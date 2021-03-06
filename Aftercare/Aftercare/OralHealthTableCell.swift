//
//  OralHealthTableViewCell.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 5.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class OralHealthTableCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setup(_ data: OralHealthData) {
        
        if let url = URL(string: data.imageURL ?? "") {
            backgroundImage.af_setImage(withURL: url)
        }
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntHeaderTitleFontSize)
        titleLabel.text = data.title
        
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntNormalTextSize)
        if let description = data.description {
            descriptionLabel.text = description
        }
        
        shadeView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.layoutIfNeeded()
    }
    
}
