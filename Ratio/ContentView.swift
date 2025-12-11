//
//  ContentView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI
import SwiftData
import AudioToolbox

enum Screen: Hashable {
    case beans
    case brews
    case beanDetail(bean: Bean)
    case brewDetail(brew: Brew)
}

struct ContentView: View {
    @Environment(\.modelContext)
    private var modelContext

    var body: some View {
        //SystemSoundsTesterView()
        //WelcomeView()
        
        TabView {
            BeansView()
                .tabItem {
                    Image("beanbag")
                    Text("Beans")
                }
            BrewsView()
                .tabItem {
                    Image(systemName: "cup.and.saucer")
                    Text("Brews")
                }
        }
        .withUndoRedo { undoManager in
            modelContext.undoManager = undoManager
        }
    }
}

struct SystemSoundsTesterView: View {
    private let soundRange = 1000...1587
    @State private var previewSoundId: Int = 1018
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("ID: \(previewSoundId)")
                        .monospacedDigit()
                    Spacer()
                    Button("Play") {
                        play(id: previewSoundId)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                List(soundRange, id: \.self) { id in
                    HStack {
                        Text("\(id)")
                            .monospacedDigit()
                        Spacer()
                        Button("Play") {
                            previewSoundId = id
                            play(id: id)
                        }
                        .buttonStyle(.bordered)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        previewSoundId = id
                        play(id: id)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("System Sounds")
        }
    }
    
    private func play(id: Int) {
        let soundId = SystemSoundID(id)
        AudioServicesPlaySystemSound(soundId)
    }
}

#Preview {
    ContentView()
}
