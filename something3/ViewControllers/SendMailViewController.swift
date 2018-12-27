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

        self.tv_sendContents.delegate = self
        self.tv_sendContents.text = self.contentPlaceHolder
        self.tv_sendContents.textColor = UIColor.lightGray
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
   

}
