import Foundation

enum MatchStatus: String, CaseIterable {
    case none
    case accepted
    case declined

    var displayText: String {
        switch self {
        case .none: return "New"
        case .accepted: return "Member Accepted"
        case .declined: return "Member Declined"
        }
    }
}
