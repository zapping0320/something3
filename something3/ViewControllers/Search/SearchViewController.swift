//
//  SearchViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 26..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var lb_searchResult: UILabel!
    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    let cellIdentifier: String = "searchedNoteCell"
    
    var searchText_: String = ""
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sb_searchBar.placeholder = NSLocalizedString("Search Notes", comment: "")
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
            let keywords = viewModel.getKeywords()
            if keywords.count == 0 {
                lb_searchResult.isHidden = false
            }
        }
        else
        {
            self.loadNotes()
        }
        
        self.tableview?.reloadData()
    }
   
    
    func loadNotes() {

        viewModel.loadNotes(searchKeyword: self.searchText_)
        let results = viewModel.getNotes()
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
        SearchKeywordHelper.updateKeywordList(keyword: self.sb_searchBar.text!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.searchText_.isEmpty {
            return
        }
        
        
        guard let noteVC : NoteViewController = segue.destination as? NoteViewController else {
            return
        }
        
        guard let cell:UITableViewCell = sender as? UITableViewCell else {
            return
        }
        
        guard  let index:IndexPath = self.tableview?.indexPath(for: cell)  else {
            return
        }
        
        noteVC.setSelectedNote(note: viewModel.getNotes()[index.row])
        
    }

}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return viewModel.getItemCount()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchText_ == "" {
                return NSLocalizedString("Keywords", comment: "")
        } else {
            return NSLocalizedString("Notes", comment: "")
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if self.searchText_ == "" {
            let keyword = viewModel.getKeywords()
            if(indexPath.row > keyword.count - 1){
                return UITableViewCell()
            }
            cell.textLabel?.text = keyword[indexPath.row]
        }
        else {
            let notes = viewModel.getNotes()
            if(indexPath.row > notes.count - 1){
                return UITableViewCell()
            }
            
            let currentNote = notes[indexPath.row]
            cell.textLabel?.text = currentNote.title
            if(currentNote.alarmDate != nil)
            {
                cell.textLabel?.text = StringHelper.makeHeaderStringAlarmed(title: currentNote.title)
            }
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let currentNote = self.viewModel.getNotes()[indexPath.row]
            self.viewModel.setNoteUnfavorite(note: currentNote)
            loadNotes()
        }
    }
}
