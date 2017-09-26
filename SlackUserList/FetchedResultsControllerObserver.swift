//
//  FetchedResultsControllerObserver.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData


public typealias FetchedResultsChange = (changeType: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)

public protocol FetchedResultsControllerObserverDelegate: class {
    func fetchedResultsControllerObserver(
        _ fetchedResultsControllerObserver: FetchedResultsControllerObserver,
        didChangeContentWithChanges changes: [FetchedResultsChange])
}

open class FetchedResultsControllerObserver: NSObject {
    
    weak var delegate: FetchedResultsControllerObserverDelegate?
    
    var pendingChanges: [FetchedResultsChange]?
    
    public init(delegate: FetchedResultsControllerObserverDelegate) {
        self.delegate = delegate
    }
}

extension FetchedResultsControllerObserver: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pendingChanges = []
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let changes = pendingChanges else { return }
        delegate?.fetchedResultsControllerObserver(self, didChangeContentWithChanges: changes)
        pendingChanges = nil
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .move && indexPath == newIndexPath {
            pendingChanges?.append(FetchedResultsChange(.update, indexPath, nil))
            return
        }
        pendingChanges?.append(FetchedResultsChange(type, indexPath, newIndexPath))
    }
}
