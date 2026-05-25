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
    @State private var isAcceptPressed = false
    @State private var isDeclinePressed = false
    
    // Cyan/Teal color matching the reference design
    private let accentColor = Color(red: 0.18, green: 0.8, blue: 0.82)
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image - Large circular with shadow
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                
                profileImage
                    .frame(width: 190, height: 190)
                    .clipShape(Circle())
            }
            
            // Name in cyan color with underline
            VStack(spacing: 6) {
                Text(profile.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(accentColor)
                
                // Underline
                Rectangle()
                    .fill(accentColor)
                    .frame(width: 60, height: 3)
                    .cornerRadius(1.5)
            }
            
            // Address details
            VStack(spacing: 4) {
                Text(profile.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text(profile.city)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Status or Action Buttons
            statusOrActionView
                .padding(.top, 12)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
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
                gradient: Gradient(colors: [accentColor.opacity(0.3), accentColor.opacity(0.5)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.white)
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
        HStack(spacing: 50) {
            // Decline Button - Circular with X
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isDeclinePressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onDecline()
                    isDeclinePressed = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(accentColor)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .stroke(accentColor, lineWidth: 2.5)
                    )
                    .scaleEffect(isDeclinePressed ? 0.9 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Accept Button - Circular with checkmark
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAcceptPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onAccept()
                    isAcceptPressed = false
                }
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(accentColor)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .stroke(accentColor, lineWidth: 2.5)
                    )
                    .scaleEffect(isAcceptPressed ? 0.9 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
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
