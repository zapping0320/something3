//
//  AddNoteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 10..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class AddNoteViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var tv_content: UITextView!
    @IBOutlet weak var pv_notebooks: UIPickerView!
    
    fileprivate var notebookArray_ = [R_NoteBook]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         loadNotebooks()
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        loadNotebooks()
        if notebookArray_.count > 0 {
            self.pv_notebooks.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    
    func loadNotebooks() {
        notebookArray_ = [R_NoteBook]()
        
        let realm = try! Realm()
        let results = realm.objects(R_NoteBook.self)
        print(results.count)
        for i in 0..<results.count {
            let item = results[i]
            notebookArray_.append(item)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return notebookArray_.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return notebookArray_[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(notebookArray_[row].name)
    }
    
    @IBAction func btn_save_action(_ sender: UIButton) {
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
        let newnote = R_Note()
        newnote.title = self.tf_title.text!
        newnote.content = self.tv_content.text!
        newnote.relatedNotebookId = notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].id
        newnote.id = (realm.objects(R_Note.self).max(ofProperty: "id") as Int? ?? 0) + 1
        
        try! realm.write {
            realm.add(newnote)
        }
        
        self.tf_title.text = ""
        self.tv_content.text = ""
        
        self.tabBarController?.selectedIndex = 0
    }
    
}