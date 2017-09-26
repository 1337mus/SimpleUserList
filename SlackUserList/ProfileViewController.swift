//
//  ProfileViewController.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/27/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import UIKit

enum ProfileViewRowType: Int {
    case profileImage
    case title
    case total
}

struct ProfileViewDataSource {
    var imageUrl: String?
    var userName: String
    var realName: String
    var title: String
}

class ProfileViewController: UITableViewController {
    
    var profileViewDataSource: ProfileViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransparentNavigationBar()
    }
    
    func setupTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let imageCell = tableView.cellForRow(at: IndexPath(row: ProfileViewRowType.profileImage.rawValue, section: 0)) as? ImageTableViewCell {
            imageCell.scrollViewDidScroll(scrollView)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == ProfileViewRowType.profileImage.rawValue {
            return UITableViewAutomaticDimension
        }
        
        return 60
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == ProfileViewRowType.profileImage.rawValue {
            return 300
        }
        
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileViewRowType.total.rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let row = ProfileViewRowType(rawValue: indexPath.row) else { return UITableViewCell() }
        
        switch row {
        case .profileImage:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageTableViewCell.self), for: indexPath) as? ImageTableViewCell {
                cell.dataProvider = profileViewDataSource
                return cell
            }
        case .title:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailsTableViewCell.self), for: indexPath) as? DetailsTableViewCell {
                cell.headerLabel.text = "Title"
                cell.detailsLabel.text = profileViewDataSource?.title
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
}
