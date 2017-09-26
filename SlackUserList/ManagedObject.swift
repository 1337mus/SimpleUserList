//
//  ManagedObject.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData

public class ManagedObject: NSManagedObject {
    
}

public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor]? { get }
    static var defaultPredicate: NSPredicate? { get }
    var managedObjectContext: NSManagedObjectContext? { get }
    var managedObjectID: NSManagedObjectID { get }
}

extension ManagedObjectType {
    public static var defaultSortDescriptors: [NSSortDescriptor]? {
        return nil
    }
    
    public static var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest(entityName: entityName)
    }
    
    public static var sortedFetchRequest: NSFetchRequest<NSFetchRequestResult> {
        let request = fetchRequest
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }
    
    public static func predicate(withPredicate predicate: NSPredicate) -> NSPredicate {
        guard let defaultPredicate = defaultPredicate else { return predicate }
        return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
    }
}

extension ManagedObjectType where Self: ManagedObject {
    
    public var managedObjectID: NSManagedObjectID {
        return objectID
    }
    
    public static var entityName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last ?? ""
    }
    
    public static func insertNewObject(inContext moc: NSManagedObjectContext, configure: (Self) -> ()) -> Self? {
        
        if let newObject: Self = moc.insertObject() {
            configure(newObject)
            return newObject
        }
        return nil
    }
    
    public static func findOrCreate(inContext moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate, configure: (Self) -> ()) -> Self? {
        
        if let obj = findOrFetch(inContext: moc, matchingPredicate: predicate) {
            return obj
        }
        
        if let newObject: Self = moc.insertObject() {
            configure(newObject)
            return newObject
        }
        return nil
    }
    
    public static func findOrFetch(inContext moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        
        if let obj = materializedObject(inContext: moc, matchingPredicate: predicate) {
            return obj
        }
        
        let result = fetch(inContext: moc) { request in
            request.predicate = predicate
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 2
        }
        
        switch result.count {
        case 0: return nil
        case 1: return result.first
            
        default:
            assertionFailure("Returned multiple objects, expected max 1")
            return nil
        }
    }
    
    public static func fetch(inContext moc: NSManagedObjectContext, configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> () = { _ in }) -> [Self] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        configurationBlock(request)
        
        do {
            if let result = try moc.fetch(request) as? [Self] {
                return result
            } else {
                assertionFailure("Fetched objects have wrong type")
            }
        } catch let e as NSError {
            assertionFailure("Fetched objects have wrong type due to error: \(e)")
        }
        
        return []
    }
    
    public static func materializedObject(inContext moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        
        for (_ , obj) in moc.registeredObjects.enumerated() {
            guard let res = obj as? Self, !obj.isFault && predicate.evaluate(with: res) else { continue }
            return res
        }
        return nil
    }

}
