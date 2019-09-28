//
//  ProfileTableViewCell.swift
//  prfls
//
//  Created by Branko Popovic on 9/28/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    override func prepareForReuse() {
        firstNameLabel.text = ""
        lastNameLabel.text = ""
        ageLabel.text = ""
        countryLabel.text = ""
    }
}
