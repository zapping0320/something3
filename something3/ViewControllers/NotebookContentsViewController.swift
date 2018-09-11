//
//  NotebookContentsViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 11..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class NotebookContentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "noteCell"
    
    
    fileprivate var selectedNotebookContents:[R_Note] = [R_Note]()
    //open var selectedNotebook:R_NoteBook = R_NoteBook()
    open var selectedNoteBookId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadContents()
    }
    
    override func  viewDidAppear(_ animated: Bool) {
        loadContents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContents() {
        selectedNotebookContents = [R_Note]()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "relatedNotebookId = %@",  NSNumber(value: self.selectedNoteBookId))
        let results = realm.objects(R_Note.self).filter(predicate).sorted(byKeyPath: "updated_at", ascending: false)
        selectedNotebookContents = Array(results)
        
        self.tableview?.reloadData()
    }

}

extension NotebookContentsViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selectedNotebookContents.count
    }
    
    /*
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }*/
    
    /*
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Note View") as! NoteViewController
        viewController.selectedNotebook = self.selectedNotebook
        viewController.selectedNote = selectedNotebookContents[indexPath.row]
        self.present(viewController, animated: true)
    }
    */
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        /*
        let cell:NoteContentCell = self.tableview.dequeueReusableCell(withIdentifier: "NoteContentCell", for: indexPath) as! NoteContentCell
        
        let currentitem = selectedNotebookContents[indexPath.row]
        //print(indexPath.row)
        //print(currentitem.name)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        cell.label_datetime?.text = dateformatter.string(from: currentitem.updated_at)
        cell.label_title?.text = currentitem.title
        cell.label_content?.text = currentitem.content
        
        return cell
        */
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentNote = selectedNotebookContents[indexPath.row]
        cell.textLabel?.text = currentNote.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let realm = try! Realm()
            try! realm.write {
                realm.delete(selectedNotebookContents[indexPath.row])
                /*
                 tableView.beginUpdates()
                 tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                 tableView.endUpdates()*/
            }
            loadContents()
        }
    }
}
