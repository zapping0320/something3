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

class AddNoteViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,UITextViewDelegate {
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var tv_content: UITextView!
    @IBOutlet weak var pv_notebooks: UIPickerView!
    @IBOutlet weak var switch_favorite: UISwitch!
    @IBOutlet weak var switch_alarm: UISwitch!
    @IBOutlet weak var bt_alarm: UIButton!
    @IBOutlet weak var btn_SaveNote: UIButton!
    
    var eventHelper:EventHelper?
    
    fileprivate var notebookArray_ = [R_NoteBook]()
    var alarmDate:Date?
    var alarmIdentifier:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.eventHelper == nil {
            self.eventHelper = EventHelper()
        }
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
        applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.btn_SaveNote.backgroundColor = ColorHelper.getCurrentMainButtonColor()
        self.bt_alarm.tintColor = ColorHelper.getCurrentDeepTextColor()
    }
    
    func loadNotebooks() {
        notebookArray_ = [R_NoteBook]()
        
        let realm = try! Realm()
        let results = realm.objects(R_NoteBook.self)
        print(results.count)
        if(results.count ==  0)
        {
            let newid = (realm.objects(R_NoteBook.self).max(ofProperty: "id") as Int? ?? 0) + 1
            
            let newnotebook = R_NoteBook()
            newnotebook.name = "Anonymous"
            newnotebook.id = newid
            
            try! realm.write {
                realm.add(newnotebook)
            }
            
            notebookArray_.append(newnotebook)
        }
        else
        {
            for i in 0..<results.count {
                let item = results[i]
                notebookArray_.append(item)
            }
        }
        self.pv_notebooks.reloadAllComponents()
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
        newnote.alarmDate = self.alarmDate
        newnote.alarmIdentifier = self.alarmIdentifier
      
        try! realm.write {
            realm.add(newnote)
            
            notebookArray_[pv_notebooks.selectedRow(inComponent: 0)].updated_at = Date()
            
        }
        
        self.tf_title.text = ""
        self.tv_content.text = ""
        
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func bt_alarm_action(_ sender: UIButton) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        if(self.alarmDate != nil) {
            datePicker.setDate(self.alarmDate!, animated: false)
        }
        
        let alarmAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\nAlarm Setting", message: nil, preferredStyle: .actionSheet)
        alarmAlert.view.addSubview(datePicker)
        /*
         datePicker.snp.makeConstraints { (make) in
         make.centerX.equalTo(alert.view)
         make.top.equalTo(alert.view).offset(8)
         }*/
        
        
        
        if(self.alarmDate == nil)
        {
            let setAction = UIAlertAction(title: "설정", style: .default) { (action) in
                
                let addResult = self.eventHelper?.addEvent(title: self.tf_title.text!, date: datePicker.date)
                if addResult?.result == false {
                    let alert = UIAlertController(title: self.title,
                                                  message: "some problems occurs when registering new alarm.\nplease try again",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "OK",
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
            let changeAlarmAction = UIAlertAction(title: "알람변경", style: .default) { (action) in
                let changeResult = self.eventHelper?.changeAlarm(title: self.tf_title.text!, date: datePicker.date, identifier: self.alarmIdentifier!)
                if changeResult?.result == false {
                    let alert = UIAlertController(title: self.title,
                                                  message: "some problems occurs when modifying this alarm.\nplease try again",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "OK",
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
            
            let unsetAction = UIAlertAction(title: "설정해제", style: .default) { (action) in
                if self.eventHelper?.removeEvent(identifier: self.alarmIdentifier!) == false {
                    let alert = UIAlertController(title: self.title,
                                                  message: "some problems occurs when removing this alarm.\nplease try again",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    
                    let cancelAction = UIAlertAction(title: "OK",
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cancelAction.setValue(ColorHelper.getCancelColor(), forKey: "titleTextColor")
        alarmAlert.addAction(cancelAction)
        
        present(alarmAlert, animated: true, completion: nil)
        
    }
    
    func chekcAlarmState(){
        if(self.alarmDate == nil)
        {
            self.bt_alarm.setTitle("미설정", for: .normal)
        }
        else
        {
            self.bt_alarm.setTitle("설정됨", for: .normal)
        }
    }
    
}
