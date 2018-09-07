//
//  NotebookViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 5..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class NotebookViewController: UIViewController, UITableViewDataSource {
    
    
    let cellIdentifier: String = "notebookCell"
    let headerSectionIdendifier: String = "headerSectionCell"
    @IBOutlet weak var tableview: UITableView!
    
    
    fileprivate var notebookArray_:[Int:[R_NoteBook]] = [Int:[R_NoteBook]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNotebooks()
    }
    
    func loadNotebooks() {
        notebookArray_ = [Int:[R_NoteBook]]()
        
        var notebookarray_recent = [R_NoteBook]()
        var notebookarray_all = [R_NoteBook]()
        
        let realm = try! Realm()
        let results = realm.objects(R_NoteBook.self).sorted(byKeyPath: "name", ascending: true)
        print(results.count)
        for i in 0..<results.count {
            let item = results[i]
            notebookarray_all.append(item)
            if(i >= results.count - 5)//pick last modified data 5 dd
            {
                notebookarray_recent.insert(item, at: 0)
            }
        }
        
        notebookArray_[0] = notebookarray_recent
        notebookArray_[1] = notebookarray_all
        
        self.tableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NotebookViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section > 1 || section < 0){
            return 0
        }else{
            let datalist = notebookArray_[section] as [R_NoteBook]?
            if datalist != nil {
                return datalist!.count
            }
            else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentNotebook = notebookArray_[indexPath.section]![indexPath.row] as R_NoteBook
        cell.textLabel?.text = currentNotebook.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String = "All Notebooks"
        if section == 0 {
            title = "Recent Notebooks"
        }
        return title
    }


}
