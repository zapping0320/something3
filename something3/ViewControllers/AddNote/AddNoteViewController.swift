//
//  AddNoteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 10..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift
import EventKit

class AddNoteViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var tf_tags: UITextField!
    @IBOutlet weak var tv_content: UITextView!
    @IBOutlet weak var pv_notebooks: UIPickerView!
    @IBOutlet weak var switch_favorite: UISwitch!
    @IBOutlet weak var switch_alarm: UISwitch!
    @IBOutlet weak var bt_alarm: UIButton!
    @IBOutlet weak var btn_SaveNote: UIButton!
    
    var eventHelper:EventHelper?
    
    private let viewModel = AddNoteViewModel()
    
   // fileprivate var notebookArray_ = [R_NoteBook]()
    var alarmDate:Date?
    var alarmIdentifier:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.eventHelper == nil {
            self.eventHelper = EventHelper()
        }
        self.tf_title.placeholder = NSLocalizedString("Title", comment: "")
        self.tf_tags.placeholder = TagManager.tagPlaceHolderString
        self.tv_content.delegate = self
        self.tv_content.text = NSLocalizedString("Content", comment: "")
        self.tv_content.textColor = UIColor.lightGray
        //loadNotebooks()
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
        clearInputFields()
        //loadNotebooks()
//        if notebookArray_.count > 0 {
//            for i in 0..<notebookArray_.count {
//                let notebook = notebookArray_[i]
//                if(notebook.id == selectedNotebookId)
//                {
//                    self.pv_notebooks.selectRow(i, inComponent: 0, animated: false)
//                    break
//                }
//            }
//        }
        applyCurrentColor()
    }
    
    func clearInputFields() {
        self.tf_title.text = ""
        self.tf_tags.text = ""
        self.tv_content.text = ""
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.btn_SaveNote.backgroundColor = ColorHelper.getCurrentMainButtonColor()
        self.bt_alarm.tintColor = ColorHelper.getCurrentDeepTextColor()
    }
    
//    func loadNotebooks() {
//        notebookArray_ = [R_NoteBook]()
//
//        let realm = try! Realm()
//        let results = realm.objects(R_NoteBook.self)
//        //print(results.count)
//        if(results.count ==  0)
//        {
//            let newid = (realm.objects(R_NoteBook.self).max(ofProperty: "id") as Int? ?? 0) + 1
//
//            let newnotebook = R_NoteBook()
//            newnotebook.name = NSLocalizedString("Anonymous", comment: "")
//            newnotebook.id = newid
//
//            try! realm.write {
//                realm.add(newnotebook)
//            }
//
//            notebookArray_.append(newnotebook)
//        }
//        else
//        {
//            for i in 0..<results.count {
//                let item = results[i]
//                notebookArray_.append(item)
//            }
//        }
//        self.pv_notebooks.reloadAllComponents()
//    }

    
    @IBAction func btn_save_action(_ sender: UIButton) {
        if(self.tf_title.text == "" && self.tv_content.text == "")
        {
            let alert = UIAlertController(title: title,
                                          message: NSLocalizedString("you entered no text, please check", comment: ""),
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let realm = try! Realm()
        let newnote = R_Note()
        newnote.title = self.tf_title.text!
        newnote.content = self.tv_content.text!
       // newnote.relatedNotebookId = notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].id
        newnote.isfavorite = self.switch_favorite.isOn
        newnote.id = (realm.objects(R_Note.self).max(ofProperty: "id") as Int? ?? 0) + 1
        newnote.alarmDate = self.alarmDate
        newnote.alarmIdentifier = self.alarmIdentifier
        
        selectedNotebookId = newnote.relatedNotebookId
      
        try! realm.write {
            realm.add(newnote)
            //notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].updated_at = Date()
        }
        //add tags noteid, tags
        _ = TagManager.addTagsToNote(noteid: newnote.id, tagString: self.tf_tags.text)
       
        self.tabBarController?.selectedIndex = 0
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
            let setAction = UIAlertAction(title: NSLocalizedString("Setting", comment: ""), style: .default) { (action) in
                
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
                self.chekcAlarmState()
            }
            setAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alarmAlert.addAction(setAction)
        }else{
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
                self.chekcAlarmState()
            }
            changeAlarmAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alarmAlert.addAction(changeAlarmAction)
            
            let unsetAction = UIAlertAction(title: NSLocalizedString("Unset Alarm", comment: ""), style: .default) { (action) in
                if self.eventHelper?.removeEvent(identifier: self.alarmIdentifier!) == false {
                    let alert = UIAlertController(title: self.title,
                                                  message: NSLocalizedString("some problems occurs when removing this alarm.\nplease try again", comment: ""),
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                                     style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.alarmDate = nil
                self.alarmIdentifier = ""
                self.chekcAlarmState()
            }
            unsetAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alarmAlert.addAction(unsetAction)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
        cancelAction.setValue(ColorHelper.getCancelColor(), forKey: "titleTextColor")
        alarmAlert.addAction(cancelAction)
        
        present(alarmAlert, animated: true, completion: nil)
        
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
    
}

extension AddNoteViewController : UIPickerViewDataSource, UIPickerViewDelegate {
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
        //print(notebookArray_[row].name)
    }
}
