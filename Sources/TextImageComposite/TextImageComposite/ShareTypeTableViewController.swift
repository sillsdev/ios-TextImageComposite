//
//  ShareTypeTableViewController.swift
//  TextImageComposite
//
//  Created by David Moore on 1/28/21.
//

import UIKit
public enum TICShareOutputType {
    case image
    case video
}
public protocol TICShareDelegate {
    func share(type: TICShareOutputType)
    func save(type: TICShareOutputType)
}
class ShareTypeTableViewController: UITableViewController {

    public var shareOperation = true
    public var shareDelegate: TICShareDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareTypeCell", for: indexPath)
        cell.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
        cell.tintColor = TICConfig.instance.theme.tintColor
        if let shareCell = cell as? ShareTypeTableViewCell {
            shareCell.sourceLabel.textColor = TICConfig.instance.theme.tintColor
            switch indexPath.row {
            case 0:
                shareCell.sourceImage.image = UIImage.init(named: "ic_image", in: TICConfig.instance.bundle, compatibleWith: nil)
                shareCell.sourceLabel.text = shareOperation ? TICConfig.instance.locale.shareImage : TICConfig.instance.locale.saveImage
                break
            case 1:
                shareCell.sourceImage.image = UIImage(named: "ic_video", in: TICConfig.instance.bundle, compatibleWith: nil)
                shareCell.sourceLabel.text = shareOperation ? TICConfig.instance.locale.shareVideo : TICConfig.instance.locale.saveVideo
                break
            default:
                break
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioVideo : TICShareOutputType = indexPath.row == 0 ? .image : .video
        if shareOperation {
            shareDelegate?.share(type: audioVideo)
        } else {
            shareDelegate?.save(type: audioVideo)
        }
        dismiss(animated: true, completion: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
