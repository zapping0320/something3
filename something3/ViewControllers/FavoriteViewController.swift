//
//  FavoriteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 16..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "noteFavoriteCell"
    let dateformatter = DateFormatter()
    
    fileprivate var favoriteNotes:[Int:[R_Note]] = [Int:[R_Note]]()
    var searchText_: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let moreBtn = UIBarButtonItem(title: "Edit", style: .plain , target: self, action: #selector(toggleEditing))
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
        navigationItem.rightBarButtonItem?.title = tableview.isEditing ? "Done" : "Edit" // Set title depending on the editing status
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNotes() {
        favoriteNotes = [Int:[R_Note]]()
        
        var notearray_all = [R_Note]()
        
        let realm = try! Realm()
        
        let recentPredicate = NSPredicate(format: "isfavorite = true")
        let recentResults = realm.objects(R_Note.self).filter(recentPredicate).sorted(byKeyPath: "updated_at", ascending: false)
        let itemCount = recentResults.count > 4 ? 3 : recentResults.count - 1
        let notearray_recent = Array(recentResults[0...itemCount])
        
        
        if(self.searchText_ == "")
        {
            let predicate = NSPredicate(format: "isfavorite = true")
            let results = realm.objects(R_Note.self).filter(predicate).sorted(byKeyPath: "updated_at", ascending: false)
            notearray_all = Array(results)
        }
        else
        {
            let predicateSearch = NSPredicate(format: "isfavorite = true AND (title contains %@ OR content contains %@)", self.searchText_,self.searchText_)
            
            let results = realm.objects(R_Note.self).filter(predicateSearch).sorted(byKeyPath: "updated_at", ascending: false)
            notearray_all = Array(results)
        }
        
        favoriteNotes[0] = notearray_recent
        favoriteNotes[1] = notearray_all
        
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
        
        noteVC.selectedNote = favoriteNotes[index.section]![index.row]
    }

}

extension FavoriteViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section > 1 || section < 0){
            return 0
        }else{
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
        var title:String = "Favorite Notes"
        if section == 0 {
            title = "Recent Notes"
        }
        return title
    }
    
    /*
     public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
     let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Note View") as! NoteViewController
     viewController.selectedNotebook = self.selectedNotebook
     viewController.selectedNote = selectedNotebookContents[indexPath.row]
     self.present(viewController, animated: true)
     }
     */
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NoteTableViewCell
        let currentNote = favoriteNotes[indexPath.section]![indexPath.row]
        //cell.textLabel?.text = currentNote.title
        if(currentNote.alarmDate != nil)
        {
            //cell.textLabel?.text = StringHelper.makeHeaderStringAlarmed(title: currentNote.title)
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
            let realm = try! Realm()
            try! realm.write {
                let currentNote = self.favoriteNotes[indexPath.section]![indexPath.row]
                currentNote.isfavorite = false
            }
            loadNotes()
        }
    }
}
