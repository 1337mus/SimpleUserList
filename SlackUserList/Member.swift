//
//  User.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation

struct Member {
    let id: String
    let teamId: String
    let userName: String
    let thumbnailUrl: String
    let deleted: Bool
    
    let profile: Profile
    
    static func fromJSON(json: [String: AnyObject]) -> Member? {
        guard
            let id = json["id"] as? String,
            let teamId = json["team_id"] as? String,
            let userName = json["name"] as? String,
            let deleted = json["deleted"] as? Bool,
            let profileHash = json["profile"] as? [String: AnyObject],
            let thumbnailUrl = profileHash["image_48"] as? String,
            let profile = Profile.fromJSON(json: profileHash)
        else {
                return nil
        }
        
        return Member(id: id, teamId: teamId, userName: userName, thumbnailUrl: thumbnailUrl, deleted: deleted, profile: profile)
    }

}
