//
//  ProfilesTableViewController.swift
//  prfls
//
//  Created by Branko Popovic on 9/28/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import UIKit

class ProfilesTableViewController: UITableViewController, ProfilesViewModelDelegate {
    
    private var profilesVM = ProfilesViewModel()
    private var loadingPage = false
    private var dataSrc: UITableViewDiffableDataSource<Sections, Profile>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibProfile = UINib(nibName: "ProfileCellView", bundle: .main)
        let nibLoading = UINib(nibName: "LoadingCellView", bundle: .main)
        tableView.register(nibProfile, forCellReuseIdentifier: "profileCell")
        tableView.register(nibLoading, forCellReuseIdentifier: "loadingCell")
        dataSrc = setupDataSource()
        profilesVM.delegate = self
    }
    
    // MARK: tableView delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "profileDetailsSegue", sender: indexPath.row)
    }
    
    // MARK: segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileDetailsVC = segue.destination as? ProfileDetailsViewController {
            profileDetailsVC.detailsRow = sender as? Int
        }
    }
    
    // MARK: Scroll view delegata
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        // detecting if tableView is scrolled to bottom
        // initialy it is and first loading starts here as well as every next one
        if offsetY > contentHeight - scrollView.frame.height {
            if !loadingPage {
                startLoadingPage()
            }
        }
    }
    
    func startLoadingPage() {
        loadingPage = true
        // empty profile for loading section
        let loadingProfile = Profile()
        handle(profiles: profilesVM.profiles!, loadingProfile: loadingProfile)
        profilesVM.loadNextProfileBatch()
    }
    
    // MARK: ProfilesViewModelDelegate implementation
    func didFetchProfiles(profileViewModel profileVM: ProfilesViewModel?, withSuccess success: Bool) {
        loadingPage = false
        handle(profiles: profileVM!.profiles!)
    }
}

// MARK: Diffable data source

extension ProfilesTableViewController {
    
    func handle(profiles: [Profile], loadingProfile: Profile? = nil) {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Sections, Profile>()
        
        let sect: [Sections] = [.profile, .loader]
        currentSnapshot.appendSections(sect)
        currentSnapshot.appendItems(profiles, toSection: .profile)
        if let lp = loadingProfile {
            currentSnapshot.appendItems([lp], toSection: .loader)
        }
        
        dataSrc?.apply(currentSnapshot, animatingDifferences: false, completion: nil)
    }
    
    func setupDataSource() -> UITableViewDiffableDataSource<Sections, Profile> {
        let dataSource = UITableViewDiffableDataSource<Sections, Profile>(tableView: tableView) {[weak self] (tableView, indexPath, profile) -> UITableViewCell? in
            if indexPath.section == 0 {
                //setup profile cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell
                let row = indexPath.row
                
                self?.setupProfileData(forCell: cell, atRow: row)
                
                return cell
            }
            else {
                // setup activity view
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingTableViewCell
                cell.activityIndicator.startAnimating()
                return cell
            }
        }
        return dataSource
    }
    
    func setupProfileData(forCell cell: ProfileTableViewCell, atRow row: Int) {
        cell.firstNameLabel.text = self.profilesVM.firstNameAtRow(row: row)
        cell.lastNameLabel.text = self.profilesVM.lastNameAtRow(row: row)
        cell.ageLabel.text = self.profilesVM.ageAtRow(row: row)
        cell.countryLabel.text = self.profilesVM.natFlagAtRow(row: row)
        self.profilesVM.loadThumbnailAtRow(row: row) { (data) in
            guard let data = data else {
                return
            }
            let img = UIImage(data: data)
            cell.profileImageView.image = img
        }
    }
}
