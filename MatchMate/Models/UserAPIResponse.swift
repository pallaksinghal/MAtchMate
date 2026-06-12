import Foundation

// MARK: - API Response

struct UserAPIResponse: Codable {
    let results: [UserResult]
}

// MARK: - User Result

struct UserResult: Codable {
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let login: Login
    let dob: DOB
    let phone: String
    let picture: Picture

    struct Name: Codable {
        let title: String
        let first: String
        let last: String
    }

    struct Location: Codable {
        let city: String
        let state: String
        let country: String
    }

    struct Login: Codable {
        let uuid: String
    }

    struct DOB: Codable {
        let date: String
        let age: Int
    }

    struct Picture: Codable {
        let large: String
        let medium: String
        let thumbnail: String
    }
}
