//
//  MemberListLazyLoader.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/27/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData
import AlamofireImage
import UIKit


class MemberListLazyLoader {

    let serialLoaderQueue = DispatchQueue(label: "com.slacklist.MemberListLazyLoader", qos: .userInitiated)
    let userListService = UserListService(limit: 100, presence: false)
    let downloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(),
                                     downloadPrioritization: .fifo,
                                     maximumActiveDownloads: 4,
                                     imageCache: AutoPurgingImageCache())
    
    fileprivate var mocSyncCoordinator: () -> MOCSyncCoordinator? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.mocSyncCoordinator
    }
    
    func syncUserList() {
        guard
            let moc = mocSyncCoordinator()?.backgroundQueueManagedObjectContext,
            let mainMOC = mocSyncCoordinator()?.mainQueueManagedObjectContext else {
            return
        }
        
        var cursor = ""
        
        if let cursorModel = CursorModel.fetchCursorModel(inContext: mainMOC), let latestCursor = cursorModel.latestCursor {
            // model exists
            cursor = latestCursor
            // We reached the end of the user list, there is nothing to fetch
            if cursor.isEmpty { return }
        }
        
        self.serialLoaderQueue.async { [weak self] in
            self?.userListService.run(cursor: cursor ) { result in
                guard result.error == nil, let members = result.object?.0 else {
                    return
                }
                
                moc.perform {
                    members.forEach { member in
                        if let memberModel = MemberModel.createOrUpdate(inContext: moc, member: member) {
                            ProfileModel.createOrUpdate(inContext: moc, profile: member.profile, memberModel: memberModel)
                        }
                        // Cache all the images immediately
                        let urlRequest = URLRequest(url: URL(string: member.profile.imageUrl)!, cachePolicy: .returnCacheDataElseLoad)
                        self?.downloader.download(urlRequest) { _ in }
                    }
                    
                    
                    if let newCursor = result.object?.1, let cursorModel = CursorModel.create(inContext: moc) {
                        cursorModel.latestCursor = newCursor
                        
                        if !newCursor.isEmpty {
                            DispatchQueue.main.async {
                                // Recursively Page through rest of the user list
                                self?.syncUserList()
                            }
                        }
                    }
                    
                    moc.saveOrRollback()
                }
            }
        }
    }
}
