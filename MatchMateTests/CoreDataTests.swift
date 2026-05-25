//
//  CoreDataTests.swift
//  MatchMateTests
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Testing
import CoreData
import Foundation
@testable import MatchMate

// MARK: - Core Data Manager Tests
struct CoreDataManagerTests {
    
    // Helper to create in-memory Core Data stack for testing
    static func createInMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "MatchMate")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }
    
    @Test func testMatchProfileCreation() {
        let container = CoreDataManagerTests.createInMemoryContainer()
        let context = container.viewContext
        
        let profile = MatchProfile(context: context)
        profile.profileId = 1
        profile.name = "Test User"
        profile.email = "test@example.com"
        profile.phone = "+91 1234567890"
        profile.city = "Mumbai"
        profile.company = "Test Corp"
        profile.matchStatus = MatchStatus.pending.rawValue
        profile.syncPending = false
        
        #expect(profile.profileId == 1)
        #expect(profile.name == "Test User")
        #expect(profile.email == "test@example.com")
        #expect(profile.matchStatus == "pending")
    }
    
    @Test func testMatchProfileSaveAndFetch() throws {
        let container = CoreDataManagerTests.createInMemoryContainer()
        let context = container.viewContext
        
        // Create and save profile
        let profile = MatchProfile(context: context)
        profile.profileId = 42
        profile.name = "Saved User"
        profile.email = "saved@example.com"
        profile.matchStatus = MatchStatus.pending.rawValue
        
        try context.save()
        
        // Fetch profile
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        request.predicate = NSPredicate(format: "profileId == %lld", 42)
        
        let results = try context.fetch(request)
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Saved User")
        #expect(results.first?.email == "saved@example.com")
    }
    
    @Test func testMatchProfileUpdate() throws {
        let container = CoreDataManagerTests.createInMemoryContainer()
        let context = container.viewContext
        
        // Create profile
        let profile = MatchProfile(context: context)
        profile.profileId = 1
        profile.name = "Original Name"
        profile.matchStatus = MatchStatus.pending.rawValue
        
        try context.save()
        
        // Update profile
        profile.name = "Updated Name"
        profile.matchStatus = MatchStatus.accepted.rawValue
        
        try context.save()
        
        // Fetch and verify
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        request.predicate = NSPredicate(format: "profileId == %lld", 1)
        
        let results = try context.fetch(request)
        
        #expect(results.first?.name == "Updated Name")
        #expect(results.first?.matchStatus == "accepted")
    }
    
    @Test func testMatchProfileDelete() throws {
        let container = CoreDataManagerTests.createInMemoryContainer()
        let context = container.viewContext
        
        // Create profile
        let profile = MatchProfile(context: context)
        profile.profileId = 1
        profile.name = "To Delete"
        
        try context.save()
        
        // Delete profile
        context.delete(profile)
        try context.save()
        
        // Verify deletion
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        let results = try context.fetch(request)
        
        #expect(results.isEmpty)
    }
    
    @Test func testMultipleProfilesFetch() throws {
        let container = CoreDataManagerTests.createInMemoryContainer()
        let context = container.viewContext
        
        // Create multiple profiles
        for i in 1...5 {
            let profile = MatchProfile(context: context)
            profile.profileId = Int64(i)
            profile.name = "User \(i)"
            profile.matchStatus = MatchStatus.pending.rawValue
        }
        
        try context.save()
        
        // Fetch all
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "profileId", ascending: true)]
        
        let results = try context.fetch(request)
        
        #expect(results.count == 5)
        #expect(results[0].name == "User 1")
        #expect(results[4].name == "User 5")
    }
    
    @Test func testSyncPendingFilter() throws {
        let container = CoreDataManagerTests.createInMemoryContainer()
        let context = container.viewContext
        
        // Create profiles with different sync states
        let profile1 = MatchProfile(context: context)
        profile1.profileId = 1
        profile1.name = "Synced User"
        profile1.syncPending = false
        
        let profile2 = MatchProfile(context: context)
        profile2.profileId = 2
        profile2.name = "Pending Sync User"
        profile2.syncPending = true
        
        let profile3 = MatchProfile(context: context)
        profile3.profileId = 3
        profile3.name = "Another Pending"
        profile3.syncPending = true
        
        try context.save()
        
        // Fetch only pending sync profiles
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        request.predicate = NSPredicate(format: "syncPending == YES")
        
        let results = try context.fetch(request)
        
        #expect(results.count == 2)
    }
    
    @Test func testMatchStatusFilter() throws {
        let container = CoreDataManagerTests.createInMemoryContainer()
        let context = container.viewContext
        
        // Create profiles with different statuses
        let profile1 = MatchProfile(context: context)
        profile1.profileId = 1
        profile1.matchStatus = MatchStatus.pending.rawValue
        
        let profile2 = MatchProfile(context: context)
        profile2.profileId = 2
        profile2.matchStatus = MatchStatus.accepted.rawValue
        
        let profile3 = MatchProfile(context: context)
        profile3.profileId = 3
        profile3.matchStatus = MatchStatus.declined.rawValue
        
        let profile4 = MatchProfile(context: context)
        profile4.profileId = 4
        profile4.matchStatus = MatchStatus.accepted.rawValue
        
        try context.save()
        
        // Fetch accepted profiles
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        request.predicate = NSPredicate(format: "matchStatus == %@", MatchStatus.accepted.rawValue)
        
        let results = try context.fetch(request)
        
        #expect(results.count == 2)
    }
}
