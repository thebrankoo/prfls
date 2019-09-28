//
//  DetailsView.swift
//  prfls
//
//  Created by Branko Popovic on 9/28/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import Foundation
import UIKit

protocol DetailsViewProtocol: class {
    func didTapDetailsView(detailsView: DetailsView)
}

enum DetailsViewType: String {
    case firstName = "First name"
    case lastName = "Last name"
    case age = "Age"
    case email = "Email"
    case nat = "From"
}

class DetailsView: UIView {
    let typeLabel: UILabel
    let valueLabel: UILabel
    var type: DetailsViewType
    
    weak var delegate: DetailsViewProtocol?
    
    init(value: String?, type: DetailsViewType, delegate: DetailsViewProtocol? = nil) {
        typeLabel = UILabel()
        valueLabel = UILabel()
        valueLabel.text = value
        typeLabel.text = type.rawValue
        self.type = type
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
        addTapDetector()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View setup
    
    func setupView() {
        typeLabel.textColor = .lightGray
        valueLabel.textColor = .black
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(typeLabel)
        addSubview(valueLabel)
        addConstraints()
    }
    
    func addConstraints() {
        let dict = ["typeLabel": typeLabel,
                    "valueLabel": valueLabel]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[typeLabel]-(5)-[valueLabel]", options: [], metrics: nil, views: dict)
        let horizontalTypeConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[typeLabel]", options: [], metrics: nil, views: dict)
        let horizontalValueConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[valueLabel]", options: [], metrics: nil, views: dict)
        addConstraints(verticalConstraints+horizontalTypeConstraints+horizontalValueConstraints)
        layoutIfNeeded()
    }
    
    // MARK: Tap detector
    
    func addTapDetector() {
        isUserInteractionEnabled = true
        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        gestureTap.numberOfTapsRequired = 1
        gestureTap.numberOfTouchesRequired = 1
        addGestureRecognizer(gestureTap)
    }
    
    @objc func didTap(_ sender: UITapGestureRecognizer? = nil) {
        delegate?.didTapDetailsView(detailsView: self)
    }
}
