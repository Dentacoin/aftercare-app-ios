//
// Aftercare
// Created by Dimitar Grudev on 16.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit
import Alamofire
import AlamofireImage

class CaptchaView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var timerBar: UIView!
    @IBOutlet weak var timerTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - public
    
    var data: CaptchaData?
    
    // MARK: - Fileprivate
    
    fileprivate let CAPTCHA_INVALIDATION_TIME: CGFloat = 180//seconds
    
    fileprivate var state: CaptchaState = .invalid
    fileprivate var timerStep: CGFloat = 0
    fileprivate var invalidationAfter: CGFloat = 0//seconds
    fileprivate var timer: Timer?
    
    // MARK: - Lifecycle
    
    fileprivate var contentView: UIView?
    
    fileprivate var nibName: String {
        return String(describing: type(of: self))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView?.frame = self.frame
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Internal
    
    fileprivate func setup() {
        
        guard let view = loadViewFromNib() else { return }
        addSubview(view)
        contentView = view
        contentView?.translatesAutoresizingMaskIntoConstraints = false
        contentView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView?.backgroundColor = .clear
        
        if state == .invalid {
            requestNewCaptcha()
        }
    }
    
    fileprivate func loadViewFromNib() -> UIView? {
        let bundle = Bundle(identifier: nibName)
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    fileprivate func requestNewCaptcha() {
        
        state = .requested
        
        APIProvider.requestCaptcha() { [weak self] data, error in
            
            if let error = error {
                let nserror = error.toNSError()
                print("Error: CaptchaView : \(nserror.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error: CaptchaView : Invalid Captcha Data")
                return
            }
            
            self?.data = data
            
            var captchaImage = UIImage()
            captchaImage = captchaImage.decodeBase64(toImage: data.imageBase64)
            guard let resizedCaptcha = captchaImage.resize(toSize: (self?.frame.size)!) else {
                print("Error: CaptchaView : Failed to resize captcha")
                return
            }
            self?.image.image = resizedCaptcha
            
            //Start invalidation timer
            self?.startTimer()
            
        }
        
    }
    
    fileprivate func startTimer() {
        
        invalidationAfter = CAPTCHA_INVALIDATION_TIME
        timerStep = self.frame.width / CAPTCHA_INVALIDATION_TIME
        timerTrailingConstraint.constant = self.frame.width
        
        if timer == nil {
            timer = Timer.scheduledTimer(
                timeInterval: 1.0,
                target: self,
                selector: Selector.updateTimerSelector,
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    fileprivate func stopTimer() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    @objc fileprivate func updateTimer() {
        
        invalidationAfter -= 1
        timerTrailingConstraint.constant = (timerStep * invalidationAfter) * -1
        print("timerStep: \(timerStep), invalidationAfter: \(invalidationAfter), const: \(timerTrailingConstraint.constant)")
        print("Captcha Invalidation update :: time left \(invalidationAfter) seconds")
        
        if invalidationAfter <= 0 {
            state = .invalid
            stopTimer()
            requestNewCaptcha()
            timerTrailingConstraint.constant = self.image.frame.width
            print("Captcha Invalidation update :: current captcha is invalid, new captcha requested...")
        }
    }
    
    fileprivate enum CaptchaState: String {
        case requested
        case valid
        case invalid
    }
}

//MARK: - Selectors

fileprivate extension Selector {
    static let updateTimerSelector = #selector(CaptchaView.updateTimer)
}
