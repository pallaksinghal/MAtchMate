import Foundation
import Combine
import CoreData
import UIKit

// MARK: - Filter

enum FilterOption: String, CaseIterable {
    case all = "All"
    case accepted = "Accepted"
    case declined = "Declined"
}

// MARK: - ViewModel

final class MatchListViewModel: ObservableObject {

    // MARK: Published State
    @Published var profiles: [MatchProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var selectedFilter: FilterOption = .all

    // MARK: Dependencies
    private let networkService = NetworkService.shared
    private let coreDataManager = CoreDataManager.shared
    private let networkMonitor = NetworkMonitor.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init() {
        setupBindings()
        loadCachedProfiles()
        fetchProfiles()
    }

    // MARK: - Public

    func fetchProfiles() {
        guard networkMonitor.isConnected else {
            loadCachedProfiles()
            return
        }

        isLoading = true
        errorMessage = nil

        networkService.fetchUsers()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    self?.loadCachedProfiles()
                }
            }, receiveValue: { [weak self] users in
                self?.upsertProfiles(users)
            })
            .store(in: &cancellables)
    }

    func acceptProfile(_ profile: MatchProfile) {
        updateProfileStatus(profile, status: .accepted)
        haptic(.success)
    }

    func declineProfile(_ profile: MatchProfile) {
        updateProfileStatus(profile, status: .declined)
        haptic(.warning)
    }

    // MARK: - Private

    private func setupBindings() {
        // Auto-fetch when network becomes available
        networkMonitor.$isConnected
            .removeDuplicates()
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in
                self?.fetchProfiles()
            }
            .store(in: &cancellables)

        // Reload list when filter changes
        $selectedFilter
            .dropFirst()
            .sink { [weak self] newFilter in
                self?.loadCachedProfiles(filter: newFilter)
            }
            .store(in: &cancellables)
    }

    private func updateProfileStatus(_ profile: MatchProfile, status: MatchStatus) {
        profile.matchStatus = status
        coreDataManager.saveContext()
        loadCachedProfiles()
    }

    func loadCachedProfiles(filter: FilterOption? = nil) {
        let activeFilter = filter ?? selectedFilter
        let request = NSFetchRequest<MatchProfile>(entityName: "MatchProfile")
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]

        switch activeFilter {
        case .accepted:
            request.predicate = NSPredicate(format: "status == %@", MatchStatus.accepted.rawValue)
        case .declined:
            request.predicate = NSPredicate(format: "status == %@", MatchStatus.declined.rawValue)
        case .all:
            request.predicate = NSPredicate(format: "status == %@ OR status == nil", MatchStatus.none.rawValue)
        }

        do {
            profiles = try coreDataManager.viewContext.fetch(request)
        } catch {
            errorMessage = "Failed to load profiles: \(error.localizedDescription)"
            showError = true
        }
    }

    private func upsertProfiles(_ users: [UserResult]) {
        let context = coreDataManager.viewContext

        for user in users {
            let request = NSFetchRequest<MatchProfile>(entityName: "MatchProfile")
            request.predicate = NSPredicate(format: "uuid == %@", user.login.uuid)
            request.fetchLimit = 1

            if let existing = try? context.fetch(request).first {
                // Update details but preserve accept/decline status
                existing.firstName = user.name.first
                existing.lastName = user.name.last
                existing.age = Int16(user.dob.age)
                existing.city = user.location.city
                existing.country = user.location.country
                existing.email = user.email
                existing.phone = user.phone
                existing.imageURL = user.picture.large
            } else {
                // Insert new profile
                let profile = MatchProfile(context: context)
                profile.uuid = user.login.uuid
                profile.firstName = user.name.first
                profile.lastName = user.name.last
                profile.age = Int16(user.dob.age)
                profile.city = user.location.city
                profile.country = user.location.country
                profile.email = user.email
                profile.phone = user.phone
                profile.imageURL = user.picture.large
                profile.status = MatchStatus.none.rawValue
            }
        }

        coreDataManager.saveContext()
        loadCachedProfiles()
    }

    private func haptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
