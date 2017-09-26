//
//  MemberListCellDataSource.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import CoreData

protocol MemberListCellDataSource: class {
    // Add Additional Elements if required
    var name: String { get }
    var thumbnailUrl: String { get }
}

extension MemberModel: MemberListCellDataSource {
    var name: String {
        return "@" + userName
    }
}
