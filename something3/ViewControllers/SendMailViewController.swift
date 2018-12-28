//
//  SendMailViewController.swift
//  something3
//
//  Created by 김동현 on 28/12/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import UIKit

class SendMailViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var tf_senderAddress: UITextField!
    @IBOutlet weak var tv_sendContents: UITextView!
    
    let contentPlaceHolder:String = "문제를 설명하거나 아이디어를 공유하세요"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tf_senderAddress.placeholder = "private@address"
        
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
        var alertMessage = ""
        if (self.tv_sendContents.text == "" || self.tf_senderAddress.text == "")
        {
            alertMessage = "It needs to fill form(email, contents) , please check"
        }
        
        if self.tf_senderAddress.text?.isValidEmail() == false {
            alertMessage = "please chekc your email format"
        }
        
        if(alertMessage != "")
        {
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

}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
