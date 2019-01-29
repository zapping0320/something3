//
//  NotebookContentsViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 11..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class NotebookContentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var lb_searchResult: UILabel!
    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "noteCell"
    let sortTypeByName : String = "ByName"
    let sortTypeByRecent : String = "ByRecent"
    
    @IBOutlet weak var button_searchByAlarm: UIButton!
    @IBOutlet weak var button_searchByTag: UIButton!
    fileprivate var selectedNotebookContents:[R_Note] = [R_Note]()
    open var selectedNoteBookId: Int = 0
    var searchText_: String = ""
    var sortType_: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lb_searchResult.isHidden = true
        self.sortType_ = self.sortTypeByRecent
        let moreBtn = UIBarButtonItem(title: "More", style: .plain , target: self, action: #selector(barBtn_more_Action))
        self.navigationItem.rightBarButtonItem = moreBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.navigationController?.navigationBar.tintColor = ColorHelper.getIdentityColor()
        self.navigationItem.rightBarButtonItem?.tintColor = ColorHelper.getIdentityColor()
    }
    
    @IBAction func tapToHideKeyboard(_ sender: UITapGestureRecognizer) {
        self.sb_searchBar.resignFirstResponder()
        sender.cancelsTouchesInView = false
    }
    
    @objc func barBtn_more_Action(){
        let alert = UIAlertController(title: title,
                                      message: "more",
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        //change sort way
        let sortByNameAction = UIAlertAction(title: "SortByName",
                                             style: .default, handler: {result in
                                                self.sortType_ = self.sortTypeByName
                                                self.loadContents()
        })
        sortByNameAction.setValue(ColorHelper.getCancelColor(), forKey: "titleTextColor")
        alert.addAction(sortByNameAction)
        
        let sortByRecentAction = UIAlertAction(title: "SortByRecent",
                                               style: .default, handler: {result in
                                                self.sortType_ = self.sortTypeByRecent
                                                self.loadContents()
        })
        sortByRecentAction.setValue(ColorHelper.getCancelColor(), forKey: "titleTextColor")
        alert.addAction(sortByRecentAction)
        
        if(self.sortType_ == self.sortTypeByRecent)
        {
            sortByRecentAction.setValue(true, forKey: "checked")
        }
        else
        {
            sortByNameAction.setValue(true, forKey: "checked")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel, handler: nil)
        if(self.selectedNoteBookId == -1)
        {
            let deleteAllAction = UIAlertAction(title: "Empty Trash",
                                                style: .default, handler:
                { reuslt in
                    let realm = try! Realm()
                    try! realm.write {
                        let predicate = NSPredicate(format: "relatedNotebookId = -1")
                        for note in realm.objects(R_Note.self).filter(predicate){
                            realm.delete(note)
                        }
                    }
                    self.navigationController?.popViewController(animated: false)
            })
            deleteAllAction.setValue(ColorHelper.getCancelColor(), forKey: "titleTextColor")
            alert.addAction(deleteAllAction)
        }
        
        cancelAction.setValue(ColorHelper.getCancelColor(), forKey: "titleTextColor")
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        searchText_ = ""
        self.sb_searchBar.placeholder = "Search Note"
        loadContents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContents() {
        selectedNotebookContents = [R_Note]()
        
        self.lb_searchResult.isHidden = true
        
        let realm = try! Realm()
        
        let predicateNotebookId = NSPredicate(format: "relatedNotebookId = %@", NSNumber(value: self.selectedNoteBookId))
        var predicateList = [NSPredicate]()
        predicateList.append(predicateNotebookId)

        if(self.searchText_ != "")
        {
             let predicateSearch = NSPredicate(format: "title contains %@ OR content contains %@", self.searchText_, self.searchText_)

             predicateList.append(predicateSearch)
        }
        
        if(self.button_searchByAlarm.isSelected == true)
        {
            let predicateAlarm = NSPredicate(format: "alarmDate != nil ")
            predicateList.append(predicateAlarm)
        }
        
        let andPredicate:NSCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateList)
        
        var sortField : String = ""
        var sortAscending: Bool = false
        if(sortType_ == self.sortTypeByName)
        {
            sortField = "title"
            sortAscending = true
        }
        else
        {
            sortField = "updated_at"
            sortAscending = false
        }
        let results = realm.objects(R_Note.self).filter(andPredicate).sorted(byKeyPath: sortField, ascending: sortAscending)
        
        
        let predicateNotebook = NSPredicate(format: "id = %@", NSNumber(value:self.selectedNoteBookId))
        let notebookResults = realm.objects(R_NoteBook.self).filter(predicateNotebook)
        if(notebookResults.count > 0)
        {
            let currentNotebook = notebookResults[0]
            if(currentNotebook.searchTags != "")
            {
                let predicateTagString = String.localizedStringWithFormat("tagId in { %@ } ", currentNotebook.searchTags)
                let predicateTag = NSPredicate(format: predicateTagString)
                let relationResults = realm.objects(R_NoteTagRelations.self).filter(predicateTag)
            }
        }
        
        selectedNotebookContents = Array(results)
        
        self.tableview?.reloadData()
        
        if(results.count == 0)
        {
            self.lb_searchResult.isHidden = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchText_ = searchText
        loadContents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NoteDetail" {
            guard let cell:UITableViewCell = sender as? UITableViewCell else {
                return
            }
            
            guard  let index:IndexPath = self.tableview?.indexPath(for: cell)  else {
                return
            }
            
            guard let noteVC : NoteViewController = segue.destination as? NoteViewController
                else {
                    return
            }
            noteVC.selectedNote = selectedNotebookContents[index.row]
        }
        else if segue.identifier == "TagFilter" {
            guard let tagFilterVC : TagFilterViewController = segue.destination as? TagFilterViewController
                else {
                    return
            }
            tagFilterVC.selectedNoteBookId = self.selectedNoteBookId
        }
    }
    
    @IBAction func button_FilterAlarmNotes(_ sender: Any) {
        self.button_searchByAlarm.isSelected = !self.button_searchByAlarm.isSelected
        self.loadContents()
    }
    @IBAction func buutonFilterTag(_ sender: UIButton) {
        self.loadContents()
    }
}

extension NotebookContentsViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selectedNotebookContents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentNote = selectedNotebookContents[indexPath.row]
        cell.textLabel?.text = currentNote.title
        if(currentNote.alarmDate != nil)
        {
            cell.textLabel?.text = StringHelper.makeHeaderStringAlarmed(title: currentNote.title)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(self.selectedNoteBookId != -1)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let realm = try! Realm()
            try! realm.write {
                selectedNotebookContents[indexPath.row].relatedNotebookId = -1
                selectedNotebookContents[indexPath.row].oldNotebookId = self.selectedNoteBookId
            }
            loadContents()
        }
    }
}
