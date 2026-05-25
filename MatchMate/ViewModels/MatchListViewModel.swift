//
//  MatchListViewModel.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation
import Combine

final class MatchListViewModel: ObservableObject {
    @Published var profiles: [ProfileViewModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var isOffline: Bool = false
    
    private let networkManager = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    private let networkMonitor = NetworkMonitor.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
        let cachedProfiles = coreDataManager.fetchAllProfiles()
        profiles = cachedProfiles.map { ProfileViewModel(from: $0) }
    }
    
    func fetchFromAPI() {
        guard networkMonitor.isConnected else {
            isOffline = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        networkManager.fetchUsers()
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
            coreDataManager.saveOrUpdateProfile(from: user)
        }
    }
    
    // MARK: - Accept/Decline Actions
    func acceptProfile(_ profileId: Int64) {
        updateMatchStatus(profileId: profileId, status: .accepted)
    }
    
    func declineProfile(_ profileId: Int64) {
        updateMatchStatus(profileId: profileId, status: .declined)
    }
    
    private func updateMatchStatus(profileId: Int64, status: MatchStatus) {
        let syncPending = !networkMonitor.isConnected
        
        // Update local database
        coreDataManager.updateMatchStatus(profileId: profileId, status: status, syncPending: syncPending)
        
        // Update UI
        if let index = profiles.firstIndex(where: { $0.id == profileId }) {
            profiles[index].matchStatus = status
            profiles[index].syncPending = syncPending
        }
        
        // Sync with server if online
        if networkMonitor.isConnected {
            syncStatusWithServer(profileId: profileId, status: status)
        }
    }
    
    private func syncStatusWithServer(profileId: Int64, status: MatchStatus) {
        networkManager.syncMatchStatus(profileId: profileId, status: status)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    // Mark as pending sync on failure
                    self?.coreDataManager.updateMatchStatus(profileId: profileId, status: status, syncPending: true)
                    print("Sync failed: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] success in
                if success {
                    self?.coreDataManager.markAsSynced(profileId: profileId)
                    if let index = self?.profiles.firstIndex(where: { $0.id == profileId }) {
                        self?.profiles[index].syncPending = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sync Pending Changes
    func syncPendingChanges() {
        let pendingProfiles = coreDataManager.fetchPendingSyncProfiles()
        
        for profile in pendingProfiles {
            guard let statusString = profile.matchStatus,
                  let status = MatchStatus(rawValue: statusString) else { continue }
            
            syncStatusWithServer(profileId: profile.profileId, status: status)
        }
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
