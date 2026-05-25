//
//  MockServices.swift
//  MatchMateTests
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation
import Combine
import CoreData
@testable import MatchMate

// MARK: - Mock Network Service
final class MockNetworkService: NetworkServiceProtocol {
    
    var shouldFail = false
    var mockUsers: [User] = []
    var syncResult = true
    
    func fetchUsers() -> AnyPublisher<[User], NetworkError> {
        if shouldFail {
            return Fail(error: NetworkError.noInternet).eraseToAnyPublisher()
        }
        return Just(mockUsers)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func syncMatchStatus(profileId: Int64, status: MatchStatus) -> AnyPublisher<Bool, NetworkError> {
        if shouldFail {
            return Fail(error: NetworkError.serverError(500)).eraseToAnyPublisher()
        }
        return Just(syncResult)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock Persistence Service
final class MockPersistenceService: PersistenceServiceProtocol {
    
    var profiles: [MatchProfile] = []
    var pendingSyncProfiles: [MatchProfile] = []
    var savedUsers: [User] = []
    var updatedStatuses: [(Int64, MatchStatus, Bool)] = []
    var syncedProfileIds: [Int64] = []
    
    private let context: NSManagedObjectContext
    
    init() {
        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "MatchMate")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, _ in }
        self.context = container.viewContext
    }
    
    func fetchAllProfiles() -> [MatchProfile] {
        return profiles
    }
    
    func fetchProfile(byId id: Int64) -> MatchProfile? {
        return profiles.first { $0.profileId == id }
    }
    
    func saveOrUpdateProfile(from user: User) {
        savedUsers.append(user)
        
        let profile = MatchProfile(context: context)
        profile.profileId = Int64(user.id)
        profile.name = user.name
        profile.email = user.email
        profile.matchStatus = MatchStatus.pending.rawValue
        profiles.append(profile)
    }
    
    func updateMatchStatus(profileId: Int64, status: MatchStatus, syncPending: Bool) {
        updatedStatuses.append((profileId, status, syncPending))
        
        if let profile = profiles.first(where: { $0.profileId == profileId }) {
            profile.matchStatus = status.rawValue
            profile.syncPending = syncPending
        }
    }
    
    func deleteAllProfiles() {
        profiles.removeAll()
    }
    
    func fetchPendingSyncProfiles() -> [MatchProfile] {
        return pendingSyncProfiles
    }
    
    func markAsSynced(profileId: Int64) {
        syncedProfileIds.append(profileId)
        
        if let profile = profiles.first(where: { $0.profileId == profileId }) {
            profile.syncPending = false
        }
    }
}

// MARK: - Mock Sync Service
final class MockSyncService: SyncServiceProtocol {
    
    var syncedProfiles: [(Int64, MatchStatus)] = []
    var syncAllCalled = false
    var shouldSucceed = true
    
    func syncMatchStatus(profileId: Int64, status: MatchStatus, completion: @escaping (Bool) -> Void) {
        syncedProfiles.append((profileId, status))
        completion(shouldSucceed)
    }
    
    func syncAllPendingChanges() {
        syncAllCalled = true
    }
}

// MARK: - Test Data Factory
struct TestDataFactory {
    
    static func createMockUser(id: Int = 1, name: String = "Test User") -> User {
        return User(
            id: id,
            name: name,
            username: "testuser",
            email: "test@example.com",
            address: Address(
                street: "123 Test St",
                suite: "Suite 100",
                city: "Test City",
                zipcode: "12345",
                geo: Geo(lat: "0.0", lng: "0.0")
            ),
            phone: "+91 1234567890",
            website: "test.com",
            company: Company(
                name: "Test Corp",
                catchPhrase: "Testing is fun",
                bs: "test solutions"
            )
        )
    }
    
    static func createMockUsers(count: Int) -> [User] {
        return (1...count).map { createMockUser(id: $0, name: "User \($0)") }
    }
    
    static func createMockProfileViewModel(
        id: Int64 = 1,
        name: String = "Test User",
        status: MatchStatus = .pending,
        syncPending: Bool = false
    ) -> ProfileViewModel {
        return ProfileViewModel(
            id: id,
            name: name,
            email: "test@example.com",
            phone: "+91 1234567890",
            website: "test.com",
            company: "Test Corp",
            city: "Test City",
            address: "123 Test St",
            imageURL: "https://example.com/image.jpg",
            matchStatus: status,
            syncPending: syncPending
        )
    }
}
