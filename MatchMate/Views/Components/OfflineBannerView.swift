//
//  OfflineBannerView.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.subheadline)
            Text("You're offline. Changes will sync when connected.")
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.orange)
    }
}

#Preview {
    OfflineBannerView()
}
