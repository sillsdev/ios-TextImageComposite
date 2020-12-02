//
//  TICImageSelectionViewController.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 9/30/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

protocol TICImageSelectionPreviewDelegate
{
    func closePreview()
    func selectImage()
}

public class TICImageSelectionPreview : UIView
{
    @IBOutlet weak var previewImage: CachedImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    var delegate : TICImageSelectionPreviewDelegate!
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        TICConfig.instance.theme.formatView(self)
        TICConfig.instance.theme.formatControl(cancelButton)
        TICConfig.instance.theme.formatControl(chooseImageButton)
        
        self.cancelButton.setTitle(TICConfig.instance.locale.cancel, for: .normal)
        self.chooseImageButton.setTitle(TICConfig.instance.locale.chooseImage, for: .normal)
    }
    
    @IBAction func handleCancelPreviewButtonTap(_ sender: Any) {
        
        self.delegate.closePreview()
    }
    
    @IBAction func handleChooseImageButtonTap(_ sender: Any) {
        
        self.delegate.selectImage()
    }
    
    public func open(imageURL : URL) {
        
        self.previewImage.imageURL = imageURL
    }
}

public class TICImageSelectionViewController : UIViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var preview: TICImageSelectionPreview!
    
    let picker = UIImagePickerController()
    
    var blackoutView: UIView!
    var imageUrl: URL? = nil
    var image: UIImage? = nil
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        TICConfig.instance.active = true
        
        self.cancelButton.title = TICConfig.instance.locale.cancel
        
        //using empty string to remove default `Back` text on NavigationBar back item
        self.navigationItem.title = " "//TICConfig.instance.locale.chooseImage
        self.cancelButton.title = TICConfig.instance.locale.cancel
        
        TICConfig.instance.theme.formatNavbar((self.navigationController?.navigationBar)!)
        TICConfig.instance.theme.formatView(self.view)
        TICConfig.instance.theme.formatView(self.collectionView)
        
        self.preview.delegate = self
        
        //this is causing a warning in the console about not being able to satisfy all constraints
        self.previewImageBottomConstraint.constant = -previewImageHeightConstraint.constant
        
        self.setupBlackout()

    }
    
    func setupBlackout() {
        
        blackoutView = UIView.init(frame:CGRect.zero)
        blackoutView.translatesAutoresizingMaskIntoConstraints = false
        blackoutView.backgroundColor = UIColor.black
        blackoutView.alpha = 0
        blackoutView.isUserInteractionEnabled = false;
        
        self.view.insertSubview(blackoutView, belowSubview: self.preview)
        
        blackoutView.constrainToFillContainer(self.view)
    }
    
    func openPreviewAt(_ index: Int) {
        
        image = nil
        imageUrl = TICConfig.instance.images[index].imageURL
        self.preview.previewImage.imageURL = imageUrl
        
        openPreview()
    }
    
    func openPreviewImage(_ image: UIImage) {
        
        imageUrl = nil
        self.image = image
        self.preview.previewImage.image = image
        
        openPreview()
    }
    
    func openPreview() {
        
        blackoutView.isUserInteractionEnabled = true;
        
        self.previewImageBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.blackoutView.alpha = 0.5
        }
    }
    
    @IBAction func handleCancelButtonTap(_ sender: Any) {
        TICConfig.instance.active = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleChooseButtonTap(_ sender: UIBarButtonItem) {
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.modalPresentationStyle = .popover
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String]
        
        let presentationController = picker.popoverPresentationController
        presentationController?.barButtonItem = sender
        presentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        self.present(picker, animated: true, completion: nil)
    }
}

extension UIImage {
    func scaledTo(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        return img!
    }
}

extension TICImageSelectionViewController: UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            openPreviewImage(image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension TICImageSelectionViewController: UINavigationControllerDelegate {
    
}

extension TICImageSelectionViewController : TICImageSelectionPreviewDelegate {
    
    func closePreview() {
        
        self.previewImageBottomConstraint.constant = -previewImageHeightConstraint.constant
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blackoutView.alpha = 0
            self.view.layoutIfNeeded()
            
        }) { (Bool) in
            self.blackoutView.isUserInteractionEnabled = false
        }
    }
    
    func selectImage() {
        
        do {
            if let url = imageUrl {
                let data = try Data(contentsOf: url)
                TICConfig.instance.selectedImage = UIImage(data:data)
            } else if let image = self.image {
                TICConfig.instance.selectedImage = image
            }
        } catch {
            
        }
       
        self.performSegue(withIdentifier: "ShowEditor", sender: nil)
        
        self.closePreview()
    }
}

extension TICImageSelectionViewController : UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        openPreviewAt(indexPath.item)
    }
}

extension TICImageSelectionViewController : UICollectionViewDataSource
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return TICConfig.instance.images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TICImageCell", for: indexPath) as! TICImageCell
        cell.imageView.imageURL = TICConfig.instance.images[indexPath.item].thumbURL
        
        return cell
    }
}
