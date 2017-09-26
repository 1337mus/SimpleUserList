//
//  ImageTableViewCell.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/27/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import AlamofireImage
import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var realName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0 {
            // scrolling down
            containerView.clipsToBounds = true
            bottomSpaceConstraint?.constant = -scrollView.contentOffset.y / 2
            topSpaceConstraint?.constant = scrollView.contentOffset.y / 2
        } else {
            // scrolling up
            topSpaceConstraint?.constant = scrollView.contentOffset.y
            containerView.clipsToBounds = false
        }
    }
    
    var dataProvider: ProfileViewDataSource? {
        didSet {
            setProfileImage()
            userName.text = "@" + (dataProvider?.userName ?? "")
            realName.text = dataProvider?.realName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setProfileImage()
    }
    
    private func setProfileImage() {
        if let urlString = dataProvider?.imageUrl, let url = URL(string: urlString), profileImageView.image == nil {
            profileImageView.af_setImage(withURL: url)
            addOverlay()
        }
    }
    
    private func addOverlay() {
        let overlay = UIView()
        profileImageView.addSubview(overlay)
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        overlay.widthAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
    }
}
