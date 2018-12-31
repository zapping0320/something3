//
//  ManageTagsViewController.swift
//  something3
//
//  Created by 김동현 on 31/12/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import UIKit

class ManageTagsViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var sb_searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "tagCell"
    var searchText_: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initSearchInfo()
    }
    
    func initSearchInfo() {
        self.sb_searchBar.text = ""
        self.searchText_ = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchText_ = searchText
        //loadNotes()
    }

}
