//
//  ServiceProtocols.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation
import Combine

// MARK: - Network Service Protocol (Interface Segregation)
protocol NetworkServiceProtocol: Sendable {
    func fetchUsers() -> AnyPublisher<[User], NetworkError>
    func syncMatchStatus(profileId: Int64, status: MatchStatus) -> AnyPublisher<Bool, NetworkError>
}

// MARK: - Persistence Protocols (Interface Segregation)

/// Protocol for fetching profiles
protocol ProfileFetchingProtocol {
    func fetchAllProfiles() -> [MatchProfile]
    func fetchProfile(byId id: Int64) -> MatchProfile?
}

/// Protocol for persisting profiles
protocol ProfilePersistingProtocol {
    func saveOrUpdateProfile(from user: User)
    func updateMatchStatus(profileId: Int64, status: MatchStatus, syncPending: Bool)
    func deleteAllProfiles()
}

/// Protocol for sync management
protocol SyncManagingProtocol {
    func fetchPendingSyncProfiles() -> [MatchProfile]
    func markAsSynced(profileId: Int64)
}

/// Combined persistence protocol
protocol PersistenceServiceProtocol: ProfileFetchingProtocol, ProfilePersistingProtocol, SyncManagingProtocol {}

// MARK: - Network Monitoring Protocol
protocol NetworkMonitorProtocol: ObservableObject {
    var isConnected: Bool { get }
    var connectionType: NetworkMonitor.ConnectionType { get }
}
