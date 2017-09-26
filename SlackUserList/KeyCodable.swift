//
//  KeyCodable.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import CoreData

public protocol KeyCodable {
    associatedtype Keys: RawRepresentable
}

extension KeyCodable where Self: ManagedObject, Keys.RawValue == String {
    public func willAccessValueForKey(_ key: Keys) {
        willAccessValue(forKey: key.rawValue)
    }
    
    public func didAccessValueForKey(_ key: Keys) {
        didAccessValue(forKey: key.rawValue)
    }
    
    public func willChangeValueForKey(_ key: Keys) {
        (self as ManagedObject).willChangeValue(forKey: key.rawValue)
    }
    
    public func didChangeValueForKey(_ key: Keys) {
        (self as ManagedObject).didChangeValue(forKey: key.rawValue)
    }
    
    public func valueForKey(_ key: Keys) -> AnyObject? {
        return (self as ManagedObject).value(forKey: key.rawValue) as AnyObject
    }
    
    public func mutableSetValueForKey(_ key: Keys) -> NSMutableSet {
        return mutableSetValue(forKey: key.rawValue)
    }
    
    public func changedValueForKey(_ key: Keys) -> AnyObject? {
        return changedValues()[key.rawValue] as AnyObject
    }
    
    public func committedValueForKey(_ key: Keys) -> AnyObject? {
        return committedValues(forKeys: [key.rawValue])[key.rawValue] as AnyObject
    }
}
