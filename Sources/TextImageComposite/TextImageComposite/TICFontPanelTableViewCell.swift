//
//  TICFontPanelTableViewCell.swift
//  TextImageComposite
//
//  Created by David Moore on 11/20/20.
//

import UIKit

class TICFontPanelTableViewCell: UITableViewCell {
    var fontLabel : UILabel?
    public var cellFont: TICFont? {
        didSet {
            let font = UIFont(name: cellFont!.fontFamily, size: 17)
            if fontLabel != nil {
                fontLabel?.removeFromSuperview() // Required for reuse of cell object
            }
            fontLabel = UILabel(frame: CGRect(x: 5, y: 5, width: contentView.frame.width - 15, height: contentView.frame.height - 5))
            fontLabel!.text = cellFont?.title
            fontLabel!.textColor = TICConfig.instance.theme.tintColor
            fontLabel!.font = font
            fontLabel!.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
            self.addSubview(fontLabel!)
            let lConstraint = NSLayoutConstraint(item: fontLabel as Any, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 8)
            let tConstraint = NSLayoutConstraint(item: fontLabel as Any, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 8)
            let cConstraint = NSLayoutConstraint(item: fontLabel as Any, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([lConstraint, tConstraint, cConstraint])
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
     }
    
}
