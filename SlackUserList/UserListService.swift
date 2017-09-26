//
//  UserListService.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import Alamofire


typealias UserListResponse = ([Member], String)
typealias UserListCompletion = (ServiceResult<UserListResponse>) -> Void
class UserListService: BaseService {
    
    let limit: Int
    let presence: Bool
    let token = "xoxp-4698769766-4698769768-207575117078-a8af5e682874670da978f7a7cf280015"
    
    init(limit: Int, presence: Bool) {
        self.limit = limit
        self.presence = presence
        
        super.init()
    }
    
    func run(cursor: String, completion: @escaping UserListCompletion) {
        requestJSON("/users.list?token=xoxp-4698769766-4698769768-207575117078-a8af5e682874670da978f7a7cf280015", method: .post, parameters: ["limit": limit, "cursor": cursor, "presence": presence]) { isSuccess, value, error in
            guard
                error == nil,
                let jsonDict = value as? [String: AnyObject], let memberJSON = jsonDict["members"] as? [[String: AnyObject]] else {
                completion(ServiceResult<UserListResponse>(object: nil, error: error))
                return
            }
            
            var cur = ""
            
            if let metaData = jsonDict["response_metadata"] as? [String: AnyObject], let c = metaData["next_cursor"] as? String  {
                cur = c
            }
            
            let members = memberJSON.flatMap { Member.fromJSON(json: $0) }
            
            completion(ServiceResult<UserListResponse>(object: (members, cur), error: nil))
        }
    }
}
