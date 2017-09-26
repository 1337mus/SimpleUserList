//
//  MemberListViewModel.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol MemberListViewModelDelegate: class {
    func memberListViewModelDidReload(_ viewModel: MemberListViewModel)
    func memberListViewModel(_ myMusicViewModel: MemberListViewModel, didUpdateSection section: Int, withFetchedResultsChanges changes: [FetchedResultsChange])
}

class MemberListViewModel: NSObject {
    let fetchBatchSize: Int
    weak var delegate: MemberListViewModelDelegate?
    
    fileprivate let fetchedResultsControllerCacheName = "MemberListCache"
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    fileprivate var fetchedResultsControllerObserver: FetchedResultsControllerObserver?
    
    fileprivate var mocSyncCoordinator: () -> MOCSyncCoordinator? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.mocSyncCoordinator
    }
    
    fileprivate lazy var lazyLoader = MemberListLazyLoader()
    
    init(delegate: MemberListViewModelDelegate, fetchBatchSize: Int) {
        self.fetchBatchSize = fetchBatchSize
        self.delegate = delegate
        
        super.init()
        
        self.fetchedResultsControllerObserver = FetchedResultsControllerObserver(delegate: self)
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        let sectionInfo = sections[0]
        return sectionInfo.numberOfObjects
    }
    
    func getItemModel(at indexPath: IndexPath) -> MemberListCellDataSource? {
        guard indexPath.item < numberOfItems(inSection: indexPath.section) else { return nil }
        
        guard let member = fetchedResultsController?.object(at: indexPath) as? MemberListCellDataSource else { return nil }
        return member
    }
    
    func startUpdating() {
        
        fetchedResultsController = createFetchedResultsController()
        fetchedResultsController?.deleteCacheAndPerformFetch()
        delegate?.memberListViewModelDidReload(self)
        
        lazyLoader.syncUserList()
    }
    
    func stopUpdating() {
        fetchedResultsController = nil
    }
    
    func isUpdating() -> Bool {
        return fetchedResultsController != nil
    }
    
    func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        
        guard let coordinator = mocSyncCoordinator() else { return nil }
        
        let fetchRequest = MemberModel.sortedFetchRequest
        fetchRequest.fetchBatchSize = fetchBatchSize
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coordinator.mainQueueManagedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: fetchedResultsControllerCacheName)
        fetchedResultsController.delegate = fetchedResultsControllerObserver
        
        return fetchedResultsController
    }
}

extension MemberListViewModel: FetchedResultsControllerObserverDelegate {
    
    func fetchedResultsControllerObserver(
        _ fetchedResultsControllerObserver: FetchedResultsControllerObserver,
        didChangeContentWithChanges changes: [FetchedResultsChange]) {
        if fetchedResultsControllerObserver == fetchedResultsControllerObserver {
            delegate?.memberListViewModel(self, didUpdateSection: 0, withFetchedResultsChanges: changes)
        }
    }
}
