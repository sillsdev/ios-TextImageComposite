//
//  EditTextViewController.swift
//  TextImageComposite
//
//  Created by David Moore on 3/12/21.
//

import UIKit
import WebKit

class EditTextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dividerLine: UIView!
    
    var referencePresent: Bool = false
    weak var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TICConfig.instance.theme.backgroundColor
        self.title = TICConfig.instance.locale.editText
        referencePresent = !TICConfig.instance.reference.isEmpty
        var initialText = TICConfig.instance.text.trimmingCharacters(in: .whitespaces)
        if referencePresent {
            let referenceText = TICConfig.instance.reference.trimmingCharacters(in: .whitespaces)
            initialText = initialText + "\n" + referenceText
        }
        textView.text = initialText
        textView.backgroundColor = TICConfig.instance.theme.backgroundColor
        textView.textColor = TICConfig.instance.theme.textColor
        dividerLine.backgroundColor = TICConfig.instance.theme.contrastColor
    }
    
    @IBAction func onDoneButtonPressed(_ sender: Any) {
        var text: String = textView.text
        var reference = ""
        if referencePresent {
            let lines = text.components(separatedBy: "\n")
            if lines.count > 1 {
                let startingReference = TICConfig.instance.reference
                if let lastLine = lines.last {
                    let firstStartingRef = startingReference.prefix(4)
                    if lastLine.range(of: firstStartingRef) != nil {
                        let newTextLength = text.count - lastLine.count
                        let newText = text.prefix(newTextLength).trimmingCharacters(in: .whitespacesAndNewlines)
                        text = newText
                        reference = lastLine.trimmingCharacters(in: .whitespaces)
                    }
                }
            }
        }
        TICConfig.instance.text = text
        TICConfig.instance.reference = reference
        TICCustomizeViewController.setTextAndReference(webView: webView)
        self.navigationController?.popViewController(animated: true)
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
