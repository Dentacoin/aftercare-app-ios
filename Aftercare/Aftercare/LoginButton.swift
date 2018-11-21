//
// Aftercare
// Created by Dimitar Grudev on 24.10.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit

class LoginButton: ReusableXibView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    // MARK: - public properties
    
    var type: LoginButtonType?
    
    // MARK: - delegate
    
    weak var delegate: LoginButtonDelegate?
    
    // MARK: - lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: - private logic
    
    fileprivate func setup() {
        self.backgroundColor = .clear
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let frame = self.frame
            if frame.contains(location) {
                delegate?.loginButtonPressed(self)
            }
        }
    }
    
    // MARK: - ReusableXibView
    
    override class func nibName() -> String {
        return String(describing: self)
    }
}

protocol LoginButtonDelegate: class {
    func loginButtonPressed(_ button: LoginButton)
}
