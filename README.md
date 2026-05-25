# MatchMate - Matrimonial Card Interface (iOS)

A SwiftUI-based iOS application that simulates a Matrimonial App by displaying match cards similar to Shaadi.com's card format. The app fetches user data from an API, displays it in a beautiful card interface, and allows users to accept or decline matches with full offline support.

## Features

- **Match Cards**: Beautiful, modern card design displaying user profiles with images, details, and action buttons
- **Accept/Decline Functionality**: Interactive buttons to accept or decline matches with visual status updates
- **Offline Mode**: Full offline support with cached data and pending sync indicators
- **Data Persistence**: Core Data integration for storing profiles and match decisions
- **Auto-Sync**: Automatic synchronization when network connectivity is restored
- **Filter System**: Filter matches by status (All, Pending, Accepted, Declined)
- **Pull to Refresh**: Swipe down to refresh the match list
- **Error Handling**: Comprehensive error handling with user-friendly messages

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** design pattern with **SOLID Principles**:

```
MatchMate/
├── Models/
│   └── User.swift                    # Data models and enums
├── Views/
│   ├── MatchListView.swift           # Main list view
│   └── Components/
│       ├── MatchCardView.swift       # Profile card component
│       ├── OfflineBannerView.swift   # Offline status banner
│       └── EmptyStateView.swift      # Empty state component
├── ViewModels/
│   └── MatchListViewModel.swift      # Business logic and state management
├── Core/
│   ├── Protocols/
│   │   └── ServiceProtocols.swift    # Protocol definitions (SOLID)
│   ├── Services/
│   │   └── SyncService.swift         # Sync logic (Single Responsibility)
│   ├── Network/
│   │   ├── NetworkManager.swift      # API calls using URLSession
│   │   └── NetworkMonitor.swift      # Network connectivity monitoring
│   └── Persistence/
│       └── CoreDataManager.swift     # Core Data operations
└── MatchMate.xcdatamodeld/           # Core Data model
```

## SOLID Principles Implementation

### S - Single Responsibility Principle
Each class has one responsibility:
- `NetworkManager` → API calls only
- `CoreDataManager` → Persistence only
- `SyncService` → Sync logic only
- `NetworkMonitor` → Connectivity monitoring only
- `MatchListViewModel` → UI state management only

### O - Open/Closed Principle
- Enums (`MatchStatus`, `NetworkError`, `APIEndpoint`) are extensible
- New features can be added without modifying existing code

### L - Liskov Substitution Principle
- All services implement protocols (`NetworkServiceProtocol`, `PersistenceServiceProtocol`)
- Mock implementations can replace real ones for testing

### I - Interface Segregation Principle
Persistence is split into focused protocols:
- `ProfileFetchingProtocol` → Read operations
- `ProfilePersistingProtocol` → Write operations
- `SyncManagingProtocol` → Sync operations

### D - Dependency Inversion Principle
- `MatchListViewModel` depends on abstractions (protocols), not concretions
- Dependencies are injected via initializer
- Enables easy testing with mock implementations

```swift
// Dependency Injection Example
init(networkService: NetworkServiceProtocol = NetworkManager.shared,
     persistenceService: PersistenceServiceProtocol = CoreDataManager.shared,
     syncService: SyncServiceProtocol? = nil)
```

## Technologies & Libraries Used

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Modern declarative UI framework |
| **Combine** | Reactive data flow management |
| **Core Data** | Local database for persistence |
| **URLSession** | Native networking for API calls |
| **NWPathMonitor** | Network connectivity monitoring |
| **AsyncImage** | Async image loading (native SwiftUI) |

## API Integration

The app fetches user data from:
```
https://jsonplaceholder.typicode.com/users
```

Profile images are generated using:
```
https://randomuser.me/api/portraits/
```

## Core Data Model

**MatchProfile Entity:**
- `id` (Int64) - Unique identifier
- `name` (String) - User's full name
- `email` (String) - Email address
- `phone` (String) - Phone number
- `website` (String) - Personal website
- `company` (String) - Company name
- `city` (String) - City
- `address` (String) - Full address
- `imageURL` (String) - Profile image URL
- `matchStatus` (String) - pending/accepted/declined
- `syncPending` (Bool) - Whether sync is pending

