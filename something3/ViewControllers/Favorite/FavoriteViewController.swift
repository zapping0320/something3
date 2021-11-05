//
//  FavoriteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 16..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit


class FavoriteViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    
    let cellIdentifier: String = "noteFavoriteCell"
    let dateformatter = DateFormatter()
    fileprivate var favoriteNotes:[Int:[R_Note]] = [Int:[R_Note]]()
    var searchText_: String = ""
    
    private let viewModel = FavoriteViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let moreBtn = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: .plain , target: self, action: #selector(toggleEditing))
        self.navigationItem.rightBarButtonItem = moreBtn
        
        loadNotes()
    }
    
    func initSearchInfo() {
        self.sb_searchBar.text = ""
        self.searchText_ = ""
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        self.initSearchInfo()
        self.loadNotes()
        applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.navigationItem.rightBarButtonItem?.tintColor = ColorHelper.getIdentityColor()
    }
    
    @objc private func toggleEditing() {
        tableview.setEditing(!tableview.isEditing, animated: true) // Set opposite value of current editing status
        navigationItem.rightBarButtonItem?.title = tableview.isEditing ? NSLocalizedString("Done", comment: "") : NSLocalizedString("Edit", comment: "")// Set title depending on the editing status
    }
    
    func loadNotes() {
        self.tableview?.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchText_ = searchText
        loadNotes()
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
        
        
        noteVC.setSelectedNote(note: favoriteNotes[index.section]![index.row])
    }

}

extension FavoriteViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section > 1 || section < 0){
            return 0
        }else{
            let favoriteNotes = viewModel.loadNotes(searchWord: self.searchText_)
            let datalist = favoriteNotes[section] as [R_Note]?
            if datalist != nil {
                return datalist!.count
            }
            else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String = NSLocalizedString("Favorite Notes", comment: "")
        if section == 0 {
            title = NSLocalizedString("Recent Notes", comment: "")
        }
        return title
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NoteTableViewCell
        let currentNote = viewModel.loadNotes(searchWord: self.searchText_)[indexPath.section]![indexPath.row]
        if(currentNote.alarmDate != nil)
        {
            cell.labelTitle?.text = StringHelper.makeHeaderStringAlarmed(title: currentNote.title)
        }
        else
        {
            cell.labelTitle?.text  = currentNote.title
        }
        
        cell.labelContent?.text = currentNote.content
        
        cell.labelDate?.text =  dateformatter.string(from: currentNote.updated_at)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let currentNote = viewModel.loadNotes(searchWord: self.searchText_)[indexPath.section]![indexPath.row]
            self.viewModel.setNoteUnfavorite(note: currentNote)

            loadNotes()
        }
    }
}
