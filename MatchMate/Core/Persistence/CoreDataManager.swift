//
//  CoreDataManager.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation
import CoreData

final class CoreDataManager: @unchecked Sendable {
    static let shared = CoreDataManager()
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "MatchMate")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Core Data error: \(error), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Match Profile Operations
    
    func fetchAllProfiles() -> [MatchProfile] {
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "profileId", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func fetchProfile(byId id: Int64) -> MatchProfile? {
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        request.predicate = NSPredicate(format: "profileId == %lld", id)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Fetch error: \(error)")
            return nil
        }
    }
    
    func saveOrUpdateProfile(from user: User) {
        let profile = fetchProfile(byId: Int64(user.id)) ?? MatchProfile(context: viewContext)
        
        profile.profileId = Int64(user.id)
        profile.name = user.name
        profile.email = user.email
        profile.phone = user.phone
        profile.website = user.website
        profile.company = user.company.name
        profile.city = user.address.city
        profile.address = "\(user.address.street), \(user.address.suite), \(user.address.city)"
        profile.imageURL = "https://randomuser.me/api/portraits/\(user.id % 2 == 0 ? "women" : "men")/\(user.id).jpg"
        
        if profile.matchStatus == nil {
            profile.matchStatus = MatchStatus.pending.rawValue
        }
        
        saveContext()
    }
    
    func updateMatchStatus(profileId: Int64, status: MatchStatus, syncPending: Bool = false) {
        guard let profile = fetchProfile(byId: profileId) else { return }
        
        profile.matchStatus = status.rawValue
        profile.syncPending = syncPending
        
        saveContext()
    }
    
    func fetchPendingSyncProfiles() -> [MatchProfile] {
        let request: NSFetchRequest<MatchProfile> = MatchProfile.fetchRequest()
        request.predicate = NSPredicate(format: "syncPending == YES")
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch pending sync error: \(error)")
            return []
        }
    }
    
    func markAsSynced(profileId: Int64) {
        guard let profile = fetchProfile(byId: profileId) else { return }
        profile.syncPending = false
        saveContext()
    }
    
    func deleteAllProfiles() {
        let request: NSFetchRequest<NSFetchRequestResult> = MatchProfile.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try viewContext.execute(deleteRequest)
            saveContext()
        } catch {
            print("Delete error: \(error)")
        }
    }
}
