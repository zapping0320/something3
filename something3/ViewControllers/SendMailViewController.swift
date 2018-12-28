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
        if self.tv_sendContents.text == "" ||
        (self.tf_senderAddress.text == "" )
        {
            let alert = UIAlertController(title: title,
                                          message: "It needs to fill form(email, contents) , please check",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
   

}
