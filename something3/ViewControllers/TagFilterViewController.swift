//
//  TagFilterViewController.swift
//  something3
//
//  Created by 김동현 on 09/01/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class TagFilterViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    open var selectedNoteBookId: Int = 0
    var selectedNotebook:R_NoteBook = R_NoteBook()
    var tagArray_:[Int:[R_Tag]] = [Int:[R_Tag]]()
    
    @IBOutlet weak var button_CloseVC: UIButton!
    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "tagCell"
    var searchText_: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadTags()
        
        self.applyCurrentColor()
    }
    
    func applyCurrentColor(){
        //self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        //self.button_CloseVC.backgroundColor = ColorHelper.getCurrentMainButtonColor()
    }

    @IBAction func action_CloseVC(_ sender: Any) {
        self.saveNotebookTagInfo()
        self.closeViewController()
    }
    
    func saveNotebookTagInfo() {
        var tagIdString = ""
        for selectedTag in tagArray_[0]! {
            if tagIdString.isEmpty == false {
                tagIdString = tagIdString + ","
            }
            tagIdString = tagIdString + String(selectedTag.id)
        }
        
        let realm = try! Realm()
        
        try! realm.write {
            self.selectedNotebook.searchTags = tagIdString
        }
    }
    
    func closeViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func loadTags() {
        let realm = try! Realm()
        let predicateNotebookId = NSPredicate(format: "id = %@", NSNumber(value: self.selectedNoteBookId))
        let notebookResults = realm.objects(R_NoteBook.self).filter(predicateNotebookId)
        if notebookResults.count == 0 {
            return
        }
        
        tagArray_ = [Int:[R_Tag]]()
        
        self.selectedNotebook = notebookResults[0]
        
        var allTagResults: Results<R_Tag>
        if(self.searchText_ != "")
        {
            let predicateSearch = NSPredicate(format: "content CONTAINS[c] %@", self.searchText_)
            allTagResults = realm.objects(R_Tag.self).filter(predicateSearch).sorted(byKeyPath: "content", ascending: true)
        }
        else
        {
            allTagResults = realm.objects(R_Tag.self).sorted(byKeyPath: "content", ascending: true)
        }
        
        let tagString = self.selectedNotebook.searchTags
        var notebooksTags:[String] = []
        if tagString.contains(",") {
            notebooksTags = tagString.components(separatedBy: ",")
        }
        
        if notebooksTags.count > 1 {
            var selectedTags = [R_Tag]()
            var otherTags = [R_Tag]()
            
            for i in 0..<allTagResults.count {
                var foundTag = false
                let item = allTagResults[i]
                for selectedTag in notebooksTags {
                    if tagString == "" {
                        continue
                    }
                    if Int(selectedTag) == item.id {
                        foundTag = true
                        selectedTags.append(item)
                        break
                    }
                }
                if(foundTag == false){
                    otherTags.append(item)
                }

            }
            tagArray_[0] = selectedTags
            tagArray_[1] = otherTags
        }
        else {
            tagArray_[0] = [R_Tag]()
            tagArray_[1] = Array(allTagResults)
        }
        
        self.tableview.reloadData()
    }
    @IBAction func buttonCancelClose(_ sender: Any) {
         self.closeViewController()
        
    }
}

extension TagFilterViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section > 1 || section < 0){
            return 0
        }else{
            let datalist = tagArray_[section] as [R_Tag]?
            if datalist != nil {
                return datalist!.count
            }
            else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section > 1 || section < 0){
            return "error"
        }else{
            if section == 0 {
                return "Selected"
            }
            else{
                return "Others"
            }
        }
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentTag = self.tagArray_[indexPath.section]![indexPath.row] as R_Tag
        cell.textLabel?.text = currentTag.content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentTag = self.tagArray_[indexPath.section]![indexPath.row] as R_Tag
        let sourceSection = indexPath.section
        let targetSection = indexPath.section == 1 ? 0 : 1
        
        self.tagArray_[sourceSection]?.remove(at: indexPath.row)
        self.tagArray_[targetSection]?.insert(currentTag, at: 0)
        
        self.tableview.reloadData()
    }
}

