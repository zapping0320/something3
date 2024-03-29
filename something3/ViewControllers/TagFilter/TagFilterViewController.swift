//
//  TagFilterViewController.swift
//  something3
//
//  Created by 김동현 on 09/01/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class TagFilterViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    public var selectedNoteBookId: Int = 0
    
    @IBOutlet weak var button_CloseVC: UIButton!
    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "tagCell"
    var searchText_: String = ""
    
    private let viewModel = TagFilterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadTags()
    }
   

    @IBAction func action_CloseVC(_ sender: Any) {
        self.viewModel.saveTagInfo()
        self.closeViewController()
    }

    
    func closeViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func loadTags() {
        
        viewModel.loadTags(selectedNoteBookId: selectedNoteBookId, searchKeyword: self.searchText_)
        
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
        return viewModel.getItemCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section > 1 || section < 0){
            return "error"
        }else{
            if section == 0 {
                return NSLocalizedString("Selected", comment: "")
            }
            else{
                return NSLocalizedString("Others", comment: "")
            }
        }
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentTag = viewModel.getTagArray()[indexPath.section]![indexPath.row] as R_Tag
        cell.textLabel?.text = currentTag.content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.reArrangeTag(indexPath.section, sourceIndex: indexPath.row)
        
        self.tableview.reloadData()
    }
}

