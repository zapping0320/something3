//
//  NotebookViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 5..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

var selectedNotebookId: Int = 0

class NotebookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier: String = "notebookCell"
    let headerSectionIdendifier: String = "headerSectionCell"
    @IBOutlet weak var tableview: UITableView!
    
    
    fileprivate var notebookArray_:[Int:[R_NoteBook]] = [Int:[R_NoteBook]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(Realm.Configuration.defaultConfiguration.fileURL!)//only for simulator
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
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
        loadNotebooks()
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        loadNotebooks()
    }
    
    func loadNotebooks() {
        notebookArray_ = [Int:[R_NoteBook]]()
        
        var notebookarray_recent = [R_NoteBook]()
        var notebookarray_all = [R_NoteBook]()
        
        let realm = try! Realm()
        let results = realm.objects(R_NoteBook.self).sorted(byKeyPath: "updated_at", ascending: true)
        //print(results.count)
        for i in 0..<results.count {
            let item = results[i]
            notebookarray_all.append(item)
            if(i >= results.count - 5)//pick last modified data 5 dd
            {
                notebookarray_recent.insert(item, at: 0)
            }
        }
        
        let trashCan = R_NoteBook()
        trashCan.name = "Trash"
        trashCan.id = -1
        notebookarray_all.append(trashCan)
        
        notebookArray_[0] = notebookarray_recent
        notebookArray_[1] = notebookarray_all
        
        self.tableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NotebookViewController {
    
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
        cell.textLabel?.text = currentNotebook.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String = "All Notebooks"
        if section == 0 {
            title = "Recent Notebooks"
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

}
