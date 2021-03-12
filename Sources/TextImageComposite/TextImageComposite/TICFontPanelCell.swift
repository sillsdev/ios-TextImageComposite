//
//  TICFontPanelCell.swift
//  TextImageComposite
//
//  Created by David Moore on 12/1/20.
//

import UIKit

class TICFontPanelCell: UITableViewCell {

    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var fontNameLabel: UILabel!
    public var cellFont: TICFont? {
        didSet {
            let font = UIFont(name: cellFont!.fontFamily, size: 17)
            setUnselectedText()
            fontNameLabel.textColor = TICConfig.instance.theme.textColor
            fontNameLabel.font = font
            fontNameLabel.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
            fontNameLabel.text = cellFont!.title
            selectedLabel.textColor = TICConfig.instance.theme.textColor
            selectedLabel.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
            self.accessoryType = .none
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            setSelectedText()
            //self.accessoryType = .checkmark
        } else {
            setUnselectedText()
            //self.accessoryType = .none
        }    }
    func setSelectedText() {
        selectedLabel.text = "\u{2713}"
    }
    func setUnselectedText() {
        selectedLabel.text = "\u{2001}"
    }
}
