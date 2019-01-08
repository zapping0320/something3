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
        
        self.sb_searchBar.delegate = self
        
        let addButton = UIBarButtonItem(title: "Add", style: .plain , target: self, action: #selector(addTag_Action))
        self.navigationItem.rightBarButtonItem = addButton
        
        self.loadTags()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initSearchInfo()
        self.loadTags()
        self.applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.navigationItem.rightBarButtonItem?.tintColor = ColorHelper.getIdentityColor()
    }
    
    func initSearchInfo() {
        self.sb_searchBar.text = ""
        self.searchText_ = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText_ = searchText
        self.loadTags()
    }
    
    func loadTags() {
        
        tagArray_ = [TagSectionInfos]()
        
        let realm = try! Realm()
        var allResults: Results<R_Tag>
        if(self.searchText_ != "")
        {
            let predicateSearch = NSPredicate(format: "content CONTAINS[c] %@", self.searchText_)
            allResults = realm.objects(R_Tag.self).filter(predicateSearch).sorted(byKeyPath: "content", ascending: true)
        }
        else
        {
            allResults = realm.objects(R_Tag.self).sorted(byKeyPath: "content", ascending: true)
        }
        
        var lastTagHeader = ""
        var thisTagHeader = ""
        var tagList:[TagUI] = [TagUI]()
        for i in 0..<allResults.count {
            let item = allResults[i]
            
            let tagFirst = item.content[item.content.startIndex]
            thisTagHeader = String(tagFirst)
            
            let tagPredicate = NSPredicate(format: "tagId = %@ ", NSNumber(value: item.id))
            let taggedNotes = realm.objects(R_NoteTagRelations.self).filter(tagPredicate)
            
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
        
        if(lastTagHeader != "" && tagList.count > 0)
        {
            tagArray_.append(TagSectionInfos(title: lastTagHeader, tagList: tagList))
        }
        
        self.tableview.reloadData()
    }
    
    @objc func addTag_Action() {
        let alert = UIAlertController(title: "", message: "Add Tag", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = ""
        })
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (updateAction) in
            _ = TagManager.storeTagInfo(tag: alert.textFields!.first!.text!)
            self.loadTags()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: false)
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
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
            let currentTagSection = self.tagArray_[indexPath.section]
            let currentTag = currentTagSection.tagList[indexPath.row]
            let alert = UIAlertController(title: "", message: "Edit Tag", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = currentTag.tag.content
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                let realm = try! Realm()
                try! realm.write {
                    currentTag.tag.content = alert.textFields!.first!.text!
                }
                self.loadTags()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "Delete",
                                          message: "Are you sure want to delete this tag?",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let yesAction = UIAlertAction(title: "YES",
                                          style: .default, handler:
                { action in
                    let currentTagSection = self.tagArray_[indexPath.section]
                    let currentTag = currentTagSection.tagList[indexPath.row]
                    TagManager.removeTagNTagInfo(tagId: currentTag.tag.id)
                    self.loadTags()
            }
            )
            
            let cancelAction = UIAlertAction(title: "No",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
            
            tableView.reloadData()
        })
        
        return [deleteAction, editAction]
    }
}
