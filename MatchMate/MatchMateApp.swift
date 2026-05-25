//
//  MatchMateApp.swift
//  MatchMate
//
//  Created by Indrajeet tripathi  on 23/05/26.
//

import SwiftUI
import CoreData

@main
struct MatchMateApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}

// MARK: - Persistence Controller (for SwiftUI Environment)
final class PersistenceController {
    static let shared = PersistenceController()
    
    var viewContext: NSManagedObjectContext {
        (CoreDataManager.shared as! CoreDataManager).viewContext
    }
}
