import SwiftUI

enum ActionButtonStyle {
    case filled
    case outlined
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let style: ActionButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .fontWeight(.semibold)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(foregroundColor)
            .background(background)
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        style == .filled ? .white : color
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .filled:
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
        case .outlined:
            RoundedRectangle(cornerRadius: 12)
                .stroke(color, lineWidth: 2)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        ActionButton(title: "Decline", icon: "xmark", color: .red, style: .outlined) {}
        ActionButton(title: "Accept", icon: "checkmark.circle.fill", color: .green, style: .filled) {}
    }
    .padding()
}
