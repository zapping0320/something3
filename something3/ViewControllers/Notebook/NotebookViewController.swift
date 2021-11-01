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
   
    var searchText_: String = ""
    
    private let viewModel = NotebookViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestReminderAccess()
        
        self.sb_searchBar.placeholder = NSLocalizedString("Search Notebooks", comment: "")
        
        loadNotebooks()
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
        self.tableview.reloadData()
    }
    
    @IBAction func addNotebookAction(_ sender: Any) {
        let addNotebookVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addNotebook") as! AddNotebookViewController
  
        addNotebookVC.dataChanged = {
            self.loadNotebooks()
        }
        
        self.present(addNotebookVC, animated: true, completion: nil)
        
    }

}

extension NotebookViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentNoteBook = viewModel.loadNotebooks(searchWord: self.searchText_)[indexPath.section]![indexPath.row] as R_NoteBook
        selectedNotebookId = currentNoteBook.id
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section > 1 || section < 0){
            return 0
        }else{
            let datalist =  viewModel.loadNotebooks(searchWord: self.searchText_)[section] as [R_NoteBook]?
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
        let currentNotebook =  viewModel.loadNotebooks(searchWord: self.searchText_)[indexPath.section]![indexPath.row] as R_NoteBook
        let noteCount = viewModel.getRelatedNoteCount(notebookId: currentNotebook.id)
        cell.textLabel?.text = currentNotebook.name + "(" + String(noteCount) + ")"
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
        
        let selectedNotebook =  viewModel.loadNotebooks(searchWord: self.searchText_)[index.section]![index.row] as R_NoteBook
        contentsVC.selectedNoteBookId = selectedNotebook.id
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let currentNotebook =  viewModel.loadNotebooks(searchWord: self.searchText_)[indexPath.section]![indexPath.row] as R_NoteBook
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
            let currentNotebook =  self.viewModel.loadNotebooks(searchWord: self.searchText_)[indexPath.section]![indexPath.row] as R_NoteBook
            let alert = UIAlertController(title: "", message: NSLocalizedString("Edit Notebook", comment: ""), preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = currentNotebook.name
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { (updateAction) in
                self.viewModel.updateNotebook(id: currentNotebook.id, updatedName: alert.textFields!.first!.text!)
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
                                                let currentNotebook = self.viewModel.loadNotebooks(searchWord: self.searchText_)[indexPath.section]![indexPath.row] as R_NoteBook
                                                self.viewModel.deleteNotebook(id: currentNotebook.id)
                                                
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
                    let currentNotebook = self.viewModel.loadNotebooks(searchWord: self.searchText_)[indexPath.section]![indexPath.row] as R_NoteBook
                    self.viewModel.deleteNotebook(id: currentNotebook.id)
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
