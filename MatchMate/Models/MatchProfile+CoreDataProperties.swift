//
//  MatchProfile+CoreDataProperties.swift
//  MatchMate
//
//  Created by Indrajeet tripathi on 23/05/26.
//

import Foundation
import CoreData

extension MatchProfile {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchProfile> {
        return NSFetchRequest<MatchProfile>(entityName: "MatchProfile")
    }
    
    @NSManaged var address: String?
    @NSManaged var city: String?
    @NSManaged var company: String?
    @NSManaged var email: String?
    @NSManaged var imageURL: String?
    @NSManaged var matchStatus: String?
    @NSManaged var name: String?
    @NSManaged var phone: String?
    @NSManaged var profileId: Int64
    @NSManaged var syncPending: Bool
    @NSManaged var website: String?
}
