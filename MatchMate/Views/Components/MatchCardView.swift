//
//  MatchCardView.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import SwiftUI

struct MatchCardView: View {
    let profile: ProfileViewModel
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @State private var imageLoadFailed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Profile Image Section
            ZStack(alignment: .bottomLeading) {
                profileImage
                
                // Gradient Overlay
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Name and Location
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text(profile.city)
                            .font(.subheadline)
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding()
            }
            .frame(height: 280)
            .clipped()
            
            // Details Section
            VStack(alignment: .leading, spacing: 12) {
                // Company Info
                HStack(spacing: 8) {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(.pink)
                        .frame(width: 24)
                    Text(profile.company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Email Info
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.pink)
                        .frame(width: 24)
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Phone Info
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.pink)
                        .frame(width: 24)
                    Text(profile.phone)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Status or Action Buttons
                statusOrActionView
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Profile Image
    @ViewBuilder
    private var profileImage: some View {
        if imageLoadFailed {
            placeholderImage
        } else {
            AsyncImage(url: URL(string: profile.imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.2))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderImage
                        .onAppear { imageLoadFailed = true }
                @unknown default:
                    placeholderImage
                }
            }
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Status or Action View
    @ViewBuilder
    private var statusOrActionView: some View {
        switch profile.matchStatus {
        case .pending:
            actionButtons
        case .accepted:
            statusBadge(text: "Member Accepted", color: .green, icon: "checkmark.circle.fill")
        case .declined:
            statusBadge(text: "Member Declined", color: .red, icon: "xmark.circle.fill")
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Decline Button
            Button(action: onDecline) {
                HStack {
                    Image(systemName: "xmark")
                        .font(.headline)
                    Text("Decline")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red, lineWidth: 2)
                )
                .foregroundColor(.red)
            }
            
            // Accept Button
            Button(action: onAccept) {
                HStack {
                    Image(systemName: "checkmark")
                        .font(.headline)
                    Text("Accept")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.pink, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private func statusBadge(text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
            Text(text)
                .fontWeight(.semibold)
            
            if profile.syncPending {
                Spacer()
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            MatchCardView(
                profile: ProfileViewModel(
                    id: 1,
                    name: "Priya Sharma",
                    email: "priya@example.com",
                    phone: "+91 98765 43210",
                    website: "priya.com",
                    company: "Tech Solutions",
                    city: "Mumbai",
                    address: "123 Main St",
                    imageURL: "https://randomuser.me/api/portraits/women/1.jpg",
                    matchStatus: .pending,
                    syncPending: false
                ),
                onAccept: {},
                onDecline: {}
            )
            
            MatchCardView(
                profile: ProfileViewModel(
                    id: 2,
                    name: "Rahul Verma",
                    email: "rahul@example.com",
                    phone: "+91 98765 43211",
                    website: "rahul.com",
                    company: "Finance Corp",
                    city: "Delhi",
                    address: "456 Oak Ave",
                    imageURL: "https://randomuser.me/api/portraits/men/2.jpg",
                    matchStatus: .accepted,
                    syncPending: false
                ),
                onAccept: {},
                onDecline: {}
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

// MARK: - ProfileViewModel Extension for Preview
extension ProfileViewModel {
    init(id: Int64, name: String, email: String, phone: String, website: String, company: String, city: String, address: String, imageURL: String, matchStatus: MatchStatus, syncPending: Bool) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.website = website
        self.company = company
        self.city = city
        self.address = address
        self.imageURL = imageURL
        self.matchStatus = matchStatus
        self.syncPending = syncPending
    }
}
