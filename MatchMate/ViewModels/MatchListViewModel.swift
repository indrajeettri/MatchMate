//
//  MatchListViewModel.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation
import Combine

// MARK: - MatchListViewModel (SOLID Compliant)
/// Single Responsibility: Manages UI state for match list
/// Open/Closed: Can be extended without modification
/// Liskov Substitution: Dependencies are protocol-based
/// Interface Segregation: Uses focused protocols
/// Dependency Inversion: Depends on abstractions, not concretions

final class MatchListViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State)
    @Published var profiles: [ProfileViewModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var isOffline: Bool = false
    
    // MARK: - Dependencies (Dependency Inversion Principle)
    private let networkService: NetworkServiceProtocol
    private let persistenceService: PersistenceServiceProtocol
    private let syncService: SyncServiceProtocol
    private let networkMonitor: NetworkMonitor
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization with Dependency Injection
    init(networkService: NetworkServiceProtocol = NetworkManager.shared,
         persistenceService: PersistenceServiceProtocol = CoreDataManager.shared,
         syncService: SyncServiceProtocol? = nil,
         networkMonitor: NetworkMonitor = NetworkMonitor.shared) {
        
        self.networkService = networkService
        self.persistenceService = persistenceService
        self.syncService = syncService ?? SyncService(networkService: networkService, persistenceService: persistenceService)
        self.networkMonitor = networkMonitor
        
        setupNetworkObserver()
        loadProfiles()
    }
    
    // MARK: - Network Observer
    private func setupNetworkObserver() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOffline = !isConnected
                if isConnected {
                    self?.syncPendingChanges()
                    self?.fetchFromAPI()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Profiles
    func loadProfiles() {
        // First load from cache
        loadFromCache()
        
        // Then fetch from API if online
        if networkMonitor.isConnected {
            fetchFromAPI()
        }
    }
    
    private func loadFromCache() {
        let cachedProfiles = persistenceService.fetchAllProfiles()
        profiles = cachedProfiles.map { ProfileViewModel(from: $0) }
    }
    
    func fetchFromAPI() {
        guard networkMonitor.isConnected else {
            isOffline = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        networkService.fetchUsers()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] users in
                self?.saveUsersToCache(users)
                debugPrint("[Users] Successfully fetched users from API \(users)")
                self?.loadFromCache()
            }
            .store(in: &cancellables)
    }
    
    private func saveUsersToCache(_ users: [User]) {
        users.forEach { user in
            persistenceService.saveOrUpdateProfile(from: user)
        }
    }
    
    // MARK: - Accept/Decline Actions (Single Responsibility)
    func acceptProfile(_ profileId: Int64) {
        updateMatchStatus(profileId: profileId, status: .accepted)
    }
    
    func declineProfile(_ profileId: Int64) {
        updateMatchStatus(profileId: profileId, status: .declined)
    }
    
    private func updateMatchStatus(profileId: Int64, status: MatchStatus) {
        let syncPending = !networkMonitor.isConnected
        
        // Update local database
        persistenceService.updateMatchStatus(profileId: profileId, status: status, syncPending: syncPending)
        
        // Update UI
        if let index = profiles.firstIndex(where: { $0.id == profileId }) {
            profiles[index].matchStatus = status
            profiles[index].syncPending = syncPending
        }
        
        // Sync with server if online (delegated to SyncService)
        if networkMonitor.isConnected {
            syncService.syncMatchStatus(profileId: profileId, status: status) { [weak self] success in
                if success {
                    if let index = self?.profiles.firstIndex(where: { $0.id == profileId }) {
                        self?.profiles[index].syncPending = false
                    }
                }
            }
        }
    }
    
    // MARK: - Sync Pending Changes (Delegated to SyncService)
    func syncPendingChanges() {
        syncService.syncAllPendingChanges()
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: NetworkError) {
        errorMessage = error.localizedDescription
        showError = true
        
        // Load from cache on error
        if profiles.isEmpty {
            loadFromCache()
        }
    }
    
    // MARK: - Refresh
    func refresh() {
        if networkMonitor.isConnected {
            fetchFromAPI()
        } else {
            loadFromCache()
        }
    }
}
