//
//  ManageTagsViewController.swift
//  something3
//
//  Created by 김동현 on 31/12/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class ManageTagsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "tagCell"
    var searchText_: String = ""
    
    //fileprivate var tagArray_:[String:[R_Tag]] = [String:[R_Tag]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(title: "Add", style: .plain , target: self, action: #selector(addTag_Action))
        self.navigationItem.rightBarButtonItem = addButton
        
        self.loadTags()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initSearchInfo()
        self.loadTags()
    }
    
    func initSearchInfo() {
        self.sb_searchBar.text = ""
        self.searchText_ = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchText_ = searchText
        self.loadTags()
    }
    
    func loadTags() {
        
        var tagArray_ = [[String:[R_Tag]]]()
        
        let realm = try! Realm()
        if(self.searchText_ == "")
        {
            let allResults = realm.objects(R_Tag.self).sorted(byKeyPath: "content", ascending: true)
            var lastTagHeader = ""
            //var eachTagList:[String:[R_Tag]] = [String:[R_Tag]]()
            var tagList:[R_Tag] = [R_Tag]()
            for i in 0..<allResults.count {
                let item = allResults[i]
                
                let tagFirst = item.content[item.content.startIndex]
                let thisTagHeader = String(tagFirst)
                
                if(lastTagHeader == "" || lastTagHeader != thisTagHeader)
                {
                    if(tagList.count > 0)
                    {
                        let eachTagList = [lastTagHeader: tagList]
                        tagArray_.append(eachTagList)
                    }
                    
                    lastTagHeader = thisTagHeader
                    
                    //eachTagList = [String:[R_Tag]]()
                    tagList = [R_Tag]()
                    tagList.append(item)
                }
                else {
                    tagList.append(item)
                }
            }
            
          
        }
        else
        {
//            let predicateSearch = NSPredicate(format: "name contains %@", self.searchText_)
//            let results = realm.objects(R_NoteBook.self).filter(predicateSearch).sorted(byKeyPath: "updated_at", ascending: false)
//            notebookarray_all = Array(results)
        }
        
        //notebookArray_[0] = notebookarray_recent
        //notebookArray_[1] = notebookarray_all
        
        self.tableview.reloadData()
    }
    
    @objc func addTag_Action() {
        
    }
}

extension ManageTagsViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
//        if (section > 1 || section < 0){
//            return 0
//        }else{
//            let datalist = favoriteNotes[section] as [R_Note]?
//            if datalist != nil {
//                return datalist!.count
//            }
//            else{
//                return 0
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        var title:String = "Favorite Notes"
//        if section == 0 {
//            title = "Recent Notes"
//        }
//        return title
        return "temp"
    }
   
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//        let currentNote = favoriteNotes[indexPath.section]![indexPath.row]
//        cell.textLabel?.text = currentNote.title
//        if(currentNote.alarmDate != nil)
//        {
//            cell.textLabel?.text = currentNote.title + String("(alarmed)")
//        }
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCellEditingStyle.delete {
//            let realm = try! Realm()
//            try! realm.write {
//                let currentNote = self.favoriteNotes[indexPath.section]![indexPath.row]
//                currentNote.isfavorite = false
//            }
//            loadNotes()
//        }
//    }
}
