//
//  UploadImageButton.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 3.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class UploadImageButton: UIButton {
    
    weak var delegate: UploadImageButtonDelegate?
    
    fileprivate var imagePicker = UIImagePickerController()
    var hasLoadedAvatar: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    fileprivate func config() {
        self.addTarget(self, action: Selector.onButtonPressed, for: .touchUpInside)
        let image = UIImage(named: ImageIDs.uploadAvatarIcon)
        self.setBackgroundImage(image, for: .normal)
        self.setTitle(nil, for: .normal)
        self.setImage(nil, for: .normal)
        self.layer.masksToBounds = true
    }
    
    //MARK: - Public API
    
    func setPlaceholderImage(_ image: UIImage) {
        self.hasLoadedAvatar = true
        self.setBackgroundImage(image, for: .normal)
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width / 2
    }
}

//MARK: - ImagePickerDelegate

extension UploadImageButton : UIImagePickerControllerDelegate {
    
    @objc func onButtonPressed() {
        showUploadImageOptions()
    }
    
    fileprivate func showUploadImageOptions() {
        
        let optionsMenuMessage = "profile_upload_avatar_option_title".localized()
        let optionCameraTitle = "profile_upload_avatar_option_1".localized()
        let optionLibraryTitle = "profile_upload_avatar_option_2".localized()
        let optionCancelTitle = "txt_cancel".localized()
        
        let optionMenu = UIAlertController(title: nil, message: optionsMenuMessage, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: optionCameraTitle, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePickerFor(sourceType: .camera)
        })
        
        let saveAction = UIAlertAction(title: optionLibraryTitle, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePickerFor(sourceType: .photoLibrary)
        })
        
        let cancelAction = UIAlertAction(title: optionCancelTitle, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        optionMenu.transitioningDelegate = self
        
        self.delegate?.showUploadOptions(optionMenu)
        
    }
    
    fileprivate func imagePickerFor(sourceType: UIImagePickerControllerSourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) == false {
            
            var sourceTypeName = ""
            
            switch sourceType {
            case .camera:
                sourceTypeName = "Camera"
            case .photoLibrary:
                sourceTypeName = "Photo Library"
            case .savedPhotosAlbum:
                sourceTypeName = "Photo Album"
            }
            
            let errorMessage = "profile_upload_avatar_error".localized(sourceTypeName)
            let errorTitle = "error_popup_title".localized()
            let okActionTitle = "txt_ok".localized()
            
            UIAlertController.show(
                controllerWithTitle: errorTitle,
                message: errorMessage,
                buttonTitle: okActionTitle
            )
            
            delegate?.optionsCanceled()
            
        } else {
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            delegate?.optionPicked(imagePicker)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User canceled from choosing image for its Avatar.")
        imagePicker.dismiss(animated: true, completion: nil)
        delegate?.optionsCanceled()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var choosedImage: UIImage?
        var choosedImageMaxSize: UIImage?
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            choosedImage = img
        } else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            choosedImage = img
            
        } else {
            print("No image choosed by the user found")
        }
        
        if let img = choosedImage {
            
            hasLoadedAvatar = true
            
            choosedImageMaxSize = img.resize(
                toSize: CGSize(width: 512, height: 512),
                contentMode: .scaleAspectFit
            )
            
            //choosedImageMaxSize = choosedImageMaxSize?.roundCornersToCircle()
            
            DispatchQueue.main.async { [unowned self] in
                self.setBackgroundImage(choosedImageMaxSize, for: .normal)
                self.setNeedsLayout()
            }
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        delegate?.optionDidFinishPickingMedia(choosedImageMaxSize)
    }
    
}

//MARK: - UIViewControllerTransitioningDelegate

extension UploadImageButton: UIViewControllerTransitioningDelegate {
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.delegate?.optionsCanceled()
        return nil
    }
    
}

//MARK: - UINavigationControllerDelegate

extension UploadImageButton : UINavigationControllerDelegate {
    //Used by the imagePicker
}

//MARK: - UploadImageButtonDelegate

protocol UploadImageButtonDelegate: class {
    func showUploadOptions(_ optionsViewController: UIAlertController)
    func optionsPresent()
    func optionsCanceled()
    func optionPicked(_ imagePickerViewController: UIImagePickerController)
    func optionDidFinishPickingMedia(_ pickedImage: UIImage?)
}

//MARK: - selectors

fileprivate extension Selector {
    static let onButtonPressed = #selector(UploadImageButton.onButtonPressed)
}

