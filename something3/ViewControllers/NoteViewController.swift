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
    
    @IBOutlet weak var bt_alarm: UIButton!
    @IBOutlet weak var lb_guideTrash: UILabel!
    
    open var selectedNote:R_Note = R_Note()
    fileprivate var notebookArray_ = [R_NoteBook]()
    let dateformatter = DateFormatter()
    var alarmDate:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        self.lb_updatedAt.text = dateformatter.string(from: selectedNote.updated_at)
        self.switch_favorite.isOn = selectedNote.isfavorite
        self.alarmDate = selectedNote.alarmDate
        if(self.selectedNote.alarmDate == nil)
        {
            self.bt_alarm.setTitle("미설정", for: .normal)
        }
        else
        {
            self.bt_alarm.setTitle("설정됨", for: .normal)
        }
        
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
            self.lb_guideTrash.isHidden = false
            self.switch_favorite.isHidden = true
            self.bt_alarm.isHidden = true
        }
        else{
            self.lb_guideTrash.isHidden = true
            self.switch_favorite.isHidden = false
            self.bt_alarm.isHidden = false
            self.pv_notebooks.isAccessibilityElement = true
        }
         loadNotebooks()
        if notebookArray_.count > 0 {
            for i in 0..<notebookArray_.count {
                let notebook = notebookArray_[i]
                if(notebook.id == self.selectedNote.relatedNotebookId)
                {
                    self.pv_notebooks.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
        }
        
        let moreBtn = UIBarButtonItem(title: "More", style: .plain , target: self, action: #selector(barBtn_more_Action))
        self.navigationItem.rightBarButtonItem = moreBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.bt_alarm.tintColor = ColorHelper.getCurrentDeepTextColor()
    }
    
    @objc func barBtn_more_Action(){
        let alert = UIAlertController(title: title,
                                      message: "more",
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        if(self.selectedNote.relatedNotebookId != -1)
        {
            let copyNoteAction = UIAlertAction(title: "Copy Note",
                                               style: .default, handler: {result in
                                                
                                                let realm = try! Realm()
                                                let newnote = R_Note()
                                                //newnote.title = self.tf_title.text! + " copied"
                                                newnote.title = StringHelper.makeHeaderStringCopied(title: self.tf_title.text!)
                                                newnote.content = self.tv_content.text!
                                                newnote.relatedNotebookId = self.notebookArray_[self.pv_notebooks.selectedRow(inComponent: 0)].id
                                                newnote.isfavorite = self.switch_favorite.isOn
                                                newnote.id = (realm.objects(R_Note.self).max(ofProperty: "id") as Int? ?? 0) + 1
                                                newnote.alarmDate = self.alarmDate
                                                
                                                try! realm.write {
                                                    realm.add(newnote)
                                                }
                                                
                                                self.navigationController?.popViewController(animated: false)
            })
            copyNoteAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(copyNoteAction)
            
            let sendToTrashAction = UIAlertAction(title: "Send To Trash",
                                                  style: .default, handler: {result in
                                                    let realm = try! Realm()
                                                    
                                                    try! realm.write {
                                                        self.selectedNote.oldNotebookId = self.selectedNote.relatedNotebookId
                                                        self.selectedNote.relatedNotebookId = -1
                                                    }
                                                    self.navigationController?.popViewController(animated: false)
            })
            sendToTrashAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(sendToTrashAction)
        }
        else
        {
            let restoreAction = UIAlertAction(title: "Restore",
                                              style: .default, handler: {result in
                                                let realm = try! Realm()
                                                try! realm.write {
                                                    self.selectedNote.relatedNotebookId = self.selectedNote.oldNotebookId
                                                    self.selectedNote.oldNotebookId = -1
                                                }
                                                self.navigationController?.popViewController(animated: false)
            })
            restoreAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(restoreAction)
            let deleteAction = UIAlertAction(title: "Delete Completely",
                                             style: .default, handler: { reuslt in
                                                let realm = try! Realm()
                                                try! realm.write {
                                                    realm.delete(self.selectedNote)
                                                }
                                                self.navigationController?.popViewController(animated: false)
            })
            deleteAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(deleteAction)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel, handler: nil)
        cancelAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadNotebooks() {
        notebookArray_ = [R_NoteBook]()
        
        let realm = try! Realm()
        let results = realm.objects(R_NoteBook.self)
        print(results.count)
        for i in 0..<results.count {
            let item = results[i]
            if(selectedNote.relatedNotebookId == -1)
            {
                if(item.id != self.selectedNote.oldNotebookId)
                {
                    continue
                }
                notebookArray_.append(item)
                break
            }
            else
            {
                notebookArray_.append(item)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeViewController() {
        self.dismiss(animated: false, completion: nil)
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
            notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].updated_at = Date()
            
            selectedNote.title = self.tf_title.text!
            selectedNote.content = self.tv_content.text
            selectedNote.isfavorite = self.switch_favorite.isOn
            selectedNote.relatedNotebookId = notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].id
            selectedNote.updated_at = Date()
            selectedNote.alarmDate = self.alarmDate
        }
        
        self.lb_updatedAt.text = dateformatter.string(from: selectedNote.updated_at)
        
        self.chekcAlarmState()
    }
    
    func chekcAlarmState(){
        if(self.selectedNote.alarmDate == nil)
        {
            self.bt_alarm.setTitle("미설정", for: .normal)
        }
        else
        {
            self.bt_alarm.setTitle("설정됨", for: .normal)
        }
    }
    
    @IBAction func switch_ValueChanged(_ sender: UISwitch) {
        if(sender.tag == 1){
            saveChangedData()
        }
        
    }
    
    @IBAction func bt_alarm_action(_ sender: UIButton) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        if(self.selectedNote.alarmDate != nil) {
            datePicker.setDate(self.selectedNote.alarmDate!, animated: false)
        }
        
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\nAlarm Setting", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        /*
         datePicker.snp.makeConstraints { (make) in
         make.centerX.equalTo(alert.view)
         make.top.equalTo(alert.view).offset(8)
         }*/
        
        let setAction = UIAlertAction(title: "설정", style: .default) { (action) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
            let dateString = dateFormatter.string(from: datePicker.date)
            print(dateString)
            self.alarmDate = datePicker.date
            self.saveChangedData()
        }
        setAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
        alert.addAction(setAction)
        
        if(self.selectedNote.alarmDate != nil)
        {
            let changeAlarmAction = UIAlertAction(title: "알람변경", style: .default) { (action) in
                self.alarmDate = datePicker.date
                self.saveChangedData()
            }
            changeAlarmAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(changeAlarmAction)
            
            let unsetAction = UIAlertAction(title: "설정해제", style: .default) { (action) in
                self.alarmDate = nil
                self.saveChangedData()
            }
            unsetAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(unsetAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cancelAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
   
}
