//
//  AddNoteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 10..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class AddNoteViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,UITextViewDelegate {
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var tv_content: UITextView!
    @IBOutlet weak var pv_notebooks: UIPickerView!
    @IBOutlet weak var switch_favorite: UISwitch!
    
    fileprivate var notebookArray_ = [R_NoteBook]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tf_title.placeholder = "Title"
        self.tv_content.delegate = self
        self.tv_content.text = "Content"
        self.tv_content.textColor = UIColor.lightGray
        loadNotebooks()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Content"
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        loadNotebooks()
        if notebookArray_.count > 0 {
            for i in 0..<notebookArray_.count {
                let notebook = notebookArray_[i]
                if(notebook.id == selectedNotebookId)
                {
                    self.pv_notebooks.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
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
        newnote.isfavorite = self.switch_favorite.isOn
        newnote.id = (realm.objects(R_Note.self).max(ofProperty: "id") as Int? ?? 0) + 1
        
        try! realm.write {
            realm.add(newnote)
        }
        
        self.tf_title.text = ""
        self.tv_content.text = ""
        
        self.tabBarController?.selectedIndex = 0
    }
    
}
