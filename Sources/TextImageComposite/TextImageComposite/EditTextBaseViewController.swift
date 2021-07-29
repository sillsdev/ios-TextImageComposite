//
//  EditTextBaseViewController.swift
//  TextImageComposite
//
//  Created by David Moore on 7/29/21.
//

import UIKit
import WebKit

open class EditTextBaseViewController: UIViewController {
    var dividerLine: UIView = UIView()
    var textView: UITextView?
    var referencePresent: Bool = false
    weak var webView: WKWebView?

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextView()
        self.view.addSubview(dividerLine)
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        setConstraints()
        let doneButtonImage = UIImage(named: "ic_done.png",
                                      in: TICConfig.instance.bundle,
                                      compatibleWith: nil)
        let doneButton = UIBarButtonItem(image: doneButtonImage, style: .plain, target: self, action: #selector(self.onDoneButtonPressed))
        doneButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem  = doneButton
        
        view.backgroundColor = TICConfig.instance.theme.backgroundColor
        self.title = TICConfig.instance.locale.editText
        referencePresent = !TICConfig.instance.reference.isEmpty
        var initialText = TICConfig.instance.text.trimmingCharacters(in: .whitespaces)
        if referencePresent {
            let referenceText = TICConfig.instance.reference.trimmingCharacters(in: .whitespaces)
            initialText = initialText + "\n" + referenceText
        }
        textView!.text = initialText
        textView!.backgroundColor = TICConfig.instance.theme.backgroundColor
        textView!.textColor = TICConfig.instance.theme.textColor
        dividerLine.backgroundColor = TICConfig.instance.theme.contrastColor
    }
    open func getTextView() -> UITextView {
        let newView = UITextView(frame: CGRect(x: 20.0, y: 88.0, width: 374.0, height: 474.5))
        return newView
    }
    func setConstraints() {
        var dividerTrailingConstraint: NSLayoutConstraint?
        var dividerLeadingConstraint: NSLayoutConstraint?
        var textTrailingConstraint: NSLayoutConstraint?
        var textLeadingConstraint: NSLayoutConstraint?
        var textTopConstraint: NSLayoutConstraint?
        let dividerHeightConstraint = NSLayoutConstraint(item: dividerLine,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .notAnAttribute,
                                                         multiplier: 1,
                                                         constant: 2)
        let dividerTextConstraint = NSLayoutConstraint(item: dividerLine,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: textView!,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: 0)
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            dividerTrailingConstraint = NSLayoutConstraint(item: guide,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: dividerLine,
                                                           attribute: .trailing,
                                                           multiplier: 1,
                                                           constant: 0)
            dividerLeadingConstraint = NSLayoutConstraint(item: dividerLine,
                                                           attribute: .leading,
                                                           relatedBy: .equal,
                                                           toItem: guide,
                                                           attribute: .leading,
                                                           multiplier: 1,
                                                           constant: 0)
            textTrailingConstraint = NSLayoutConstraint(item: guide,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: textView!,
                                                           attribute: .trailing,
                                                           multiplier: 1,
                                                           constant: 20)
            textLeadingConstraint = NSLayoutConstraint(item: textView!,
                                                            attribute: .leading,
                                                            relatedBy: .equal,
                                                            toItem: guide,
                                                            attribute: .leading,
                                                            multiplier: 1,
                                                            constant: 20)
            textTopConstraint = NSLayoutConstraint(item: textView!,
                                                        attribute: .top,
                                                        relatedBy: .equal,
                                                        toItem: guide,
                                                        attribute: .top,
                                                        multiplier: 1,
                                                        constant: 0)
        } else {
            let standardSpacing: CGFloat = 8.0
            dividerTrailingConstraint = NSLayoutConstraint(item: view!,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: dividerLine,
                                                           attribute: .trailing,
                                                           multiplier: 1,
                                                           constant: standardSpacing)
            dividerLeadingConstraint = NSLayoutConstraint(item: dividerLine,
                                                           attribute: .leading,
                                                           relatedBy: .equal,
                                                           toItem: view!,
                                                           attribute: .leading,
                                                           multiplier: 1,
                                                           constant: standardSpacing)
            textTrailingConstraint = NSLayoutConstraint(item: view!,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: textView,
                                                           attribute: .trailing,
                                                           multiplier: 1,
                                                           constant: standardSpacing + 20)
            textLeadingConstraint = NSLayoutConstraint(item: textView!,
                                                           attribute: .leading,
                                                           relatedBy: .equal,
                                                           toItem: view!,
                                                           attribute: .leading,
                                                           multiplier: 1,
                                                           constant: standardSpacing + 20)
            textTopConstraint = NSLayoutConstraint(item: textView!,
                                                        attribute: .top,
                                                        relatedBy: .equal,
                                                        toItem: view!,
                                                        attribute: .top,
                                                        multiplier: 1,
                                                        constant: standardSpacing)

        }
        view.addConstraints([dividerTextConstraint,
                             dividerTrailingConstraint!,
                             dividerLeadingConstraint!,
                             textTrailingConstraint!,
                             textLeadingConstraint!,
                             textTopConstraint!])
        dividerLine.addConstraints([dividerHeightConstraint])
         
    }
    func setupTextView() {
        textView = getTextView()
        textView!.isEditable = true
        textView!.isSelectable = true
        textView!.font = UIFont.systemFont(ofSize: 25.0, weight: .regular)
        textView!.showsHorizontalScrollIndicator = true
        textView!.showsVerticalScrollIndicator = true
        textView!.contentMode = .scaleToFill
        textView!.autoresizesSubviews = true
        textView!.isUserInteractionEnabled = true
        textView!.clipsToBounds = true
        textView!.sizeToFit()
        textView!.isScrollEnabled = false
        if #available(iOS 11, *) {
            textView!.contentInsetAdjustmentBehavior = .automatic
        }
        self.view.addSubview(textView!)
        textView!.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc func onDoneButtonPressed(_ sender: Any) {
        var text: String = textView!.text
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
