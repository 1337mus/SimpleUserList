//
//  NSManagedObjectContext+Extension.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    private var store: NSPersistentStore? {
        guard let psc = persistentStoreCoordinator else {
            assertionFailure("PSC missing")
            return nil
        }
        guard let store = psc.persistentStores.first else {
            assertionFailure("No Store")
            return nil
        }
        return store
    }
    
    public convenience init(concurrencyType: NSManagedObjectContextConcurrencyType,
                            bundlesForSourceModel: [Bundle]?,
                            storeType: String = NSInMemoryStoreType,
                            storeURL: URL? = nil) throws {
        self.init(concurrencyType: concurrencyType)
        try persistentStoreCoordinator = createPersistentStoreCoordinator(bundlesForSourceModel,
                                                                          storeType: storeType,
                                                                          storeURL: storeURL)
    }
    
    private func createPersistentStoreCoordinator(_ bundlesForSourceModel: [Bundle]?,
                                                  storeType: String = NSInMemoryStoreType,
                                                  storeURL: URL? = nil) throws -> NSPersistentStoreCoordinator {
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: bundlesForSourceModel) else {
            let message = "Managed object model not found"
            assertionFailure(message)
            throw message
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let options = NSManagedObjectContext.optionsForPersistentStoreWithAutomaticMigrationSupport()
        try psc.addPersistentStore(ofType: storeType, configurationName: nil, at: storeURL, options: options)
        
        return psc
    }
    
    private static func optionsForPersistentStoreWithAutomaticMigrationSupport() -> [AnyHashable: Any]? {
        // Use automatic migration
        return [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
    }
    
    public static func destroyPersistentStore(_ bundlesForSourceModel: [Bundle]?,
                                              storeURL: URL,
                                              storeType: String = NSInMemoryStoreType) -> Bool {
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: bundlesForSourceModel) else {
            assertionFailure("Managed object model not found")
            return false
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let options = optionsForPersistentStoreWithAutomaticMigrationSupport()
        do {
            try psc.destroyPersistentStore(at: storeURL, ofType: storeType, options: options)
            return true
        } catch let error as NSError {
            debugPrint("destroyPersistentStoreAtURL > handled error : ", error, error.userInfo)
        }
        return false
    }
    
    public func insertObject<A: ManagedObject>() -> A? where A: ManagedObjectType {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            assertionFailure("Wrong object type")
            return nil
        }
        return obj
    }
    
    public func createBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    @discardableResult
    public func saveOrRollback() -> Bool {
        do {
            if hasChanges {
                try save()
            }
            return true
        } catch let error as NSError {
            debugPrint("MOC save failed : \(error), \(error.userInfo)")
            rollback()
            return false
        }
    }
}

extension String: Error {
    public var errorDescription: String? { return self }
}
