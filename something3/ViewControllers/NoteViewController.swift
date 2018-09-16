//
//  NoteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 12..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class NoteViewController: UIViewController {

    @IBOutlet weak var lb_updatedAt: UILabel!
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var tv_content: UITextView!
    @IBOutlet weak var switch_favorite: UISwitch!
    
    open var selectedNote:R_Note = R_Note()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        self.lb_updatedAt.text = dateformatter.string(from: selectedNote.updated_at)
        self.switch_favorite.isOn = selectedNote.isfavorite
        self.tf_title.text = selectedNote.title
        self.tv_content.text = selectedNote.content
        if(selectedNote.relatedNotebookId == -1){
            self.tf_title.isUserInteractionEnabled = false
            self.tv_content.isEditable = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btn_save_action(_ sender: UIButton) {
        if(self.selectedNote.relatedNotebookId == -1)
        {
            let alert = UIAlertController(title: title,
                                          message: "It's not allowed to modify notes at TrashCan. Please try after restoring this",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if(self.tf_title.text == "" && self.tv_content.text == "")
        {
            let alert = UIAlertController(title: title,
                                          message: "you entered no text, please check",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let realm = try! Realm()
        
        try! realm.write {
            selectedNote.title = self.tf_title.text!
            selectedNote.content = self.tv_content.text
            selectedNote.isfavorite = self.switch_favorite.isOn
            selectedNote.updated_at = Date()
        }
        
        self.navigationController?.popViewController(animated: false)
        
    }
}
