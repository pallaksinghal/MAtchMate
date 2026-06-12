import SwiftUI

struct StatusBadgeView: View {
    let status: MatchStatus

    private var color: Color {
        status == .accepted ? .green : .red
    }

    private var icon: String {
        status == .accepted ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
            Text(status.displayText)
                .font(.headline)
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadgeView(status: .accepted)
        StatusBadgeView(status: .declined)
    }
    .padding()
}
