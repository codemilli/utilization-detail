import SwiftUI

struct UtilizationFooterView: View {
    let footnote: String

    var body: some View {
        Text(footnote)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.top, 4)
    }
}
