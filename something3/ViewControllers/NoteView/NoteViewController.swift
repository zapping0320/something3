//
//  NoteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 12..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit

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
        guard let selectedNote = viewModel.selectedNote else { return }
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
        
        self.tf_title.text = selectedNote.title
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
        
        chekcAlarmState()
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
        if(viewModel.selectedNote?.relatedNotebookId != -1)
        {
            let copyNoteAction = UIAlertAction(title: NSLocalizedString("Copy Note", comment: ""),
                                               style: .default, handler: {result in
                                                self.viewModel.copyNote(title: StringHelper.makeHeaderStringCopied(title: self.tf_title.text!), content: self.tv_content.text!, relatedNotebookId: self.viewModel.getNotebooks()[self.pv_notebooks.selectedRow(inComponent: 0)].id, isFavorite: self.switch_favorite.isOn, alarmDate: self.alarmDate)
                                                self.navigationController?.popViewController(animated: false)
            })
            copyNoteAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(copyNoteAction)
            
            let sendToTrashAction = UIAlertAction(title: NSLocalizedString("Send To Trash", comment: ""),
                                                  style: .default, handler: {result in
                                                    self.viewModel.setNoteInitialized()
                                                    self.navigationController?.popViewController(animated: false)
            })
            sendToTrashAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(sendToTrashAction)
        }
        else
        {
            let restoreAction = UIAlertAction(title: NSLocalizedString("Restore", comment: ""),
                                              style: .default, handler: {result in
                                                self.viewModel.restoreNotebookInfo()
                                                self.navigationController?.popViewController(animated: false)
            })
            restoreAction.setValue(ColorHelper.getIdentityColor(), forKey: "titleTextColor")
            alert.addAction(restoreAction)
            let deleteAction = UIAlertAction(title: NSLocalizedString("Delete Completely", comment: ""),
                                             style: .default, handler: { reuslt in
                                                self.viewModel.deleteNote()
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
        let note = getUIData()
        
        viewModel.updateNote(updatedNote: note)
        viewModel.addTags(tagString: self.tf_tags.text ?? "")
        
        updateUI()

    }
    
    func getUIData() -> R_Note {
        let note = R_Note()
        note.title = self.tf_title.text!
        note.content = self.tv_content.text
        note.isfavorite = self.switch_favorite.isOn
        note.relatedNotebookId = viewModel.getNotebooks()[pv_notebooks.selectedRow(inComponent: 0)].id
        note.alarmDate = self.alarmDate
        note.alarmIdentifier = self.alarmIdentifier
        
        return note
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
