//
//  AddNotebookViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 8..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import Foundation
import RealmSwift

class AddNotebookViewController : UIViewController {

    @IBOutlet weak var tf_notebookName: UITextField!
    @IBOutlet weak var btn_SaveNotebook: UIButton!
    
    override func viewDidLoad() {
        applyCurrentColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.btn_SaveNotebook.backgroundColor = ColorHelper.getCurrentMainButtonColor()
        
    }
    
    func closeViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btn_cancel_action(_ sender: UIButton) {
        closeViewController()
    }
    
    @IBAction func btn_save_action(_ sender: UIButton) {
        
        if(self.tf_notebookName.text == "")
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
        
        let newid = (realm.objects(R_NoteBook.self).max(ofProperty: "id") as Int? ?? 0) + 1
        
        let newnotebook = R_NoteBook()
        newnotebook.name = self.tf_notebookName.text!
        newnotebook.id = newid
        
        try! realm.write {
            realm.add(newnotebook)
        }
        
        closeViewController()
    }
    
}
