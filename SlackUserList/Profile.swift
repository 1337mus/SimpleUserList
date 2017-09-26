//
//  Profile.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation

struct Profile {
    let imageUrl: String
    let realName: String
    let title: String?
    
    static func fromJSON(json: [String: AnyObject]) -> Profile? {
        guard
            let imageUrl = json["image_original"] as? String,
            let realName = json["real_name"] as? String
        else {
                return nil
        }
        
        let title = json["title"] as? String
        
        return Profile(imageUrl: imageUrl, realName: realName, title: title)
    }
}
