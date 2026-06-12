import SwiftUI

@main
struct MatchMateApp: App {
    let coreDataManager = CoreDataManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            MatchListView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
                .environmentObject(networkMonitor)
        }
    }
}
