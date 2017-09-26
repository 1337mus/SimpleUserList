//
//  ProfileModel.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData

class ProfileModel: ManagedObject {
    static func findOrCreate(inContext moc: NSManagedObjectContext, profile: Profile, memberModel: MemberModel) -> ProfileModel? {
        let matchingPredicate = predicate(memberModel: memberModel)
        return findOrCreate(inContext: moc, matchingPredicate: matchingPredicate, configure: {
            $0.imageUrl = profile.imageUrl
            $0.title = profile.title
            $0.realName = profile.realName
            $0.memberModel = memberModel
        })
    }
    
    @discardableResult
    static func createOrUpdate(inContext moc: NSManagedObjectContext, profile: Profile, memberModel: MemberModel) -> ProfileModel? {
        guard let memberModel = ProfileModel.findOrCreate(inContext: moc, profile: profile, memberModel: memberModel) else { return nil }
        
        return memberModel
    }
}

extension ProfileModel {
    @NSManaged var imageUrl: String?
    @NSManaged var title: String?
    @NSManaged var realName: String
    @NSManaged var memberModel: MemberModel
}

extension ProfileModel: ManagedObjectType {
    static var entityName: String {
        return "ProfileModel"
    }
    
    static var defaultSortDescriptors: [NSSortDescriptor]? {
        return [sortDescriptorForName(ascending: true)]
    }
    
    static var defaultPredicate: NSPredicate? {
        return nil
    }
}

extension ProfileModel: KeyCodable {
    public enum Keys: String {
        case title
        case imageUrl
        case realName
        case memberModel
    }
}

extension ProfileModel {
    static func sortDescriptorForName(ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: Keys.realName.rawValue, ascending: ascending)
    }
    
    static func predicate(memberModel: MemberModel) -> NSPredicate {
        return NSPredicate(format: "%K == %@", Keys.memberModel.rawValue)
    }
}
