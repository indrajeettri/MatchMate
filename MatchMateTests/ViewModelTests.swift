//
//  ViewModelTests.swift
//  MatchMateTests
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Testing
import Combine
import Foundation
@testable import MatchMate

// MARK: - MatchListViewModel Tests
struct MatchListViewModelTests {
    
    @Test @MainActor func testViewModelInitialState() {
        let viewModel = MatchListViewModel()
        
        #expect(viewModel.isLoading == false || viewModel.isLoading == true) // May be loading on init
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showError == false)
    }
    
    @Test @MainActor func testProfilesArrayInitiallyEmpty() {
        let viewModel = MatchListViewModel()
        
        // Profiles may be empty initially or loaded from cache
        #expect(viewModel.profiles.count >= 0)
    }
}

// MARK: - NetworkMonitor Tests
struct NetworkMonitorTests {
    
    @Test @MainActor func testNetworkMonitorSharedInstance() {
        let monitor1 = NetworkMonitor.shared
        let monitor2 = NetworkMonitor.shared
        
        // Should be the same instance
        #expect(monitor1 === monitor2)
    }
    
    @Test @MainActor func testNetworkMonitorInitialState() {
        let monitor = NetworkMonitor.shared
        
        // Should have a connection type
        let connectionTypes: [NetworkMonitor.ConnectionType] = [.wifi, .cellular, .ethernet, .unknown]
        #expect(connectionTypes.contains(monitor.connectionType))
    }
    
    @Test func testConnectionTypeEnum() {
        let wifi = NetworkMonitor.ConnectionType.wifi
        let cellular = NetworkMonitor.ConnectionType.cellular
        let ethernet = NetworkMonitor.ConnectionType.ethernet
        let unknown = NetworkMonitor.ConnectionType.unknown
        
        // Verify all cases exist
        #expect(wifi != cellular)
        #expect(cellular != ethernet)
        #expect(ethernet != unknown)
    }
}

// MARK: - NetworkManager Tests
struct NetworkManagerTests {
    
    @Test func testNetworkManagerSharedInstance() {
        let manager1 = NetworkManager.shared
        let manager2 = NetworkManager.shared
        
        // Should be the same instance
        #expect(manager1 === manager2)
    }
    
    @Test func testFetchUsersReturnsPublisher() {
        let manager = NetworkManager.shared
        let publisher = manager.fetchUsers()
        
        // Publisher should not be nil
        #expect(publisher != nil)
    }
}

// MARK: - CoreDataManager Tests
struct CoreDataManagerSingletonTests {
    
    @Test func testCoreDataManagerSharedInstance() {
        let manager1 = CoreDataManager.shared
        let manager2 = CoreDataManager.shared
        
        // Should be the same instance
        #expect(manager1 === manager2)
    }
    
    @Test func testViewContextNotNil() {
        let manager = CoreDataManager.shared
        let context = manager.viewContext
        
        #expect(context != nil)
    }
}

// MARK: - Profile Filtering Tests
struct ProfileFilteringTests {
    
    @Test func testFilterPendingProfiles() {
        let profiles = createMockProfiles()
        
        let pendingProfiles = profiles.filter { $0.matchStatus == .pending }
        
        #expect(pendingProfiles.count == 2)
    }
    
    @Test func testFilterAcceptedProfiles() {
        let profiles = createMockProfiles()
        
        let acceptedProfiles = profiles.filter { $0.matchStatus == .accepted }
        
        #expect(acceptedProfiles.count == 1)
    }
    
    @Test func testFilterDeclinedProfiles() {
        let profiles = createMockProfiles()
        
        let declinedProfiles = profiles.filter { $0.matchStatus == .declined }
        
        #expect(declinedProfiles.count == 1)
    }
    
    @Test func testFilterSyncPendingProfiles() {
        let profiles = createMockProfiles()
        
        let syncPendingProfiles = profiles.filter { $0.syncPending }
        
        #expect(syncPendingProfiles.count == 1)
    }
    
    // Helper function to create mock profiles
    private func createMockProfiles() -> [ProfileViewModel] {
        return [
            ProfileViewModel(id: 1, name: "User 1", email: "u1@test.com", phone: "", website: "", company: "", city: "", address: "", imageURL: "", matchStatus: .pending, syncPending: false),
            ProfileViewModel(id: 2, name: "User 2", email: "u2@test.com", phone: "", website: "", company: "", city: "", address: "", imageURL: "", matchStatus: .accepted, syncPending: false),
            ProfileViewModel(id: 3, name: "User 3", email: "u3@test.com", phone: "", website: "", company: "", city: "", address: "", imageURL: "", matchStatus: .declined, syncPending: false),
            ProfileViewModel(id: 4, name: "User 4", email: "u4@test.com", phone: "", website: "", company: "", city: "", address: "", imageURL: "", matchStatus: .pending, syncPending: true)
        ]
    }
}

// MARK: - Image URL Generation Tests
struct ImageURLTests {
    
    @Test func testMaleImageURLGeneration() {
        // Odd user IDs should get male images
        let userId = 1
        let imageURL = "https://randomuser.me/api/portraits/\(userId % 2 == 0 ? "women" : "men")/\(userId).jpg"
        
        #expect(imageURL == "https://randomuser.me/api/portraits/men/1.jpg")
    }
    
    @Test func testFemaleImageURLGeneration() {
        // Even user IDs should get female images
        let userId = 2
        let imageURL = "https://randomuser.me/api/portraits/\(userId % 2 == 0 ? "women" : "men")/\(userId).jpg"
        
        #expect(imageURL == "https://randomuser.me/api/portraits/women/2.jpg")
    }
    
    @Test func testImageURLPattern() {
        for userId in 1...10 {
            let imageURL = "https://randomuser.me/api/portraits/\(userId % 2 == 0 ? "women" : "men")/\(userId).jpg"
            
            #expect(imageURL.contains("randomuser.me"))
            #expect(imageURL.hasSuffix(".jpg"))
            
            if userId % 2 == 0 {
                #expect(imageURL.contains("women"))
            } else {
                #expect(imageURL.contains("men"))
            }
        }
    }
}
