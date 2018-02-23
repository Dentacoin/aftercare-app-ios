//
// Aftercare
// Created by Dimitar Grudev on 15.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit

class TutorialView: ReusableXibView {
    
    typealias Tutorial = (title: String, description: String, image: String)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - public vars
    
    var tutorialData: Tutorial? {
        didSet {
            updateContent()
        }
    }
    
    // MARK: - Internal
    
    fileprivate func updateContent() {
        
        guard let data = self.tutorialData else {
            return
        }
        
        backgroundImage.image = ThemeManager.shared.tutorialBackgroundTexture
        
        tutorialImage.image = UIImage(named: data.image)
        
        titleLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntTitleFontSize)
        titleLabel.text = data.title
        
        descriptionLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        descriptionLabel.text = data.description
        
    }
    
    override class func nibName() -> String {
        return String(describing: self)
    }
    
}
