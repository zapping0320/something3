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
        self.closeViewController()
    }
    
    func closeViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func loadTags() {
        let realm = try! Realm()
        let predicateNotebookId = NSPredicate(format: "id = %@", NSNumber(value: self.selectedNoteBookId))
        let results = realm.objects(R_NoteBook.self).filter(predicateNotebookId)
        if results.count > 0 {
            self.selectedNotebook = results[0]
        }
        
        let tagString = self.selectedNotebook.searchTags
        
        if tagString == "" {
            return
        }
        
        var tags:[String] = []
        if tagString.contains(",") {
            tags = tagString.components(separatedBy: ",")
        }
        
        if tags.count > 1 {
            for tag in tags {
                //_ = storeTagInfo(noteid: noteid, tag: tag)
            }
          
        }
    }
}

extension TagFilterViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1//tagArray_.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        if (section > tagArray_.count || section < 0){
//            return 0
//        }else{
//            let tagSectionInfos = tagArray_[section]
//            return tagSectionInfos.tagList.count
//        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if (section > tagArray_.count || section < 0){
//            return "error"
//        }else{
//            let tagSectionInfos = tagArray_[section]
//            return tagSectionInfos.title
//        }
        return "temp"
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        //let currentTagSection = self.tagArray_[indexPath.section]
        //let currentTag = currentTagSection.tagList[indexPath.row]
        //cell.textLabel?.text = currentTag.tag.content + "(" +  String(currentTag.count) + ")"
        cell.textLabel?.text = "1"
        return cell
    }
}

