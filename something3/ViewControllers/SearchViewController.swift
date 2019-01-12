//
//  SearchViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 26..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var lb_searchResult: UILabel!
    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "searchedNoteCell"
    
    
    var searchedNotes:[R_Note] = [R_Note]()
    var keywordList:[String] = [String]()
    var searchText_: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sb_searchBar.placeholder = "Search Note"
        self.loadContents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadContents()
        self.applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
    }
    
    func initSearchInfo() {
        self.sb_searchBar.text = ""
        self.searchText_ = ""
    }
    
    @IBAction func tapToHideKeyboard(_ sender: UITapGestureRecognizer) {
        self.sb_searchBar.resignFirstResponder()
        sender.cancelsTouchesInView = false
    }
    
    func loadContents()
    {
        self.lb_searchResult.isHidden = true
        
        if(self.searchText_ == "")
        {
           self.loadKeywords()
        }
        else
        {
            self.loadNotes()
        }
        
        self.tableview?.reloadData()
    }
    
    func loadKeywords() {
        self.keywordList = SearchKeywordelper.getKeywordList()
        
        if self.keywordList.count == 0 {
            lb_searchResult.isHidden = false
        }
    }
    
    func loadNotes() {
        self.searchedNotes = [R_Note]()
        
        let realm = try! Realm()
        let predicateSearch = NSPredicate(format: "title contains %@ OR content contains %@", self.searchText_, self.searchText_)
        let results = realm.objects(R_Note.self).filter(predicateSearch).sorted(byKeyPath: "updated_at", ascending: false)
        self.searchedNotes = Array(results)
        
        if(results.count == 0)
        {
            lb_searchResult.isHidden = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText_ = searchText
        self.loadContents()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SearchKeywordelper.updateKeywordList(keyword: self.sb_searchBar.text!)
        //move result view
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.searchText_ == "" {
            
        }
        else {
            
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
            
            noteVC.selectedNote = searchedNotes[index.row]
        }
    }

}

extension SearchViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.searchText_ == "" {
            return self.keywordList.count
        } else {
            return searchedNotes.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchText_ == "" {
                return "Keywords"
        } else {
            return "Notes"
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if self.searchText_ == "" {
            if(indexPath.row > self.keywordList.count - 1){
                return UITableViewCell()
            }
            cell.textLabel?.text = self.keywordList[indexPath.row]
        }
        else {
            
            if(indexPath.row > searchedNotes.count - 1){
                return UITableViewCell()
            }
            
            let currentNote = searchedNotes[indexPath.row]
            cell.textLabel?.text = currentNote.title
            if(currentNote.alarmDate != nil)
            {
                cell.textLabel?.text = currentNote.title + String("(alarmed)")
            }
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let realm = try! Realm()
            try! realm.write {
                let currentNote = self.searchedNotes[indexPath.row]
                currentNote.isfavorite = false
            }
            loadNotes()
        }
    }
}
