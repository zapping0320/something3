//
//  ManageTagsViewController.swift
//  something3
//
//  Created by 김동현 on 31/12/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import UIKit
import RealmSwift


struct TagSectionInfos {
    var title:String
    var tagList:[TagUI]
}

struct TagUI {
    var tag:R_Tag
    var count:Int
}

class ManageTagsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "tagCell"
    var searchText_: String = ""
    
    fileprivate var tagArray_ = [TagSectionInfos]()
    
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
        
        tagArray_ = [TagSectionInfos]()
        
        let realm = try! Realm()
        if(self.searchText_ == "")
        {
            let allResults = realm.objects(R_Tag.self).sorted(byKeyPath: "content", ascending: true)
            var lastTagHeader = ""
            var tagList:[TagUI] = [TagUI]()
            for i in 0..<allResults.count {
                let item = allResults[i]
                
                let tagFirst = item.content[item.content.startIndex]
                let thisTagHeader = String(tagFirst)
                
                let tagPredicate = NSPredicate(format: "tagId = %@ ", NSNumber(value: item.id))
                let taggedNotes = realm.objects(R_NoteTagRelations.self).filter(tagPredicate)
                //item.relatedNotes = taggedNotes.count
                //print(taggedNotes.count)
                
                let tatUI = TagUI(tag: item, count: taggedNotes.count)
                
                if(lastTagHeader == "" || lastTagHeader != thisTagHeader)
                {
                    if(tagList.count > 0)
                    {
                        tagArray_.append(TagSectionInfos(title: lastTagHeader, tagList: tagList))
                    }
                    
                    lastTagHeader = thisTagHeader
                    tagList = [TagUI]()
                    tagList.append(tatUI)
                }
                else {
                    tagList.append(tatUI)
                }
            }
            
          
        }
        else
        {
//            let predicateSearch = NSPredicate(format: "name contains %@", self.searchText_)
//            let results = realm.objects(R_NoteBook.self).filter(predicateSearch).sorted(byKeyPath: "updated_at", ascending: false)
//            notebookarray_all = Array(results)
        }
        
        
        self.tableview.reloadData()
    }
    
    @objc func addTag_Action() {
        
    }
}

extension ManageTagsViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return tagArray_.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section > tagArray_.count || section < 0){
            return 0
        }else{
            let tagSectionInfos = tagArray_[section]
            return tagSectionInfos.tagList.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section > tagArray_.count || section < 0){
            return "error"
        }else{
            let tagSectionInfos = tagArray_[section]
            return tagSectionInfos.title
        }
    }
   
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentTagSection = self.tagArray_[indexPath.section]
        let currentTag = currentTagSection.tagList[indexPath.row]
        cell.textLabel?.text = currentTag.tag.content + "(" +  String(currentTag.count) + ")"
        
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
