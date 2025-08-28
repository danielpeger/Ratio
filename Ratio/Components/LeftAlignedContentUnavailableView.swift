import SwiftUI

struct LeftAlignedContentUnavailableView<Label: View, Description: View, Actions: View>: View {
    private let label: Label
    private let description: Description
    private let actions: Actions

    init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder description: () -> Description,
        @ViewBuilder actions: () -> Actions
    ) {
        self.label = label()
        self.description = description()
        self.actions = actions()
    }

    init(
        @ViewBuilder label: () -> Label
    ) where Description == EmptyView, Actions == EmptyView {
        self.label = label()
        self.description = EmptyView()
        self.actions = EmptyView()
    }

    init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder description: () -> Description
    ) where Actions == EmptyView {
        self.label = label()
        self.description = description()
        self.actions = EmptyView()
    }

    // Label-less initializers
    init(
        @ViewBuilder description: () -> Description,
        @ViewBuilder actions: () -> Actions
    ) where Label == EmptyView {
        self.label = EmptyView()
        self.description = description()
        self.actions = actions()
    }

    init(
        @ViewBuilder description: () -> Description
    ) where Label == EmptyView, Actions == EmptyView {
        self.label = EmptyView()
        self.description = description()
        self.actions = EmptyView()
    }

    init(
        @ViewBuilder actions: () -> Actions
    ) where Label == EmptyView, Description == EmptyView {
        self.label = EmptyView()
        self.description = EmptyView()
        self.actions = actions()
    }

    init() where Label == EmptyView, Description == EmptyView, Actions == EmptyView {
        self.label = EmptyView()
        self.description = EmptyView()
        self.actions = EmptyView()
    }

    init(
        _ titleKey: LocalizedStringKey
    ) where Label == Text, Description == EmptyView, Actions == EmptyView {
        self.label = Text(titleKey)
        self.description = EmptyView()
        self.actions = EmptyView()
    }

    init(
        _ titleKey: LocalizedStringKey,
        @ViewBuilder description: () -> Description
    ) where Label == Text, Actions == EmptyView {
        self.label = Text(titleKey)
        self.description = description()
        self.actions = EmptyView()
    }

    init(
        _ titleKey: LocalizedStringKey,
        @ViewBuilder actions: () -> Actions
    ) where Label == Text, Description == EmptyView {
        self.label = Text(titleKey)
        self.description = EmptyView()
        self.actions = actions()
    }

    init(
        _ titleKey: LocalizedStringKey,
        @ViewBuilder description: () -> Description,
        @ViewBuilder actions: () -> Actions
    ) where Label == Text {
        self.label = Text(titleKey)
        self.description = description()
        self.actions = actions()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if Label.self != EmptyView.self {
                label
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.leading)
            }

            description
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)

            if Actions.self != EmptyView.self {
                actions
                    .buttonStyle(CapsuleActionButtonStyle())
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 32)
    }
}

private struct CapsuleActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.accentColor)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

#Preview("Left-aligned empty state") {
    LeftAlignedContentUnavailableView("No Beans") {
        Text("Try adding some.")
    } actions: {
        Button("Add Bean") {}
    }
    .padding()
}


