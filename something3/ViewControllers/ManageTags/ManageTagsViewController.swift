//
//  ManageTagsViewController.swift
//  something3
//
//  Created by 김동현 on 31/12/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import UIKit


struct TagSectionInfos {
    var title:String
    var tagList:[TagUI]
}

struct TagUI {
    var tag:R_Tag
    var count:Int
}

class ManageTagsViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    let cellIdentifier: String = "tagCell"
    var searchText_: String = ""
    
    private let viewModel = ManageTagsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sb_searchBar.delegate = self
        
        let addButton = UIBarButtonItem(title: NSLocalizedString("Add", comment: ""), style: .plain , target: self, action: #selector(addTag_Action))
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
        
        viewModel.loadTags(searchKeyword: self.searchText_)
        
        self.tableview.reloadData()
    }
    
    @objc func addTag_Action() {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Add Tag", comment: ""), preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = ""
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default, handler: { (updateAction) in
            _ = TagManager.storeTagInfo(tag: alert.textFields!.first!.text!)
            self.loadTags()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: false)
    }
}

extension ManageTagsViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return viewModel.getTagArray().count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section > viewModel.getTagArray().count || section < 0){
            return 0
        }else{
            let tagSectionInfos = viewModel.getTagArray()[section]
            return tagSectionInfos.tagList.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section > viewModel.getTagArray().count || section < 0){
            return "error"
        }else{
            let tagSectionInfos = viewModel.getTagArray()[section]
            return tagSectionInfos.title
        }
    }
   
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentTagSection = viewModel.getTagArray()[indexPath.section]
        let currentTag = currentTagSection.tagList[indexPath.row]
        cell.textLabel?.text = currentTag.tag.content + "(" +  String(currentTag.count) + ")"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let editAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: ""), handler: { (action, indexPath) in
            let currentTagSection = self.viewModel.getTagArray()[indexPath.section]
            let currentTag = currentTagSection.tagList[indexPath.row]
            let alert = UIAlertController(title: "", message: NSLocalizedString("Edit Tag", comment: ""), preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = currentTag.tag.content
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { (updateAction) in
                TagManager.shared.updateTag(tagId: currentTag.tag.id, updatedContent: alert.textFields!.first!.text!)
                self.loadTags()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: ""), handler: { (action, indexPath) in
            let alert = UIAlertController(title: NSLocalizedString("Delete", comment: ""),
                                          message: NSLocalizedString("Are you sure want to delete this tag?", comment: ""),
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                          style: .default, handler:
                { action in
                    let currentTagSection = self.viewModel.getTagArray()[indexPath.section]
                    let currentTag = currentTagSection.tagList[indexPath.row]
                    TagManager.removeTagNTagInfo(tagId: currentTag.tag.id)
                    self.loadTags()
            }
            )
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""),
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
            
            tableView.reloadData()
        })
        
        return [deleteAction, editAction]
    }
}
