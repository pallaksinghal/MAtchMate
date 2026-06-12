# MatchMate - Matrimonial Card Interface (iOS)

A SwiftUI-based iOS application that simulates a Matrimonial App by displaying match profile cards. Users can browse profiles fetched from the RandomUser API, accept or decline matches, and have their decisions persist locally — even in offline mode.

---

## Features

- **Profile Cards** — Beautiful card-based UI showing profile photo, name, age, and location
- **Accept / Decline** — Tap to accept or decline a match; status persists in Core Data
- **Filter Tabs** — Segmented control to filter by All / Accepted / Declined
- **Offline Mode** — Cached profiles and images available without internet; decisions saved locally
- **Auto-Sync** — Automatically fetches fresh profiles when connectivity is restored
- **Pull-to-Refresh** — Swipe down to load new profiles
- **Haptic Feedback** — Tactile feedback on accept/decline actions
- **Dark Mode** — Full support for iOS light and dark appearance
- **Animated Transitions** — Smooth spring animations when updating card status

---

## Architecture

**MVVM (Model-View-ViewModel)** with **Combine** for reactive data flow.

```
Views (SwiftUI)
   │  @StateObject / @EnvironmentObject
   ▼
ViewModel (MatchListViewModel)
   │  Combine Publishers
   ▼
Services & Core Data
   ├── NetworkService (URLSession + Combine)
   ├── NetworkMonitor (NWPathMonitor)
   └── CoreDataManager (NSPersistentContainer)
```

---

## Tech Stack

| Component         | Library / Framework              |
|-------------------|----------------------------------|
| UI                | SwiftUI                          |
| Architecture      | MVVM                             |
| Networking        | URLSession + Combine             |
| Image Loading     | SDWebImageSwiftUI (SPM)          |
| Local Database    | Core Data                        |
| Reactive Layer    | Combine                          |
| Connectivity      | Network.framework (NWPathMonitor)|
| Dependency Mgmt   | Swift Package Manager            |

---

## Requirements

- **Xcode** 15.0+
- **iOS** 16.0+
- **Swift** 5.9+
- macOS Ventura or later (for development)

---

## Setup & Run

### Option 1: Using XcodeGen (recommended)

```bash
# Install XcodeGen if needed
brew install xcodegen

# Navigate to project root
cd MatchMate

# Generate Xcode project
xcodegen generate

# Open in Xcode
open MatchMate.xcodeproj
```

### Option 2: Open existing project

If the `.xcodeproj` is already generated:

```bash
open MatchMate.xcodeproj
```

Then:
1. Wait for SPM to resolve `SDWebImageSwiftUI` dependency
2. Select an iPhone simulator (iOS 16+)
3. Press **⌘R** to build and run

---

## Project Structure

```
MatchMate/
├── App/
│   └── MatchMateApp.swift              # App entry point
├── Models/
│   ├── UserAPIResponse.swift           # Codable models for API JSON
│   └── MatchStatus.swift               # Status enum (none/accepted/declined)
├── CoreData/
│   ├── CoreDataManager.swift           # NSPersistentContainer singleton
│   ├── MatchProfile+Extensions.swift   # Computed properties on entity
│   └── MatchMate.xcdatamodeld          # Core Data model
├── Services/
│   ├── NetworkService.swift            # URLSession API calls via Combine
│   └── NetworkMonitor.swift            # NWPathMonitor connectivity wrapper
├── ViewModels/
│   └── MatchListViewModel.swift        # Business logic, fetch/accept/decline
├── Views/
│   ├── MatchListView.swift             # Main screen with list + filters
│   ├── MatchCardView.swift             # Individual profile card
│   └── Components/
│       ├── ActionButton.swift          # Accept/Decline button component
│       ├── ProfileImageView.swift      # SDWebImage wrapper
│       ├── StatusBadgeView.swift       # Accepted/Declined badge
│       └── EmptyStateView.swift        # Empty state placeholder
└── Resources/
    └── Assets.xcassets                 # Colors, app icon
```

---

## API

- **Endpoint:** `https://randomuser.me/api/?results=10`
- Fetches 10 random user profiles per request
- Read-only API — accept/decline decisions are stored locally only

---

## Offline Mode Details

| Scenario                    | Behavior                                               |
|-----------------------------|--------------------------------------------------------|
| App launched offline        | Displays cached profiles from Core Data                |
| Accept/Decline while offline| Saved immediately to Core Data                         |
| Network restored            | Auto-fetches new profiles; merges with existing data   |
| App closed and reopened     | All profiles and decisions persist via Core Data       |
| Images offline              | SDWebImage serves from disk cache                      |

---

## Data Persistence

- Profiles are **upserted** (insert or update) keyed by UUID
- Accept/decline status is **never overwritten** by API refreshes
- New API responses add new profiles; existing ones keep their status
- Core Data uses `NSMergeByPropertyObjectTrumpMergePolicy` for conflict resolution

---

## Error Handling

- **Network errors** — Alert shown + fallback to cached data
- **Core Data errors** — Logged with user-facing error state
- **Empty state** — Friendly message with contextual icon per filter tab
- **Image failures** — Placeholder avatar displayed
- **HTTP errors** — Status code validation before decoding

---

## License

This project is for educational/assignment purposes.
