//
//  MemberListTableViewCell.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/29/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import UIKit

class MemberListTableViewCell: UITableViewCell {
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    
    var dataSource: MemberListCellDataSource? {
        didSet {
            didSetDataSource()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func didSetDataSource() {
        if memberImageView.image == nil, let urlString = dataSource?.thumbnailUrl, let url = URL(string: urlString) {
           memberImageView.af_setImage(withURL: url)
        }
        
        memberNameLabel.text = dataSource?.name
    }
}
