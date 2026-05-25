//
//  EmptyStateView.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.pink.opacity(0.6))
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.pink, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }
}

#Preview {
    EmptyStateView(
        title: "No Matches Found",
        message: "We couldn't find any matches for you. Please try again later.",
        systemImage: "heart.slash",
        actionTitle: "Refresh",
        action: {}
    )
}
