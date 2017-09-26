//
//  MemberModel.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData

class MemberModel: ManagedObject {
    static func findOrCreate(inContext moc: NSManagedObjectContext, member: Member) -> MemberModel? {
        let matchingPredicate = predicate(memberId: member.id)
        return findOrCreate(inContext: moc, matchingPredicate: matchingPredicate, configure: {
            $0.memberId = member.id
            $0.teamId = member.teamId
            $0.userName = member.userName
            $0.thumbnailUrl = member.thumbnailUrl
            $0.memberDeleted = member.deleted
        })
    }
    
    static func createOrUpdate(inContext moc: NSManagedObjectContext, member: Member) -> MemberModel? {
        guard let memberModel = MemberModel.findOrCreate(inContext: moc, member: member) else { return nil }
        memberModel.update(member: member)
        return memberModel
    }
    
    private func update(member: Member) {
        userName = member.userName
        thumbnailUrl = member.thumbnailUrl
        memberDeleted = member.deleted
    }
    
    static func findOrFetch(inContext moc: NSManagedObjectContext, memberId: String) -> MemberModel? {
        return fetch(inContext: moc) { fetchRequest in
            fetchRequest.predicate = MemberModel.predicate(memberId: memberId)
            fetchRequest.fetchLimit = 1
        }.first
    }
}

extension MemberModel {
    @NSManaged public var teamId: String
    @NSManaged public var memberId: String
    @NSManaged public var userName: String
    @NSManaged public var thumbnailUrl: String
    @NSManaged public var memberDeleted: Bool
    @NSManaged public var profileModel: ProfileModel?
}

extension MemberModel: ManagedObjectType {
    static var entityName: String {
        return "MemberModel"
    }
    
    static var defaultSortDescriptors: [NSSortDescriptor]? {
        return [sortDescriptorForCanonicalName(ascending: true)]
    }
    
    static var defaultPredicate: NSPredicate? {
        return nil
    }
}

extension MemberModel: KeyCodable {
    public enum Keys: String {
        case memberId
        case teamId
        case userName
        case thumnbnailUrl
        case memberDeleted
        case profileModel
    }
}

extension MemberModel {
    static func sortDescriptorForCanonicalName(ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: Keys.userName.rawValue, ascending: ascending)
    }
    
    static func predicate(memberId: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", Keys.memberId.rawValue, memberId)
    }
}
