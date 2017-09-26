//
//  ViewController.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/26/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import UIKit

class MemberListViewController: UITableViewController {

    var viewModel: MemberListViewModel?
    
    fileprivate var mocSyncCoordinator: () -> MOCSyncCoordinator? = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.mocSyncCoordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        viewModel?.startUpdating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel?.stopUpdating()
    }
    
    private func setupViewModel() {
        let fetchBatchSize = Int(tableView.bounds.size.height / tableView.rowHeight * 2)
        viewModel = MemberListViewModel(delegate: self, fetchBatchSize: fetchBatchSize)
    }
}

extension MemberListViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MemberVCToProfileVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let itemModel = viewModel?.getItemModel(at: indexPath) as? MemberModel, let profileModel = itemModel.profileModel else {
            return
        }
        
        let profileDataSource = ProfileViewDataSource(imageUrl: profileModel.imageUrl,
                                                      userName: itemModel.userName,
                                                      realName: profileModel.realName,
                                                      title: profileModel.title ?? "")
        
        if let profileVC = segue.destination as? ProfileViewController {
            profileVC.profileViewDataSource = profileDataSource
        }
    }
}

extension MemberListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        
        return viewModel.numberOfItems(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MemberListTableViewCell", for: indexPath) as? MemberListTableViewCell,
            let itemModel = viewModel?.getItemModel(at: indexPath) {
        
            cell.dataSource = itemModel
        }
        
        return UITableViewCell()
    }
}

extension MemberListViewController: MemberListViewModelDelegate {
    func memberListViewModelDidReload(_ viewModel: MemberListViewModel) {
        tableView.reloadData()
    }
    
    func memberListViewModel(_ myMusicViewModel: MemberListViewModel, didUpdateSection section: Int, withFetchedResultsChanges changes: [FetchedResultsChange]) {
        CATransaction.begin()
        tableView.beginUpdates()
        changes.forEach {
            processIndividualResultChange($0)
        }
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    func processIndividualResultChange(_ change: FetchedResultsChange, animation: UITableViewRowAnimation = .fade) {
        switch change.changeType {
        case .insert:
            if let indexPath = change.newIndexPath {
                tableView.insertRows(at: [indexPath], with: animation)
            }
        case .delete:
            if let indexPath = change.indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }

        case .update:
            if let indexPath = change.indexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        case .move:
            if let indexPath = change.indexPath,
                let newIndexPath = change.newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        }
    }

}

