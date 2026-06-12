import SwiftUI

struct MatchCardView: View {
    let profile: MatchProfile
    let onAccept: () -> Void
    let onDecline: () -> Void

    private var status: MatchStatus {
        profile.matchStatus
    }

    var body: some View {
        VStack(spacing: 0) {
            // Profile Image
            ProfileImageView(url: profile.imageURL)
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    imageOverlay
                }

            // Info + Actions
            VStack(spacing: 12) {
                infoSection

                Divider()

                if status == .none {
                    actionButtons
                        .transition(.opacity)
                } else {
                    StatusBadgeView(status: status)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }

    // MARK: - Subviews

    private var imageOverlay: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.5)],
            startPoint: .center,
            endPoint: .bottom
        )
        .frame(height: 120)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(profile.fullName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)

                if profile.age > 0 {
                    Text(", \(profile.age)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundColor(.pink)
                Text(profile.locationText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            ActionButton(
                title: "Decline",
                icon: "xmark",
                color: .red,
                style: .outlined
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    onDecline()
                }
            }

            ActionButton(
                title: "Accept",
                icon: "checkmark.circle.fill",
                color: .green,
                style: .filled
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    onAccept()
                }
            }
        }
    }
}
