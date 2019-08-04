//
//  NotebookViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 5..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift
import EventKit

var selectedNotebookId: Int = 0

class NotebookViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var btn_AddNotebook: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var sb_searchBar: UISearchBar!
    
    let cellIdentifier: String = "notebookCell"
    let headerSectionIdendifier: String = "headerSectionCell"
    
    var eventStore: EKEventStore?
    
    fileprivate var notebookArray_:[Int:[R_NoteBook]] = [Int:[R_NoteBook]]()
    var searchText_: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRealmInfo()
        
        requestReminderAccess()
        
        self.sb_searchBar.placeholder = NSLocalizedString("Search Notebooks", comment: "")
        
        loadNotebooks()
    }
    
    func setRealmInfo() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)//only for simulator
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 8,
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    func requestReminderAccess() {
        if self.eventStore == nil {
            self.eventStore = EKEventStore()
            self.eventStore!.requestAccess(to: EKEntityType.reminder, completion: { (isAccessible, errors) in })
        }
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        initSearchInfo()
        loadNotebooks()
        applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.btn_AddNotebook.backgroundColor = ColorHelper.getCurrentMainButtonColor()
    }
    
    
    func initSearchInfo() {
        self.sb_searchBar.text = ""
        self.searchText_ = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchText_ = searchText
        loadNotebooks()
    }
    
    @IBAction func tapToHideKeyboard(_ sender: UITapGestureRecognizer) {
        self.sb_searchBar.resignFirstResponder()
        sender.cancelsTouchesInView = false
    }
    
    func loadNotebooks() {
        notebookArray_ = [Int:[R_NoteBook]]()
        
        var notebookarray_recent = [R_NoteBook]()
        var notebookarray_all = [R_NoteBook]()
        
        let realm = try! Realm()
        if(self.searchText_ == "")
        {
            let recentResults = realm.objects(R_NoteBook.self).sorted(byKeyPath: "updated_at", ascending: false)
            let recentCount = recentResults.count > 5 ? 4 : recentResults.count
            for i in 0..<recentCount {
                let item = recentResults[i]
                notebookarray_recent.append(item)
            }
            
            let allResults = realm.objects(R_NoteBook.self).sorted(byKeyPath: "name", ascending: true)
            for i in 0..<allResults.count {
                let item = allResults[i]
                notebookarray_all.append(item)
            }
            
            let trashCan = R_NoteBook()
            trashCan.name = "Trash"
            trashCan.id = -1
            notebookarray_all.append(trashCan)
        }
        else
        {
            let predicateSearch = NSPredicate(format: "name contains %@", self.searchText_)
            let results = realm.objects(R_NoteBook.self).filter(predicateSearch).sorted(byKeyPath: "updated_at", ascending: false)
            notebookarray_all = Array(results)
        }
        
        notebookArray_[0] = notebookarray_recent
        notebookArray_[1] = notebookarray_all
        
        self.tableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NotebookViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentNoteBook = notebookArray_[indexPath.section]![indexPath.row] as R_NoteBook
        selectedNotebookId = currentNoteBook.id
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section > 1 || section < 0){
            return 0
        }else{
            let datalist = notebookArray_[section] as [R_NoteBook]?
            if datalist != nil {
                return datalist!.count
            }
            else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentNotebook = notebookArray_[indexPath.section]![indexPath.row] as R_NoteBook
        let realm = try! Realm()
        let predicate = NSPredicate(format: "relatedNotebookId = %@",  NSNumber(value: currentNotebook.id))
        let results = realm.objects(R_Note.self).filter(predicate)
        cell.textLabel?.text = currentNotebook.name + "(" + String(results.count) + ")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String = NSLocalizedString("All Notebooks", comment: "")
        if section == 0 {
            title = NSLocalizedString("Recent Notebooks", comment: "")
        }
        return title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let contentsVC : NotebookContentsViewController = segue.destination as? NotebookContentsViewController
            else {
                return
            }
        
        guard let cell:UITableViewCell = sender as? UITableViewCell else {
            return
        }
        
        guard  let index:IndexPath = self.tableview.indexPath(for: cell)  else {
            return
        }
        
        let selectedNotebook = notebookArray_[index.section]![index.row] as R_NoteBook
        contentsVC.selectedNoteBookId = selectedNotebook.id
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let currentNotebook = notebookArray_[indexPath.section]![indexPath.row] as R_NoteBook
        if(currentNotebook.id != -1)
        {
            return true
        }
        else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let editAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: ""), handler: { (action, indexPath) in
            let currentNotebook = self.notebookArray_[indexPath.section]![indexPath.row] as R_NoteBook
            let alert = UIAlertController(title: "", message: NSLocalizedString("Edit Notebook", comment: ""), preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = currentNotebook.name
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { (updateAction) in
                let realm = try! Realm()
                try! realm.write {
                    currentNotebook.name = alert.textFields!.first!.text!
                    currentNotebook.updated_at = Date()
                }
                self.loadNotebooks()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: ""), handler: { (action, indexPath) in
            let alert = UIAlertController(title: NSLocalizedString("Delete", comment: ""),
                                          message: NSLocalizedString("Are you sure want to delete this notebook?", comment: ""),
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                          style: .default, handler:
                { action in
                    let currentNotebook = self.notebookArray_[indexPath.section]![indexPath.row] as R_NoteBook
                    let realm = try! Realm()
                    try! realm.write {
                        
                        let predicate = NSPredicate(format: "relatedNotebookId = %@",  NSNumber(value: currentNotebook.id))
                        for note in realm.objects(R_Note.self).filter(predicate){
                            note.relatedNotebookId = -1
                            note.oldNotebookId = currentNotebook.id
                        }
                        realm.delete(currentNotebook)
                    }
                    self.loadNotebooks()
            }
            )
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""),
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        
            tableView.reloadData()
        })
        
        return [deleteAction, editAction]
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            let alert = UIAlertController(title: title,
                                          message: NSLocalizedString("Are you sure want to delete this notebook?", comment: ""),
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                          style: .default, handler:
                { action in
                    let currentNotebook = self.notebookArray_[indexPath.section]![indexPath.row] as R_NoteBook
                    let realm = try! Realm()
                    try! realm.write {
                        
                        let predicate = NSPredicate(format: "relatedNotebookId = %@",  NSNumber(value: currentNotebook.id))
                        for note in realm.objects(R_Note.self).filter(predicate){
                            note.relatedNotebookId = -1
                            note.oldNotebookId = currentNotebook.id
                        }
                        realm.delete(currentNotebook)
                    }
                    self.loadNotebooks()
                }
            )
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""),
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

}
