//
//  TICFontPanelView.swift
//  TICExample
//
//  Created by Jacob Bullock on 11/22/17.
//  Copyright © 2017 SIL. All rights reserved.
//

import Foundation
import UIKit

public class TICFontPanelView : TICFormatPanelView, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var fontTableView: UITableView!
    var availableFonts: [TICFont] = []
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        fontTableView.delegate = self
        fontTableView.dataSource = self
        fontTableView.register(UINib(nibName: "TICFontPanelTableViewCell", bundle: TICConfig.instance.bundle), forCellReuseIdentifier: "FontTableCell")
        fontTableView.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
 
    }
    
    func setAvailableFonts(fonts : [TICFont]) {
        // Check how many valid fonts are defined
        availableFonts = []
        for f : TICFont in fonts {
            if UIFont(name: f.fontFamily, size: 17) != nil {
                availableFonts.append(f)
            }
        }
    }

    // MARK: - TableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableFonts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontTableCell", for: indexPath) as! TICFontPanelTableViewCell
        let ticFont = availableFonts[indexPath.row]
        cell.cellFont = ticFont
        cell.contentView.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
        cell.tintColor = TICConfig.instance.theme.tintColor
        return cell
    }
    
    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TICFontPanelTableViewCell
        cell.accessoryView?.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
        self.delegate.setStyle(.fontFamily, cell.cellFont!.fontFamily, .both)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

public class TICFontDetailsPanelView : TICFormatPanelView
{
    @IBOutlet weak var lineHeightStepper: UIStepper!
    @IBOutlet weak var letterSpacingStepper: UIStepper!
    @IBOutlet weak var lineHeightLabel: UILabel!
    @IBOutlet weak var letterSpacingLabel: UILabel!
    
    var lineHeight : Int = 25
    var letterSpacing : Int = 0
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        TICConfig.instance.theme.formatLabel(lineHeightLabel)
        TICConfig.instance.theme.formatLabel(letterSpacingLabel)
        
        TICConfig.instance.theme.formatControl(lineHeightStepper)
        TICConfig.instance.theme.formatControl(letterSpacingStepper)
        
        lineHeightLabel.text = TICConfig.instance.locale.lineHeight
        letterSpacingLabel.text = TICConfig.instance.locale.letterSpacing
    }
    
    @IBAction func handleLetterSpacingValueChanged(_ sender: UIStepper) {
        
        letterSpacing = Int(sender.value)
        let ls = String(letterSpacing) + "px"
        self.delegate.setStyle(.letterSpacing, ls, .both)
    }
    
    @IBAction func handleLineHeightValueChanged(_ sender: UIStepper) {
        
        lineHeight = Int(sender.value)
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh, .both)
    }
    
    public func setLineHeightFromFontSize(_ size : Int) {
        
        lineHeight = size + 10
        let lh = String(lineHeight) + "px"
        self.delegate.setStyle(.lineHeight, lh, .both)
        
        lineHeightStepper.value = Double(lineHeight)
    }
}
