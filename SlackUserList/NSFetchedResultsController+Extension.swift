//
//  NSFetchedResultsController+Extension.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/27/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import CoreData

extension NSFetchedResultsController {
    public func deleteCacheAndPerformFetch () {
        if let cacheName = self.cacheName {
            NSFetchedResultsController.deleteCache(withName: cacheName)
        }
        do {
            try performFetch()
        } catch let error as NSError {
            assertionFailure("fetchedResultsController failed to perform fetch: \(error), \(error.userInfo)")
        }
    }
}
