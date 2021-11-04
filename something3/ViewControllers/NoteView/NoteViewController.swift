//
//  NoteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 12..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class NoteViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var lb_updatedAt: UILabel!
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var tf_tags: UITextField!
    @IBOutlet weak var tv_content: UITextView!
    @IBOutlet weak var switch_favorite: UISwitch!
    @IBOutlet weak var pv_notebooks: UIPickerView!
    
    @IBOutlet weak var bt_alarm: UIButton!
    @IBOutlet weak var lb_guideTrash: UILabel!
    
     
    var alarmDate:Date?
    var alarmIdentifier:String?
    
    var eventHelper:EventHelper?
    
    private let viewModel = NoteViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.eventHelper == nil {
            self.eventHelper = EventHelper()
        }
        
       
        
        
        let moreBtn = UIBarButtonItem(title: NSLocalizedString("More", comment: ""), style: .plain , target: self, action: #selector(barBtn_more_Action))
        self.navigationItem.rightBarButtonItem = moreBtn
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateUI()
    }
    
    private func updateUI() {
        let selectedNote = viewModel.selectedNote
        self.lb_updatedAt.text = viewModel.getUpdatedDateString()
        self.switch_favorite.isOn = selectedNote.isfavorite
        self.alarmDate = selectedNote.alarmDate
        if(selectedNote.alarmDate == nil)
        {
            self.bt_alarm.setTitle(NSLocalizedString("Unset", comment: ""), for: .normal)
        }
        else
        {
            self.bt_alarm.setTitle(NSLocalizedString("Set", comment: ""), for: .normal)
            self.alarmIdentifier = selectedNote.alarmIdentifier
        }
        
        self.tf_title.text = viewModel.selectedNote.title
        self.tf_title.placeholder = NSLocalizedString("Title", comment: "")
        self.tf_tags.placeholder = TagManager.tagPlaceHolderString
        self.tf_tags.text = TagManager.makeTagString(noteid: selectedNote.id)
        self.tv_content.text = selectedNote.content
        self.tv_content.delegate = self
        if(selectedNote.content == "")
        {
            self.tv_content.text = NSLocalizedString("Content", comment: "")
            self.tv_content.textColor = UIColor.lightGray
        }
        
        
     
        if(selectedNote.relatedNotebookId == -1){
            self.tf_title.isUserInteractionEnabled = false
            self.tf_tags.isEnabled = false
            self.tv_content.isEditable = false
            self.lb_guideTrash.isHidden = false
            self.switch_favorite.isEnabled = false
            self.bt_alarm.isEnabled = false
            self.pv_notebooks.isHidden = true
        }
        else{
            self.lb_guideTrash.isHidden = true
            self.switch_favorite.isEnabled = true
            self.bt_alarm.isEnabled = true
            self.pv_notebooks.isHidden = false
            
            let notebooks = viewModel.getNotebooks()
            if notebooks.count > 0 {
                for i in 0..<notebooks.count {
                    let notebook = notebooks[i]
                    if(notebook.id == selectedNote.relatedNotebookId)
                    {
                        self.pv_notebooks.selectRow(i, inComponent: 0, animated: false)
                        break
                    }
                }
            }
        }
        
        self.tf_tags.text = TagManager.makeTagString(noteid: selectedNote.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applyCurrentColor()
        
    }
    
    public func setSelectedNote(note:R_Note) {
        viewModel.selectedNote = note
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.bt_alarm.tintColor = ColorHelper.getCurrentDeepTextColor()
        self.lb_guideTrash.backgroundColor = ColorHelper.getCurrentAppBackground()
    }
    
    @objc func barBtn_more_Action(){
        let alert = UIAlertController(title: title,
                                      message: NSLocalizedString("More", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        if(true)//self.selectedNote.relatedNotebookId != -1)
        {
            let copyNoteAction = UIAlertAction(title: NSLocalizedString("Copy Note", comment: ""),
                                               style: .default, handler: {result in
                                                
//                                                let realm = try! Realm()
//                                                let newnote = R_Note()
//                                                newnote.title = StringHelper.makeHeaderStringCopied(title: self.tf_title.text!)
//                                                newnote.content = self.tv_content.text!
//                                                newnote.relatedNotebookId = self.notebookArray_[self.pv_notebooks.selectedRow(inComponent: 0)].id
//                                                newnote.isfavorite = self.switch_favorite.isOn
//                                                newnote.id = (realm.objects(R_Note.self).max(ofProperty: "id") as Int? ?? 0) + 1
//                                                newnote.alarmDate = self.alarmDate
//
//                                                try! realm.write {
//                                                    realm.add(newnote)
//                                                }
                                                
                                                self.navigationController?.popViewController(animated: false)
            })
            copyNoteAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(copyNoteAction)
            
            let sendToTrashAction = UIAlertAction(title: NSLocalizedString("Send To Trash", comment: ""),
                                                  style: .default, handler: {result in
//                                                    let realm = try! Realm()
//
//                                                    try! realm.write {
//                                                        self.selectedNote.oldNotebookId = self.selectedNote.relatedNotebookId
//                                                        self.selectedNote.relatedNotebookId = -1
//                                                    }
                                                    self.navigationController?.popViewController(animated: false)
            })
            sendToTrashAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(sendToTrashAction)
        }
        else
        {
            let restoreAction = UIAlertAction(title: NSLocalizedString("Restore", comment: ""),
                                              style: .default, handler: {result in
//                                                let realm = try! Realm()
//                                                try! realm.write {
//                                                    self.selectedNote.relatedNotebookId = self.selectedNote.oldNotebookId
//                                                    self.selectedNote.oldNotebookId = -1
//                                                }
                                                self.navigationController?.popViewController(animated: false)
            })
            restoreAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(restoreAction)
            let deleteAction = UIAlertAction(title: NSLocalizedString("Delete Completely", comment: ""),
                                             style: .default, handler: { reuslt in
//                                                let realm = try! Realm()
//                                                try! realm.write {
//                                                    realm.delete(self.selectedNote)
//                                                }
                                                self.navigationController?.popViewController(animated: false)
            })
            deleteAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(deleteAction)
        }
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel, handler: nil)
        cancelAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
            textView.text = NSLocalizedString("Content", comment: "")
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
    
    @IBAction func tf_tag_EndEditing(_ sender: Any) {
        saveChangedData()
    }
    
    func saveChangedData() {
//        let realm = try! Realm()
//
//        try! realm.write {
//            notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].updated_at = Date()
//
//            selectedNote.title = self.tf_title.text!
//            selectedNote.content = self.tv_content.text
//            selectedNote.isfavorite = self.switch_favorite.isOn
//            selectedNote.relatedNotebookId = notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].id
//            selectedNote.updated_at = Date()
//            selectedNote.alarmDate = self.alarmDate
//            selectedNote.alarmIdentifier = self.alarmIdentifier
//        }
//
//        self.lb_updatedAt.text = dateformatter.string(from: selectedNote.updated_at)
//
//        _ = TagManager.addTagsToNote(noteid: selectedNote.id, tagString: self.tf_tags.text)
//
//        self.chekcAlarmState()
    }
    
    func chekcAlarmState(){
        if(self.alarmDate == nil)
        {
            self.bt_alarm.setTitle(NSLocalizedString("Unset", comment: ""), for: .normal)
        }
        else
        {
            self.bt_alarm.setTitle(NSLocalizedString("Set", comment: ""), for: .normal)
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
        if(self.alarmDate != nil) {
            datePicker.setDate(self.alarmDate!, animated: false)
        }
        
        let alarmAlert = UIAlertController(title: NSLocalizedString("\n\n\n\n\n\n\n\n\n\n\nAlarm Setting", comment: ""), message: nil, preferredStyle: .actionSheet)
        alarmAlert.view.addSubview(datePicker)
        
        if(self.alarmDate == nil)
        {
            let setAction = UIAlertAction(title: NSLocalizedString("Set", comment: ""), style: .default) { (action) in
              
                let addResult = self.eventHelper?.addEvent(title: self.tf_title.text!, date: datePicker.date)
                if addResult?.result == false {
                    let alert = UIAlertController(title: self.title,
                                                  message: NSLocalizedString("some problems occurs when registering new alarm.\nplease try again", comment: ""),
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                                     style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                self.alarmDate = datePicker.date
                self.alarmIdentifier = addResult?.identifier
                self.saveChangedData()
            }
            setAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alarmAlert.addAction(setAction)
            
        }else {
            let changeAlarmAction = UIAlertAction(title: NSLocalizedString("Set Alarm", comment: ""), style: .default) { (action) in
                let changeResult = self.eventHelper?.changeAlarm(title: self.tf_title.text!, date: datePicker.date, identifier: self.alarmIdentifier!)
                if changeResult?.result == false {
                    let alert = UIAlertController(title: self.title,
                                                  message: NSLocalizedString("some problems occurs when modifying this alarm.\nplease try again", comment: ""),
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                                     style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.alarmDate = datePicker.date
                self.alarmIdentifier = changeResult?.identifier
                self.saveChangedData()
            }
            changeAlarmAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alarmAlert.addAction(changeAlarmAction)
            
            let unsetAction = UIAlertAction(title: NSLocalizedString("Unset", comment: ""), style: .default) { (action) in
                if self.eventHelper?.removeEvent(identifier: self.alarmIdentifier!) == false {
                    let alert = UIAlertController(title: self.title,
                                                  message: NSLocalizedString("some problems occurs when removing this alarm.\nplease try again", comment: ""),
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "OK",
                                                     style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.alarmDate = nil
                self.alarmIdentifier = ""
                self.saveChangedData()
            }
            unsetAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alarmAlert.addAction(unsetAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cancelAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
        alarmAlert.addAction(cancelAction)
        
        present(alarmAlert, animated: true, completion: nil)
        
    }
}

extension NoteViewController : UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getNotebooks().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.getNotebooks()[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        saveChangedData()
    }
}
