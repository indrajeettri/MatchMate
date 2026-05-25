//
//  SyncService.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation
import Combine

// MARK: - Sync Service Protocol
protocol SyncServiceProtocol {
    func syncMatchStatus(profileId: Int64, status: MatchStatus, completion: @escaping (Bool) -> Void)
    func syncAllPendingChanges()
}

// MARK: - Sync Service Implementation
final class SyncService: SyncServiceProtocol {
    
    // MARK: - Dependencies (Dependency Inversion)
    private let networkService: NetworkServiceProtocol
    private let persistenceService: PersistenceServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization with Dependency Injection
    init(networkService: NetworkServiceProtocol = NetworkManager.shared,
         persistenceService: PersistenceServiceProtocol = CoreDataManager.shared) {
        self.networkService = networkService
        self.persistenceService = persistenceService
    }
    
    // MARK: - SyncServiceProtocol Implementation
    
    func syncMatchStatus(profileId: Int64, status: MatchStatus, completion: @escaping (Bool) -> Void) {
        networkService.syncMatchStatus(profileId: profileId, status: status)
            .sink { result in
                if case .failure(let error) = result {
                    print("Sync failed: \(error.localizedDescription)")
                    // Mark as pending sync on failure
                    self.persistenceService.updateMatchStatus(profileId: profileId, status: status, syncPending: true)
                    completion(false)
                }
            } receiveValue: { [weak self] success in
                if success {
                    self?.persistenceService.markAsSynced(profileId: profileId)
                }
                completion(success)
            }
            .store(in: &cancellables)
    }
    
    func syncAllPendingChanges() {
        let pendingProfiles = persistenceService.fetchPendingSyncProfiles()
        
        for profile in pendingProfiles {
            guard let statusString = profile.matchStatus,
                  let status = MatchStatus(rawValue: statusString) else { continue }
            
            syncMatchStatus(profileId: profile.profileId, status: status) { _ in }
        }
    }
}
