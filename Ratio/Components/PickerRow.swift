import SwiftUI

struct PickerRowDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation{
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(Color(.tertiaryLabel))
                        .rotationEffect(configuration.isExpanded ? .degrees(90.0) : .zero)
                        .animation(.default, value: configuration.isExpanded)
                    configuration.label
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
                    .transition(.push(from: .top))
            }
        }
    }
}

struct PickerRow: View {
    let title: String
    let numericText: String
    let numericValue: Double
    let value: Binding<CGFloat>
    let config: WheelPicker.Config
    @Binding var isExpanded: Bool

    init(
        title: String,
        numericText: String,
        numericValue: Double,
        value: Binding<CGFloat>,
        config: WheelPicker.Config,
        isExpanded: Binding<Bool>
    ) {
        self.title = title
        self.numericText = numericText
        self.numericValue = numericValue
        self.value = value
        self.config = config
        self._isExpanded = isExpanded
    }

    var body: some View {
        VStack {
            DisclosureGroup(isExpanded: $isExpanded) {
                WheelPicker(config: config, value: value)
                    .frame(height: 100)
                    .padding(.bottom, 4)
            } label: {
                HStack {
                    Text(title)
                    Spacer()
                    NumericText(text: numericText, numericValue: numericValue)
                        .foregroundColor(.secondary)
                        .animation(.snappy, value: numericValue)
                }
            }
            .disclosureGroupStyle(PickerRowDisclosureStyle())
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: Design.containerCornerRadius))
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    struct Wrapper: View {
        @State private var value: CGFloat = 18
        @State private var expanded: Bool = false
        var body: some View {
            PickerRow(
                title: "Dose",
                numericText: "\(Int(value))g",
                numericValue: Double(value),
                value: $value,
                config: .init(minValue: 1, maxValue: 50, spacing: 10),
                isExpanded: $expanded
            )
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
        }
    }
    return Wrapper()
}
