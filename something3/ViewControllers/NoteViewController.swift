//
//  NoteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 12..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class NoteViewController: UIViewController,UITextViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var lb_updatedAt: UILabel!
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var tv_content: UITextView!
    @IBOutlet weak var switch_favorite: UISwitch!
    @IBOutlet weak var pv_notebooks: UIPickerView!
    
    @IBOutlet weak var bt_more: UIButton!
    @IBOutlet weak var lb_guideTrash: UILabel!
    
    open var selectedNote:R_Note = R_Note()
    fileprivate var notebookArray_ = [R_NoteBook]()
    let dateformatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        self.lb_updatedAt.text = dateformatter.string(from: selectedNote.updated_at)
        self.switch_favorite.isOn = selectedNote.isfavorite
        
        self.tf_title.text = selectedNote.title
        self.tf_title.placeholder = "Title"
        self.tv_content.text = selectedNote.content
        self.tv_content.delegate = self
        if(selectedNote.content == "")
        {
            self.tv_content.text = "Content"
            self.tv_content.textColor = UIColor.lightGray
        }
        
        if(selectedNote.relatedNotebookId == -1){
            self.tf_title.isUserInteractionEnabled = false
            self.tv_content.isEditable = false
            self.bt_more.isHidden = false
            self.lb_guideTrash.isHidden = false
            self.switch_favorite.isHidden = true
        }
        else{
            self.bt_more.isHidden = true
            self.lb_guideTrash.isHidden = true
            self.switch_favorite.isHidden = false
        }
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
    @IBAction func btn_more_action(_ sender: UIButton) {
        let alert = UIAlertController(title: title,
                                      message: "More",
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let restoreAction = UIAlertAction(title: "Restore",
                                          style: .default, handler: {result in
            let realm = try! Realm()
            try! realm.write {
                self.selectedNote.relatedNotebookId = self.selectedNote.oldNotebookId
                self.selectedNote.oldNotebookId = -1
            }
            self.navigationController?.popViewController(animated: false)
        })
        let deleteAction = UIAlertAction(title: "Delete Completely",
                                         style: .default, handler: { reuslt in
            let realm = try! Realm()
            try! realm.write {
                realm.delete(self.selectedNote)
            }
            self.navigationController?.popViewController(animated: false)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel, handler: nil)
        alert.addAction(restoreAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
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
        else
        {
            saveChangedData()
        }
    }
    
    
    @IBAction func lb_title_ValueChanged(_ sender: Any) {
        saveChangedData()
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
        saveChangedData()
    }
    
    func saveChangedData() {
        let realm = try! Realm()
        
        try! realm.write {
            selectedNote.title = self.tf_title.text!
            selectedNote.content = self.tv_content.text
            selectedNote.isfavorite = self.switch_favorite.isOn
            selectedNote.relatedNotebookId = notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].id
            selectedNote.updated_at = Date()
        }
        
        self.lb_updatedAt.text = dateformatter.string(from: selectedNote.updated_at)
        
    }
    
    @IBAction func switch_ValueChanged(_ sender: UISwitch) {
        saveChangedData()
    }
}
