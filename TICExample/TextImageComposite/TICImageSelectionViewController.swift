//
//  TICImageSelectionViewController.swift
//  ScriptureImage
//
//  Created by Jacob Bullock on 9/30/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit


protocol TICImageSelectionPreviewDelegate
{
    func closePreview()
    func selectImage()
}

class TICImageSelectionPreview : UIView
{
    @IBOutlet weak var previewImage: CachedImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    var delegate : TICImageSelectionPreviewDelegate!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        TICConfig.instance.theme.formatView(self)
        TICConfig.instance.theme.formatControl(cancelButton)
        TICConfig.instance.theme.formatControl(chooseImageButton)
        
        self.cancelButton.setTitle(TICConfig.instance.locale.cancel, for: .normal)
        self.chooseImageButton.setTitle(TICConfig.instance.locale.chooseImage, for: .normal)
    }
    
    @IBAction func handleCancelPreviewButtonTap(_ sender: Any)
    {
        self.delegate.closePreview()
    }
    
    @IBAction func handleChooseImageButtonTap(_ sender: Any)
    {
        self.delegate.selectImage()
    }
    
    public func open(imageURL : URL)
    {
        self.previewImage.imageURL = imageURL
    }
}

class TICImageSelectionViewController : UIViewController
{
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var preview: TICImageSelectionPreview!
    
    var blackoutView : UIView!
    var imageIndex : Int = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.cancelButton.title = TICConfig.instance.locale.cancel
        
        self.navigationItem.title = TICConfig.instance.locale.chooseImage
        self.cancelButton.title = TICConfig.instance.locale.cancel
        
        TICConfig.instance.theme.formatNavbar((self.navigationController?.navigationBar)!)
        TICConfig.instance.theme.formatView(self.view)
        TICConfig.instance.theme.formatView(self.collectionView)
        
        self.preview.delegate = self
        
        //this is causing a warning in the console about not being able to satisfy all constraints
        self.previewImageTopConstraint.constant = self.view.frame.size.height
        
        self.setupBlackout()
    }
    
    func setupBlackout()
    {
        blackoutView = UIView.init(frame:CGRect.zero)
        blackoutView.translatesAutoresizingMaskIntoConstraints = false
        blackoutView.backgroundColor = UIColor.black
        blackoutView.alpha = 0
        blackoutView.isUserInteractionEnabled = false;
        
        self.view.insertSubview(blackoutView, belowSubview: self.preview)
        
        //Using older syntax to support iOS 8
        
        NSLayoutConstraint(item: blackoutView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: blackoutView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: blackoutView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: blackoutView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    @IBAction func handleCancelButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openPreview(_ index : Int)
    {
        blackoutView.isUserInteractionEnabled = true;
        imageIndex = index
        
        self.previewImageTopConstraint.constant = 150
        self.preview.previewImage.imageURL = TICConfig.instance.images[imageIndex].imageURL
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.blackoutView.alpha = 0.5
        }
    }

    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEditor"
        {
            if let vc = segue.destination as? TICCustomizeViewController
            {
               vc.config = config
            }
        }
    }
     */
}

extension TICImageSelectionViewController : TICImageSelectionPreviewDelegate
{
    func closePreview()
    {
        self.previewImageTopConstraint.constant = self.view.frame.size.height
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blackoutView.alpha = 0
            self.view.layoutIfNeeded()
            
        }) { (Bool) in
            self.blackoutView.isUserInteractionEnabled = false
        }
    }
    
    func selectImage()
    {
        TICConfig.instance.imageUrl = TICConfig.instance.images[imageIndex].imageURL
        self.performSegue(withIdentifier: "ShowEditor", sender: nil)
        
        self.closePreview()
    }
}

extension TICImageSelectionViewController : UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        openPreview(indexPath.item)
    }
}

extension TICImageSelectionViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TICConfig.instance.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TICImageCell", for: indexPath) as! TICImageCell
        
        cell.imageView.imageURL = TICConfig.instance.images[indexPath.item].thumbURL
        
        return cell
    }
}
