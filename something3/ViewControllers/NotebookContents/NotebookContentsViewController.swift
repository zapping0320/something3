//
//  NotebookContentsViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 11..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit

class NotebookContentsViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var lb_searchResult: UILabel!
    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var button_searchByAlarm: UIButton!
    @IBOutlet weak var button_searchByTag: UIButton!
    
    
    let cellIdentifier: String = "noteCell"
    
    open var selectedNoteBookId: Int = 0
    var searchText_: String = ""
    
    private let viewModel = NotebookContentsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        self.lb_searchResult.isHidden = true
        let moreBtn = UIBarButtonItem(title: NSLocalizedString("More", comment: ""), style: .plain , target: self, action: #selector(barBtn_more_Action))
        self.navigationItem.rightBarButtonItem = moreBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(self.selectedNoteBookId == -1)
        {
            self.button_searchByTag.isEnabled = false
        }
        else
        {
            self.button_searchByTag.isEnabled = true
        }
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
                                      message: NSLocalizedString("More", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        //change sort way
        let sortByNameAction = UIAlertAction(title: NSLocalizedString("SortByName", comment: ""),
                                             style: .default, handler: {result in
                                                self.viewModel.isSortTypeByName = true
                                                self.loadContents()
        })
        sortByNameAction.setValue(ColorHelper.getCancelColor(), forKey: "titleTextColor")
        alert.addAction(sortByNameAction)
        
        let sortByRecentAction = UIAlertAction(title: NSLocalizedString("SortByRecent", comment: ""),
                                               style: .default, handler: {result in
                                                self.viewModel.isSortTypeByName = false
                                                self.loadContents()
        })
        sortByRecentAction.setValue(ColorHelper.getCancelColor(), forKey: "titleTextColor")
        alert.addAction(sortByRecentAction)
        
        if(self.viewModel.isSortTypeByName != true)
        {
            sortByRecentAction.setValue(true, forKey: "checked")
        }
        else
        {
            sortByNameAction.setValue(true, forKey: "checked")
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel, handler: nil)
        if(self.selectedNoteBookId == -1)
        {
            let deleteAllAction = UIAlertAction(title: NSLocalizedString("Empty Trash", comment: ""),
                                                style: .default, handler:
                { reuslt in
                    self.viewModel.deleteTrashNotes()
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
        self.sb_searchBar.placeholder = NSLocalizedString("Search Notes", comment: "")
        loadContents()
    }

    
    func loadContents() {
        
        self.lb_searchResult.isHidden = true
        
        _ = viewModel.getNotes(notebookId: self.selectedNoteBookId, searchWord: self.searchText_)
        
        self.tableview?.reloadData()
        

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
            //noteVC.selectedNote = viewModel.getNotes(notebookId: self.selectedNoteBookId, searchWord: self.searchText_)[index.row]
            noteVC.setSelectedNote(note: viewModel.getNotes(notebookId: self.selectedNoteBookId, searchWord: self.searchText_)[index.row])
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

extension NotebookContentsViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let count = viewModel.getNotes(notebookId: self.selectedNoteBookId, searchWord: self.searchText_).count
        self.lb_searchResult.isHidden = count != 0
        return count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentNote = viewModel.getNotes(notebookId: self.selectedNoteBookId, searchWord: self.searchText_)[indexPath.row]
        cell.textLabel?.text = currentNote.title
        if(currentNote.alarmDate != nil)
        {
            cell.textLabel?.text = StringHelper.makeHeaderStringAlarmed(title: currentNote.title)
        }
        
        cell.detailTextLabel?.text = currentNote.content
        
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
            let note = viewModel.getNotes(notebookId: self.selectedNoteBookId, searchWord: self.searchText_)[indexPath.row]
            self.viewModel.setNoteInitialized(noteId: note.id)
            loadContents()
        }
    }
}
