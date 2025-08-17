//
//  WithUndoRedo.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 17..
//

import SwiftUI
import SwiftData

// On shake modifier
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

// A view modifier that detects shaking and calls a function of our choosing.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// A View extension to make the modifier easier to use.
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}

// Undo-redo modifieer
extension View {
    public func withUndoRedo(_ undoManager: @escaping (UndoManager) -> Void) -> some View {
        modifier(UndoRedoAwareModifier(register: undoManager))
    }
}

struct UndoRedoAction: Identifiable {
    enum UndoOrRedo {
        case undo, redo
    }
    let id: UUID
    let title: String
    let undoOrRedo: UndoOrRedo

    private init(_ undoOrRedo: UndoOrRedo, title: String) {
        self.id = UUID()
        self.title = title
        self.undoOrRedo = undoOrRedo
    }

    static func undo(title: String) -> Self {
        .init(.undo, title: title)
    }

    static func redo(title: String) -> Self {
        .init(.redo, title: title)
    }
}

struct UndoRedoAwareModifier: ViewModifier {
    @Environment(\.undoManager)
    private var undoManager
    @Environment(\.modelContext)
    private var modelContext

    let register: (UndoManager) -> Void

    @State private var isShakeToUndoEnabled = UIAccessibility.isShakeToUndoEnabled
    @State private var action: UndoRedoAction?

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard let undoManager else {
                    return
                }
                register(undoManager)
            }
            .onChange(of: undoManager) { _, newUndoManager in
                guard let newUndoManager else {
                    return
                }
                register(newUndoManager)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.shakeToUndoDidChangeNotification)) { _ in
                isShakeToUndoEnabled = UIAccessibility.isShakeToUndoEnabled
            }
            .onShake {
                guard isShakeToUndoEnabled else {
                    return
                }
                guard let undoManager, action == nil else {
                    return
                }
                if undoManager.canRedo {
                    action = .redo(title: undoManager.redoMenuItemTitle)
                } else if undoManager.canUndo {
                    action = .undo(title: undoManager.undoMenuItemTitle)
                }
            }
            .alert(item: $action) { info in
                Alert(title: Text(info.title), primaryButton: .default(Text("Yes"), action: {
                    withAnimation {
                        switch info.undoOrRedo {
                        case .undo:
                            undoManager?.undo()
                        case .redo:
                            undoManager?.redo()
                        }
                    }
                    // Persist and flush changes so UI reflects immediately
                    try? modelContext.save()
                }), secondaryButton: .cancel(Text("No")))
            }
    }
}