## Offline Mode

The app handles offline scenarios gracefully:

1. **Data Caching**: All fetched profiles are stored in Core Data
2. **Offline Actions**: Users can accept/decline matches while offline
3. **Sync Queue**: Offline actions are queued with `syncPending` flag
4. **Auto-Sync**: When connectivity is restored, pending changes sync automatically
5. **Visual Indicators**: Orange banner shows offline status; sync icon shows pending changes

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/MatchMate.git
```

2. Open the project in Xcode:
```bash
cd MatchMate
open MatchMate.xcodeproj
```

3. Build and run on simulator or device (⌘ + R)

## Usage

1. **Launch the app** - Profiles load automatically from the API
2. **Browse matches** - Scroll through the list of profile cards
3. **Accept/Decline** - Tap the Accept (green) or Decline (red) button
4. **Filter results** - Use the filter pills to view specific statuses
5. **Refresh** - Pull down or tap the refresh button to reload data

## Screenshots

The app features:
- Modern card-based UI with gradient overlays
- Profile images with fallback placeholders
- Status badges for accepted/declined matches
- Filter pills with count indicators
- Offline mode banner

## Error Handling

The app handles various error scenarios:
- **Network errors**: Shows alert with retry option
- **API errors**: Displays cached data with error message
- **No data**: Shows empty state with refresh option
- **Image loading failures**: Displays gradient placeholder

## Unit Testing

The project includes comprehensive unit tests using Swift Testing framework. Run tests with **⌘ + U** in Xcode.

### Test Files

| File | Description |
|------|-------------|
| `MatchMateTests.swift` | Core model and enum tests |
| `CoreDataTests.swift` | Core Data CRUD operation tests |
| `ViewModelTests.swift` | ViewModel and business logic tests |
| `NetworkTests.swift` | Network layer and JSON parsing tests |

### Test Coverage

#### Model Tests (`MatchMateTests.swift`)
- **UserModelTests**: JSON decoding for User, Address, Company, Geo models
- **MatchStatusTests**: Enum raw values, display text, all cases validation
- **ProfileViewModelTests**: Initialization, Identifiable conformance, mutability
- **NetworkErrorTests**: Error descriptions for all error types
- **APIEndpointTests**: URL validation and structure

#### Core Data Tests (`CoreDataTests.swift`)
- **CRUD Operations**: Create, Read, Update, Delete profiles
- **In-Memory Testing**: Uses in-memory store for isolated tests
- **Filtering**: Tests for sync pending and match status filters
- **Batch Operations**: Multiple profile fetch and sort tests

#### ViewModel Tests (`ViewModelTests.swift`)
- **MatchListViewModelTests**: Initial state validation
- **NetworkMonitorTests**: Singleton pattern, connection types
- **NetworkManagerTests**: Singleton pattern, publisher creation
- **ProfileFilteringTests**: Filter by pending/accepted/declined status
- **ImageURLTests**: Male/female image URL generation logic

#### Network Tests (`NetworkTests.swift`)
- **NetworkIntegrationTests**: Live API fetch test
- **URLValidationTests**: URL structure and scheme validation
- **JSONParsingTests**: Valid/invalid JSON handling, nested object parsing
- **ErrorHandlingTests**: Server error codes, error wrapping

### Running Tests

```bash
# Run all tests
⌘ + U

# Or via command line
xcodebuild test -scheme MatchMate -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Architecture

```
MatchMateTests/
├── MatchMateTests.swift      # Model & enum tests
├── CoreDataTests.swift       # Persistence layer tests
├── ViewModelTests.swift      # Business logic tests
└── NetworkTests.swift        # Network & parsing tests
```

## Future Improvements

- [ ] Add profile detail view
- [ ] Implement search functionality
- [ ] Add match preferences/filters
- [ ] Push notifications for new matches
- [ ] Chat functionality
- [ ] Profile editing

## License

This project is created for demonstration purposes.

## Author

Indrajeet Tripathi
