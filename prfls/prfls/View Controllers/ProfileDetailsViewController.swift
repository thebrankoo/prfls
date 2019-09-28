//
//  ProfileDetailsViewController.swift
//  prfls
//
//  Created by Branko Popovic on 9/28/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import UIKit

class ProfileDetailsViewController: UIViewController, DetailsViewProtocol {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileInfoStack: UIStackView!
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!
    var detailsRow: Int?
    private var profileDetailsVM: ProfileDetailsViewModel?
    private var detailsViewes: [DetailsView] = [DetailsView]()
    
    private let detailsViewHeight: CGFloat = 55.0
    private let stackItemSpacing: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModel()
        populateProfileImage()
        setupDetailsStack()
    }
    
    func createViewModel() {
        if let detailsRow = detailsRow {
            profileDetailsVM = ProfileDetailsViewModel(withProfileIndex: detailsRow)
        }
    }
    
    //MARK: Profile image fetch
    
    func populateProfileImage() {
        profileDetailsVM?.loadLargeImage(completion: { [weak self] (data) in
            if let data = data {
                let img = UIImage(data: data)
                self?.profileImageView.image = img
            }
        })
    }
    
    //MARK: Stack view setup
    
    func setupDetailsStack() {
        createDetailsViews()
        populateStackView()
        setupStackView()
    }
    
    func createDetailsViews() {
        let firstNameView = DetailsView(value: profileDetailsVM?.firstName, type: .firstName)
        let lastNameView = DetailsView(value: profileDetailsVM?.lastName, type: .lastName)
        let emailView = DetailsView(value: profileDetailsVM?.email, type: .email, delegate: self)
        let ageView = DetailsView(value: profileDetailsVM?.age, type: .age)
        
        detailsViewes.append(firstNameView)
        detailsViewes.append(lastNameView)
        detailsViewes.append(emailView)
        detailsViewes.append(ageView)
    }
    
    func populateStackView() {
        detailsViewes.forEach { (detialsView) in
            profileInfoStack.addArrangedSubview(detialsView)
        }
    }
    
    func setupStackView() {
        profileInfoStack.spacing = stackItemSpacing
        
        let subviewCount = CGFloat(profileInfoStack.arrangedSubviews.count)
        
        let h1 = subviewCount * detailsViewHeight
        let h2 = (subviewCount - 1) * stackItemSpacing
        stackHeightConstraint.constant = CGFloat(h1+h2)
    }
    
    // MARK: Details view protocl
    
    func didTapDetailsView(detailsView: DetailsView) {
        profileDetailsVM?.selectedDetails(withType: detailsView.type)
    }
}
