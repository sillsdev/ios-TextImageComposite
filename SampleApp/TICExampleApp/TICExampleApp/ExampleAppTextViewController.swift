//
//  ExampleAppTextViewController.swift
//  TICExampleApp
//
//  Created by David Moore on 7/29/21.
//

import UIKit
import TextImageComposite

class ExampleAppTextViewController: EditTextBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func getTextView() -> UITextView {
        let newView = UITextView(frame: CGRect(x: 20.0, y: 88.0, width: 374.0, height: 474.5))
        return newView
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
