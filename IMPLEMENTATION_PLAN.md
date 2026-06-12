# MatchMate - Implementation Plan

## Overview
MatchMate is an iOS matrimonial card interface app that fetches user profiles from the RandomUser API and lets users Accept or Decline matches. Decisions persist locally via Core Data and the app works fully offline.

---

## Architecture: MVVM + Combine

```
┌─────────────────────────────────────────────┐
│                   View Layer                │
│  MatchListView ─ MatchCardView ─ StatusBadge│
└──────────────────┬──────────────────────────┘
                   │ @StateObject / @ObservedObject
┌──────────────────▼──────────────────────────┐
│               ViewModel Layer               │
│         MatchListViewModel                  │
│  - fetchProfiles()                          │
│  - accept(profile)                          │
│  - decline(profile)                         │
│  - filterByStatus()                         │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              Service / Repository           │
│  NetworkService  │  CoreDataManager         │
│  (URLSession)    │  (NSPersistentContainer) │
│                  │                          │
│  NetworkMonitor  │  ImageCacheService       │
└─────────────────────────────────────────────┘
```

---

## Tech Stack

| Component          | Choice                          | Rationale                                    |
|--------------------|---------------------------------|----------------------------------------------|
| UI Framework       | SwiftUI                         | Assignment requirement                       |
| Architecture       | MVVM                            | Assignment requirement                       |
| Networking         | URLSession + Combine            | Native, no extra dependency                  |
| Image Loading      | SDWebImageSwiftUI (SPM)         | Assignment suggests SDWebImage               |
| Local DB           | Core Data                       | Assignment requirement, offline persistence  |
| Reactive Layer     | Combine                         | Native Apple framework, pairs with SwiftUI   |
| Connectivity       | NWPathMonitor (Network.framework)| Native, monitors online/offline transitions |
| Dependency Mgmt    | Swift Package Manager           | Built into Xcode, modern                     |
| Min Target         | iOS 16                          | User choice                                  |

---

## Project Structure

```
MatchMate/
├── App/
│   └── MatchMateApp.swift              # App entry point
├── Models/
│   ├── UserAPIResponse.swift           # Codable models for API JSON
│   └── MatchStatus.swift               # Enum: .none, .accepted, .declined
├── CoreData/
│   ├── MatchMate.xcdatamodeld          # Core Data model
│   ├── CoreDataManager.swift           # NSPersistentContainer singleton
│   └── MatchProfile+Extensions.swift   # Convenience accessors
├── Services/
│   ├── NetworkService.swift            # URLSession API calls
│   ├── NetworkMonitor.swift            # NWPathMonitor wrapper
│   └── ImageCacheService.swift         # Optional disk cache helper
├── ViewModels/
│   └── MatchListViewModel.swift        # Fetch, accept, decline, filter logic
├── Views/
│   ├── MatchListView.swift             # Main scrollable list of cards
│   ├── MatchCardView.swift             # Individual profile card (image, info, buttons)
│   ├── StatusBadgeView.swift           # "Accepted" / "Declined" overlay
│   └── Components/
│       ├── ActionButton.swift          # Reusable Accept/Decline button
│       └── ProfileImageView.swift      # SDWebImage wrapper
├── Resources/
│   └── Assets.xcassets
└── README.md
```

---

## Key Implementation Details

### 1. API Integration
- **Endpoint:** `GET https://randomuser.me/api/?results=10`
- Parse JSON into `UserAPIResponse` Codable struct.
- On success, upsert profiles into Core Data (keyed by `login.uuid`).
- On failure (offline), load cached profiles from Core Data.

### 2. Core Data Model — `MatchProfile` Entity

| Attribute     | Type      | Notes                            |
|---------------|-----------|----------------------------------|
| uuid          | String    | Primary key from API             |
| firstName     | String    |                                  |
| lastName      | String    |                                  |
| age           | Int16     |                                  |
| city          | String    |                                  |
| country       | String    |                                  |
| imageURL      | String    | Large thumbnail URL              |
| email         | String    |                                  |
| phone         | String    |                                  |
| status        | String    | "none" / "accepted" / "declined" |

### 3. Card Design
- **Top:** Full-width profile image (rounded corners, shadow).
- **Middle:** Name, age, location.
- **Bottom:** Two action buttons — ✓ Accept (green) / ✗ Decline (red).
- **Overlay Badge:** Once decided, a "Member Accepted" or "Member Declined" badge appears and buttons are disabled/hidden.

### 4. Offline Mode Flow
```
App Launch
    ├── Online?
    │     ├── Fetch API → Upsert Core Data → Display
    │     └── (also cache images via SDWebImage)
    └── Offline?
          └── Load Core Data → Display cached profiles + cached images
          
Accept/Decline tap
    └── Always writes to Core Data immediately (works offline)
    └── (No server-side sync needed — randomuser.me is read-only)
```

### 5. Networking with Combine
```swift
func fetchUsers() -> AnyPublisher<[User], Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: UserAPIResponse.self, decoder: JSONDecoder())
        .map(\.results)
        .eraseToAnyPublisher()
}
```

### 6. Error Handling
- Network errors → Show alert + fallback to cached data.
- Core Data errors → Logged, user-facing error state.
- Empty state → Friendly "No matches found" view.
- Image load failure → Placeholder avatar.

---

## UI/UX Enhancements (Beyond Basic Requirements)
- **Segmented filter:** All / Accepted / Declined tabs at the top.
- **Pull-to-refresh** to fetch new profiles.
- **Smooth animations** on accept/decline (card color flash, badge slide-in).
- **Haptic feedback** on button tap.
- **Dark mode** support via system adaptive colors.

---

## Build & Run
1. Open `MatchMate.xcodeproj` in Xcode 15+.
2. SPM dependencies resolve automatically.
3. Select simulator (iPhone 15 / iOS 16+) → Run.

---

## Questions / Clarifications

> **Note:** The RandomUser API is read-only — there is no server endpoint to POST accept/decline decisions. The "sync data with the server when connection is restored" requirement will be implemented as:
> - A **sync-ready architecture** with a pending-sync queue in Core Data.
> - When connectivity is restored, the app would call a sync endpoint **if one existed**.
> - For this demo, the sync triggers a **re-fetch of fresh profiles** instead.
>
> This is the most practical interpretation. Let me know if you'd like a mock server instead.
