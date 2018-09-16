//
//  FavoriteViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 16..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    let cellIdentifier: String = "noteFavoriteCell"
    
    fileprivate var favoriteNotes:[R_Note] = [R_Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNotes() {
        favoriteNotes = [R_Note]()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "isfavorite = true")
        let results = realm.objects(R_Note.self).filter(predicate).sorted(byKeyPath: "updated_at", ascending: false)
        favoriteNotes = Array(results)
        
        self.tableview?.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let noteVC : NoteViewController = segue.destination as? NoteViewController
            else {
                return
        }
        
        guard let cell:UITableViewCell = sender as? UITableViewCell else {
            return
        }
        
        guard  let index:IndexPath = self.tableview?.indexPath(for: cell)  else {
            return
        }
        
        noteVC.selectedNote = favoriteNotes[index.row]
    }

}

extension FavoriteViewController {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favoriteNotes.count
    }
    /*
     public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
     let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Note View") as! NoteViewController
     viewController.selectedNotebook = self.selectedNotebook
     viewController.selectedNote = selectedNotebookContents[indexPath.row]
     self.present(viewController, animated: true)
     }
     */
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentNote = favoriteNotes[indexPath.row]
        cell.textLabel?.text = currentNote.title
        
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(self.selectedNoteBookId != -1)
        {
            return true
        }
        else
        {
            return false
        }
    }*/
    /*
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let realm = try! Realm()
            try! realm.write {
                selectedNotebookContents[indexPath.row].relatedNotebookId = -1
                selectedNotebookContents[indexPath.row].oldNotebookId = self.selectedNoteBookId
                
                /*
                 tableView.beginUpdates()
                 tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                 tableView.endUpdates()*/
            }
            loadContents()
        }
    }*/
}
