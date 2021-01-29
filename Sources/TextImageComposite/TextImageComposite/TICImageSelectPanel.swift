//
//  TICImageSelectPanel.swift
//  TextImageComposite
//
//  Created by David Moore on 1/26/21.
//

import UIKit
import MobileCoreServices

class TICImageSelectPanel: UIViewController {

    @IBOutlet weak var imageCollection: UICollectionView!
    
    var selectImageDelegate: TICImageSelectionDelegate?
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageCollection.dataSource = self
        imageCollection.delegate = self
        imageCollection.backgroundColor = TICConfig.instance.theme.backgroundColor
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TICImageSelectPanel: UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            TICConfig.instance.selectedURL = nil
            TICConfig.instance.selectedImage = image
            selectImageDelegate?.changeSelectedImage()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension TICImageSelectPanel: UINavigationControllerDelegate {
    
}

extension TICImageSelectPanel : UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                picker.delegate = self
                picker.allowsEditing = true
                picker.modalPresentationStyle = .popover
                picker.sourceType = .photoLibrary
                picker.mediaTypes = [kUTTypeImage as String]
                
                let presentationController = picker.popoverPresentationController
                presentationController?.barButtonItem = selectImageDelegate?.getAnchorButton()
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                
                self.present(picker, animated: true, completion: nil)
            }
        } else {
            TICConfig.instance.selectedURL = TICConfig.instance.images[indexPath.item - 1].imageURL
            TICConfig.instance.selectedImage = nil
            selectImageDelegate?.changeSelectedImage()
        }
    }
}

extension TICImageSelectPanel : UICollectionViewDataSource
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return TICConfig.instance.images.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TICImagesCell", for: indexPath)
            cell.tintColor = TICConfig.instance.theme.contrastColor
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TICImageCell2", for: indexPath) as! TICImageCell
            cell.imageView.imageURL = TICConfig.instance.images[indexPath.item - 1].imageURL
            return cell
        }
    }
}
