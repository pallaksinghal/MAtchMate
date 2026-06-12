import SwiftUI

struct EmptyStateView: View {
    let filter: FilterOption

    private var message: String {
        switch filter {
        case .all:
            return "No matches found.\nPull down to refresh."
        case .accepted:
            return "No accepted matches yet.\nStart accepting profiles!"
        case .declined:
            return "No declined matches yet."
        }
    }

    private var icon: String {
        switch filter {
        case .all: return "heart.slash"
        case .accepted: return "checkmark.circle"
        case .declined: return "xmark.circle"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.gray.opacity(0.4))

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    EmptyStateView(filter: .all)
}
