//
//  CursorModel.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/27/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData

class CursorModel: ManagedObject {
    @NSManaged var latestCursor: String?
    
    static func fetchCursorModel(inContext moc: NSManagedObjectContext) -> CursorModel? {
        let models = CursorModel.fetch(inContext: moc)
        if let first = models.first {
            return first
        }
        
        return nil
    }
    
    static func create(inContext moc: NSManagedObjectContext) -> CursorModel? {
        if let model = CursorModel.fetchCursorModel(inContext: moc) {
            return model
        } else {
            let cursorModel: CursorModel? = moc.insertObject()
            return cursorModel
        }
    }
}

extension CursorModel: ManagedObjectType {
    static var entityName: String {
        return "CursorModel"
    }
    
    static var defaultSortDescriptors: [NSSortDescriptor]? {
        return nil
    }
    
    static var defaultPredicate: NSPredicate? {
        return nil
    }
}

extension CursorModel: KeyCodable {
    public enum Keys: String {
        case latestCursor
    }
}
