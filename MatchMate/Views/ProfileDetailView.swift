//
//  ProfileDetailView.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import SwiftUI

struct ProfileDetailView: View {
    let profile: ProfileViewModel
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private let accentColor = Color(red: 0.18, green: 0.8, blue: 0.82)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with image
                headerSection
                
                // Personal Details
                detailsSection
                
                // Action Buttons (if pending)
                if profile.matchStatus == .pending {
                    actionButtonsSection
                }
                
                // Status Badge (if not pending)
                if profile.matchStatus != .pending {
                    statusSection
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(accentColor)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: profile.imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 150, height: 150)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .frame(width: 150, height: 150)
                        .background(accentColor.opacity(0.5))
                        .clipShape(Circle())
                @unknown default:
                    EmptyView()
                }
            }
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // Name
            Text(profile.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(accentColor)
            
            // City
            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(accentColor)
                Text(profile.city)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("Personal Details")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            // Detail Rows
            VStack(spacing: 0) {
                DetailRow(icon: "envelope.fill", title: "Email", value: profile.email, color: accentColor)
                Divider().padding(.leading, 56)
                
                DetailRow(icon: "phone.fill", title: "Phone", value: profile.phone, color: accentColor)
                Divider().padding(.leading, 56)
                
                DetailRow(icon: "globe", title: "Website", value: profile.website, color: accentColor)
                Divider().padding(.leading, 56)
                
                DetailRow(icon: "building.2.fill", title: "Company", value: profile.company, color: accentColor)
                Divider().padding(.leading, 56)
                
                DetailRow(icon: "location.fill", title: "Address", value: profile.address, color: accentColor)
            }
            .background(Color(.systemBackground))
        }
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            Text("Interested in this profile?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                // Decline Button
                Button(action: {
                    onDecline()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.headline)
                        Text("Decline")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 2)
                    )
                    .foregroundColor(.red)
                }
                
                // Accept Button
                Button(action: {
                    onAccept()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.headline)
                        Text("Accept")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        HStack(spacing: 12) {
            Image(systemName: profile.matchStatus == .accepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
            
            Text(profile.matchStatus.displayText)
                .fontWeight(.semibold)
            
            if profile.syncPending {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Sync Pending")
                        .font(.caption)
                }
                .foregroundColor(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(profile.matchStatus == .accepted ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
        .foregroundColor(profile.matchStatus == .accepted ? .green : .red)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value.isEmpty ? "Not available" : value)
                    .font(.body)
                    .foregroundColor(value.isEmpty ? .secondary : .primary)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileDetailView(
            profile: ProfileViewModel(
                id: 1,
                name: "Leanne Graham",
                email: "Sincere@april.biz",
                phone: "1-770-736-8031 x56442",
                website: "hildegard.org",
                company: "Romaguera-Crona",
                city: "Gwenborough",
                address: "Kulas Light, Apt. 556, Gwenborough",
                imageURL: "https://randomuser.me/api/portraits/men/1.jpg",
                matchStatus: .pending,
                syncPending: false
            ),
            onAccept: {},
            onDecline: {}
        )
    }
}
