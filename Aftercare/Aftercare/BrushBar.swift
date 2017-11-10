//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

@IBDesignable
class BrushBar: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var tooth01: UIButton!
    @IBOutlet weak var tooth02: UIButton!
    @IBOutlet weak var tooth03: UIButton!
    @IBOutlet weak var tooth04: UIButton!
    @IBOutlet weak var tooth05: UIButton!
    @IBOutlet weak var tooth06: UIButton!
    @IBOutlet weak var tooth07: UIButton!
    @IBOutlet weak var tooth08: UIButton!
    @IBOutlet weak var tooth09: UIButton!
    @IBOutlet weak var tooth10: UIButton!
    @IBOutlet weak var tooth11: UIButton!
    @IBOutlet weak var tooth12: UIButton!
    @IBOutlet weak var tooth13: UIButton!
    @IBOutlet weak var tooth14: UIButton!
    @IBOutlet weak var tooth15: UIButton!
    @IBOutlet weak var tooth16: UIButton!
    @IBOutlet weak var tooth17: UIButton!
    @IBOutlet weak var tooth18: UIButton!
    @IBOutlet weak var tooth19: UIButton!
    @IBOutlet weak var tooth20: UIButton!
    @IBOutlet weak var tooth21: UIButton!
    @IBOutlet weak var tooth22: UIButton!
    @IBOutlet weak var tooth23: UIButton!
    @IBOutlet weak var tooth24: UIButton!
    @IBOutlet weak var tooth25: UIButton!
    @IBOutlet weak var tooth26: UIButton!
    @IBOutlet weak var tooth27: UIButton!
    @IBOutlet weak var tooth28: UIButton!
    @IBOutlet weak var tooth29: UIButton!
    @IBOutlet weak var tooth30: UIButton!
    @IBOutlet weak var tooth31: UIButton!
    @IBOutlet weak var tooth32: UIButton!
    
    @IBOutlet weak var mouthContainer: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    //MARK: - fileprivate vars
    
    fileprivate var contentView : UIView?
    
    fileprivate var upperRightPart: [UIButton] = []
    fileprivate var downRightPart: [UIButton] = []
    fileprivate var downLeftPart: [UIButton] = []
    fileprivate var upperLeftPart: [UIButton] = []
    fileprivate var allTeeth: [UIButton] = []
    fileprivate var highlightedSection: [UIButton]?
    
    //MARK: - IBDesignable Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        customizeComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if self.subviews.count == 0 {
            setup()
        }
        return self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeComponents()
    }
    
    fileprivate func setup() {
        contentView = loadViewFromNib()
        contentView!.frame = bounds
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(contentView!)
    }
    
    fileprivate func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateLayouts()
    }
    
    //MARK: - Public api
    
    func highlightSection(_ section: BrushBarSections) {
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            if let highlighted = self?.highlightedSection {
                for tooth in highlighted {
                    tooth.alpha = 0
                }
            }
            
            let sectionToHighlight: [UIButton]?
            
            switch section {
                case .UpperRight:
                    sectionToHighlight = self?.upperRightPart
                case .DownRight:
                    sectionToHighlight = self?.downRightPart
                case .DownLeft:
                    sectionToHighlight = self?.downLeftPart
                case .UpperLeft:
                    sectionToHighlight = self?.upperLeftPart
                case .None:
                    sectionToHighlight = nil
                    self?.highlightedSection = nil
            }
            
            if let section = sectionToHighlight {
                for tooth in section {
                    tooth.alpha = 0.7
                }
                self?.highlightedSection = section
            }
        })
        
    }
    
    enum BrushBarSections {
        case UpperRight
        case DownRight
        case DownLeft
        case UpperLeft
        case None
    }
    
}

//MARK: - apply theme

extension BrushBar {
    
    fileprivate func customizeComponents() {
        
        upperRightPart = [tooth09, tooth10, tooth11, tooth12,
                          tooth13, tooth14, tooth15, tooth16]
        
        downRightPart = [tooth25, tooth26, tooth27, tooth28,
                         tooth29, tooth30, tooth31, tooth32]
        
        downLeftPart = [tooth17, tooth18, tooth19, tooth20,
                        tooth21, tooth22, tooth23, tooth24]
        
        upperLeftPart = [tooth01, tooth02, tooth03, tooth04,
                         tooth05, tooth06, tooth07, tooth08]
        
        allTeeth.append(contentsOf: upperLeftPart)
        allTeeth.append(contentsOf: upperRightPart)
        allTeeth.append(contentsOf: downLeftPart)
        allTeeth.append(contentsOf: downRightPart)
        
        //make all teeth transparent on start
        for tooth in allTeeth {
            tooth.alpha = 0
        }
        
        timerLabel.textColor = UIColor.dntCeruleanBlue
        timerLabel.font = UIFont.dntLatoLightFont(size: 40)
        timerLabel.text = "0:00"
        
        self.backgroundColor = .clear
        
    }
    
    fileprivate func calculateLayouts() {
        
        //Scale and position Mouth Container in the View
        
        let containerPadding: CGFloat = 8
        let screenRect = self.bounds
        let positionRectY = containerPadding
        let positionRectHeight = screenRect.height - (2 * containerPadding)
        
        let positionRect = CGRect(
            x: containerPadding,
            y: positionRectY,
            width: screenRect.size.width - (2 * containerPadding),
            height: positionRectHeight
        )
        
        let containerSize = mouthContainer.frame
        let widthScale: CGFloat = positionRect.width / containerSize.width
        let heightScale: CGFloat = positionRect.height / containerSize.height
        let scaleFactor = min(widthScale, heightScale)
        
        mouthContainer.transform = mouthContainer.transform.scaledBy(x: scaleFactor, y: scaleFactor)
        mouthContainer.frame.origin.x = positionRect.origin.x + ((positionRect.width - mouthContainer.frame.width) / 2)
        mouthContainer.frame.origin.y = positionRect.origin.y
        
    }

}
