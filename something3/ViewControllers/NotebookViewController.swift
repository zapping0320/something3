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
    @IBOutlet weak var tableview: UITableView!
    
    
    fileprivate var notebookArray_:[Int:[R_NoteBook]] = [Int:[R_NoteBook]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        
        return cell
    }


}
