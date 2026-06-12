import Foundation
import Combine

final class NetworkService {
    static let shared = NetworkService()

    private let baseURL = "https://randomuser.me/api/?results=10"
    private let decoder = JSONDecoder()

    private init() {}

    /// Fetches random user profiles from the API.
    func fetchUsers() -> AnyPublisher<[UserResult], Error> {
        guard let url = URL(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: UserAPIResponse.self, decoder: decoder)
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
