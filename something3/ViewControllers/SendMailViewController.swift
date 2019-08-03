//
//  SendMailViewController.swift
//  something3
//
//  Created by 김동현 on 28/12/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import UIKit
import MessageUI

class SendMailViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var tf_senderAddress: UITextField!
    @IBOutlet weak var tv_sendContents: UITextView!
    
    let contentPlaceHolder:String = NSLocalizedString("Describe the problem or share your ideas", comment: "")
    
    var composeVC:MFMailComposeViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.composeVC = MFMailComposeViewController()
        if(self.composeVC == nil ){
            self.navigationController?.popViewController(animated: false)
        }
        else {
            self.composeVC!.mailComposeDelegate = self
        }

        self.tf_senderAddress.placeholder = "address@example.com"
        
        self.tv_sendContents.delegate = self
        self.tv_sendContents.text = self.contentPlaceHolder
        self.tv_sendContents.textColor = UIColor.lightGray
        
        let sendButton = UIBarButtonItem(barButtonSystemItem: .action , target: self, action: #selector(sendEmailToAppAdministrator))
        self.navigationItem.rightBarButtonItem = sendButton
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.contentPlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func sendEmailToAppAdministrator() {
        if !MFMailComposeViewController.canSendMail() {
            popupMessaage(alertMessage: "Mail services are not available")
        }
        
        if (self.tv_sendContents.text == "" || self.tf_senderAddress.text == "")
        {
            popupMessaage(alertMessage: "It needs to fill form(email, contents) , please check")
        }
        
        if self.tf_senderAddress.text?.isValidEmail() == false {
            popupMessaage(alertMessage: "please chekc your email format")
        }
        
        self.composeVC!.setToRecipients(["zappingtest@gmail.com"])
        self.composeVC!.setSubject("Customer's opinion" + self.tf_senderAddress.text!)
        self.composeVC!.setMessageBody(self.tv_sendContents.text, isHTML: false)
        self.present(self.composeVC!, animated: true, completion: {self.dismiss(animated: false, completion: nil)})
    }
    
    func popupMessaage(alertMessage:String) {
        let alert = UIAlertController(title: title,
                                      message: alertMessage,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        return
    }

}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
