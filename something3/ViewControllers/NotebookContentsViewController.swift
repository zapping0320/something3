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

    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "noteCell"
    let sortTypeByName : String = "ByName"
    let sortTypeByRecent : String = "ByRecent"
    
    fileprivate var selectedNotebookContents:[R_Note] = [R_Note]()
    //open var selectedNotebook:R_NoteBook = R_NoteBook()
    open var selectedNoteBookId: Int = 0
    var searchText_: String = ""
    var sortType_: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadContents()
        self.sortType_ = self.sortTypeByRecent
        let moreBtn = UIBarButtonItem(title: "More", style: .plain , target: self, action: #selector(barBtn_more_Action))
        self.navigationItem.rightBarButtonItem = moreBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        //self.navigationItem.leftBarButtonItem?.tintColor = ColorHelper.getIdentityColor()
        self.navigationItem.rightBarButtonItem?.tintColor = ColorHelper.getIdentityColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
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
        alert.addAction(sortByNameAction)
        
        let sortByRecentAction = UIAlertAction(title: "SortByRecent",
                                               style: .default, handler: {result in
                                                self.sortType_ = self.sortTypeByRecent
                                                self.loadContents()
        })
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
            
            alert.addAction(deleteAllAction)
        }
        //alert.addAction(restoreAction)
       
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        searchText_ = ""
        loadContents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContents() {
        selectedNotebookContents = [R_Note]()
        
        let realm = try! Realm()
        var andPredicate:NSCompoundPredicate
        let predicateNotebookId = NSPredicate(format: "relatedNotebookId = %@", NSNumber(value: self.selectedNoteBookId))
        if(self.searchText_ == "")
        {
            andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateNotebookId])
        }
        else
        {
             let predicateSearch = NSPredicate(format: "title contains %@ OR content contains %@", self.searchText_, self.searchText_)
            andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateNotebookId, predicateSearch])
        }
       
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
        selectedNotebookContents = Array(results)
        
        self.tableview?.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchText_ = searchText
        loadContents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let noteVC : NoteViewController = segue.destination as? NoteViewController
            else {
                return
        }
        
        guard let cell:UITableViewCell = sender as? UITableViewCell else {
            return
        }
        
        guard  let index:IndexPath = self.tableview?.indexPath(for: cell)  else {
            return
        }
        
        noteVC.selectedNote = selectedNotebookContents[index.row]
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
    
    /*
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }*/
    
    /*
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Note View") as! NoteViewController
        viewController.selectedNotebook = self.selectedNotebook
        viewController.selectedNote = selectedNotebookContents[indexPath.row]
        self.present(viewController, animated: true)
    }
    */
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        /*
        let cell:NoteContentCell = self.tableview.dequeueReusableCell(withIdentifier: "NoteContentCell", for: indexPath) as! NoteContentCell
        
        let currentitem = selectedNotebookContents[indexPath.row]
        //print(indexPath.row)
        //print(currentitem.name)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        cell.label_datetime?.text = dateformatter.string(from: currentitem.updated_at)
        cell.label_title?.text = currentitem.title
        cell.label_content?.text = currentitem.content
        
        return cell
        */
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentNote = selectedNotebookContents[indexPath.row]
        cell.textLabel?.text = currentNote.title
        if(currentNote.alarmDate != nil)
        {
            cell.textLabel?.text = currentNote.title + String("(alarmed)")
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
                
                /*
                 tableView.beginUpdates()
                 tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                 tableView.endUpdates()*/
            }
            loadContents()
        }
    }
}
