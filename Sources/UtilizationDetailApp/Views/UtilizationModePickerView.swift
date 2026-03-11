import SwiftUI

struct UtilizationModePickerView: View {
    @Binding var displayMode: UtilizationDisplayMode

    var body: some View {
        HStack(spacing: 10) {
            Picker("Display mode", selection: $displayMode) {
                ForEach(UtilizationDisplayMode.allCases) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)

            Text("%")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
                .accessibilityHidden(true)
        }
    }
}
