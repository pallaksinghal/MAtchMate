import CoreData

extension MatchProfile {

    var matchStatus: MatchStatus {
        get { MatchStatus(rawValue: status ?? "none") ?? .none }
        set { status = newValue.rawValue }
    }

    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }

    var locationText: String {
        let c = city ?? ""
        let co = country ?? ""
        if c.isEmpty && co.isEmpty { return "Unknown Location" }
        if c.isEmpty { return co }
        if co.isEmpty { return c }
        return "\(c), \(co)"
    }
}
