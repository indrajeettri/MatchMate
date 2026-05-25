//
//  User.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation

// MARK: - User Model (API Response)
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
}

struct Address: Codable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
}

struct Geo: Codable {
    let lat: String
    let lng: String
}

struct Company: Codable {
    let name: String
    let catchPhrase: String
    let bs: String
}

// MARK: - Match Status
enum MatchStatus: String, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    
    var displayText: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Member Accepted"
        case .declined: return "Member Declined"
        }
    }
}

// MARK: - Profile View Model
struct ProfileViewModel: Identifiable {
    let id: Int64  // This is profileId from Core Data
    let name: String
    let email: String
    let phone: String
    let website: String
    let company: String
    let city: String
    let address: String
    let imageURL: String
    var matchStatus: MatchStatus
    var syncPending: Bool
    
    /// Memberwise initializer
    init(id: Int64, name: String, email: String, phone: String, website: String,
         company: String, city: String, address: String, imageURL: String,
         matchStatus: MatchStatus, syncPending: Bool) {
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
    
    /// Initialize from Core Data MatchProfile entity
    init(profile: MatchProfile) {
        self.init(
            id: profile.profileId,
            name: profile.name ?? "Unknown",
            email: profile.email ?? "",
            phone: profile.phone ?? "",
            website: profile.website ?? "",
            company: profile.company ?? "",
            city: profile.city ?? "",
            address: profile.address ?? "",
            imageURL: profile.imageURL ?? "",
            matchStatus: MatchStatus(rawValue: profile.matchStatus ?? "pending") ?? .pending,
            syncPending: profile.syncPending
        )
    }
}
