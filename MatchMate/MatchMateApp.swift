//
//  MatchMateApp.swift
//  MatchMate
//
//  Created by Indrajeet tripathi  on 23/05/26.
//

import SwiftUI

@main
struct MatchMateApp: App {
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
        }
    }
}
