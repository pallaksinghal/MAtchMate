import SwiftUI

struct MatchListView: View {
    @StateObject private var viewModel = MatchListViewModel()
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Offline Banner
                if !networkMonitor.isConnected {
                    offlineBanner
                }

                // Filter Picker
                filterPicker

                // Content
                if viewModel.isLoading && viewModel.profiles.isEmpty {
                    loadingView
                } else if viewModel.profiles.isEmpty {
                    EmptyStateView(filter: viewModel.selectedFilter)
                } else {
                    profileList
                }
            }
            .navigationTitle("MatchMate")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            viewModel.fetchProfiles()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(!networkMonitor.isConnected)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            }
        }
    }

    // MARK: - Subviews

    private var offlineBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash")
                .font(.caption)
            Text("You're offline. Showing cached data.")
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.orange)
        .foregroundColor(.white)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: networkMonitor.isConnected)
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.selectedFilter) {
            ForEach(FilterOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var profileList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.profiles, id: \.objectID) { profile in
                    MatchCardView(
                        profile: profile,
                        onAccept: { viewModel.acceptProfile(profile) },
                        onDecline: { viewModel.declineProfile(profile) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .refreshable {
            viewModel.fetchProfiles()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Finding matches...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

#Preview {
    MatchListView()
        .environmentObject(NetworkMonitor.shared)
}
