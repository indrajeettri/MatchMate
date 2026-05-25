//
//  MatchListView.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import SwiftUI

struct MatchListView: View {
    @StateObject private var viewModel = MatchListViewModel()
    @State private var selectedFilter: MatchFilter = .all
    
    enum MatchFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
    }
    
    var filteredProfiles: [ProfileViewModel] {
        switch selectedFilter {
        case .all:
            return viewModel.profiles
        case .pending:
            return viewModel.profiles.filter { $0.matchStatus == .pending }
        case .accepted:
            return viewModel.profiles.filter { $0.matchStatus == .accepted }
        case .declined:
            return viewModel.profiles.filter { $0.matchStatus == .declined }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Offline Banner
                    if viewModel.isOffline {
                        OfflineBannerView()
                    }
                    
                    // Filter Pills
                    filterPills
                    
                    // Content
                    if viewModel.isLoading && viewModel.profiles.isEmpty {
                        loadingView
                    } else if filteredProfiles.isEmpty {
                        emptyStateView
                    } else {
                        profileList
                    }
                }
            }
            .navigationTitle("MatchMate")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.pink)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
                Button("Retry") { viewModel.refresh() }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
    
    // MARK: - Filter Pills
    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MatchFilter.allCases, id: \.self) { filter in
                    FilterPillButton(
                        title: filter.rawValue,
                        count: countForFilter(filter),
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private func countForFilter(_ filter: MatchFilter) -> Int {
        switch filter {
        case .all:
            return viewModel.profiles.count
        case .pending:
            return viewModel.profiles.filter { $0.matchStatus == .pending }.count
        case .accepted:
            return viewModel.profiles.filter { $0.matchStatus == .accepted }.count
        case .declined:
            return viewModel.profiles.filter { $0.matchStatus == .declined }.count
        }
    }
    
    // MARK: - Profile List
    private var profileList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(filteredProfiles) { profile in
                    MatchCardView(
                        profile: profile,
                        onAccept: { viewModel.acceptProfile(profile.id) },
                        onDecline: { viewModel.declineProfile(profile.id) }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            viewModel.refresh()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Finding your matches...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        EmptyStateView(
            title: emptyStateTitle,
            message: emptyStateMessage,
            systemImage: emptyStateIcon,
            actionTitle: selectedFilter == .all ? "Refresh" : nil,
            action: selectedFilter == .all ? { viewModel.refresh() } : nil
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all:
            return "No Matches Found"
        case .pending:
            return "No Pending Matches"
        case .accepted:
            return "No Accepted Matches"
        case .declined:
            return "No Declined Matches"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return "We couldn't find any matches. Pull to refresh or check your connection."
        case .pending:
            return "You've responded to all your matches!"
        case .accepted:
            return "You haven't accepted any matches yet."
        case .declined:
            return "You haven't declined any matches yet."
        }
    }
    
    private var emptyStateIcon: String {
        switch selectedFilter {
        case .all:
            return "heart.slash"
        case .pending:
            return "checkmark.circle"
        case .accepted:
            return "heart"
        case .declined:
            return "xmark.circle"
        }
    }
}

// MARK: - Filter Pill Button
struct FilterPillButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                    )
            }
            .font(.subheadline)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? 
                          LinearGradient(gradient: Gradient(colors: [.pink, .red]), startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray5)]), startPoint: .leading, endPoint: .trailing)
                    )
            )
        }
    }
}

#Preview {
    MatchListView()
}
