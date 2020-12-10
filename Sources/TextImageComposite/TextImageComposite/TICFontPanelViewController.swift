//
//  TICFontPanelViewController.swift
//  TextImageComposite
//
//  Created by David Moore on 12/1/20.
//

import UIKit

class TICFontPanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var availableFonts: [TICFont] = []
    public var delegate: TICFormatDelegate!
    
    @IBOutlet weak var fontListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontListTableView.delegate = self
        fontListTableView.dataSource = self
        fontListTableView.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableFonts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TICFontPanelCell", for: indexPath) as! TICFontPanelCell
        let ticFont = availableFonts[indexPath.row]
        cell.cellFont = ticFont
        cell.contentView.backgroundColor = TICConfig.instance.theme.viewBackgroundColor
        cell.tintColor = TICConfig.instance.theme.tintColor
        return cell    }
    
    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TICFontPanelCell
        self.delegate.setStyle(.fontFamily, cell.cellFont!.fontFamily, .both)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(61) //UITableView.automaticDimension
    }

}
