//
//  MOCSyncCoordinator.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData

class MOCSyncCoordinator: NSObject {
    let mainQueueManagedObjectContext: NSManagedObjectContext
    let backgroundQueueManagedObjectContext: NSManagedObjectContext
    let notification = NotificationCenter.default
    
    public init(bundlesForSourceModel: [Bundle]?,
                storeType: String = NSInMemoryStoreType,
                storeURL: URL? = nil) throws {
        mainQueueManagedObjectContext = try NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType,
            bundlesForSourceModel: bundlesForSourceModel,
            storeType: storeType,
            storeURL: storeURL)
        mainQueueManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        backgroundQueueManagedObjectContext = mainQueueManagedObjectContext.createBackgroundContext()
        super.init()
        setup()
    }
    
    func setup() {
        notification.addObserver(self, selector: #selector(MOCSyncCoordinator.mainQueueManagedObjectContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainQueueManagedObjectContext)
        notification.addObserver(self, selector: #selector(MOCSyncCoordinator.backgroundQueueManagedObjectContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundQueueManagedObjectContext)
    }
    
    func mainQueueManagedObjectContextDidSave(_ notification : Notification) {
        backgroundQueueManagedObjectContext.perform { [weak self] () -> Void in
            // Safeguard merging for background MOC since we are also writing on main thread
            if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
                updatedObjects.forEach({ (updatedObject) in
                    do {
                        try self?.backgroundQueueManagedObjectContext.existingObject(with: (updatedObject as AnyObject).objectID)
                    } catch let error as NSError {
                        debugPrint("Error when fetching object updated in private queue MOC : \(error), \(error.userInfo)")
                    }
                })
            }
            
            self?.backgroundQueueManagedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func backgroundQueueManagedObjectContextDidSave(_ notification : Notification) {
        mainQueueManagedObjectContext.perform { [weak self] () -> Void in
            // Due to a known bug described at http://mikeabdullah.net/merging-saved-changes-betwe.html ,
            // merged changes will not update faults, which match the predicate of a NSFetchedResultsController.
            // In order to these faulted objects to be updated,
            // we need to fulfill their fault by fetching them using existingObjectWithID before merging the changes.
            // This is a workaround recommended by Scott Perry, an Apple engineer in the Core Data team.
            if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
                updatedObjects.forEach({ (updatedObject) in
                    do {
                        try self?.mainQueueManagedObjectContext.existingObject(with: (updatedObject as AnyObject).objectID)
                    } catch let error as NSError {
                        debugPrint("Error when fetching object updated in private queue MOC : \(error), \(error.userInfo)")
                    }
                })
            }
            self?.mainQueueManagedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
    }

}
