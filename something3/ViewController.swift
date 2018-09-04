//
//  ViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 4..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

     @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableview.delegate = self
        self.tableview.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
        /*
        if (section > 1 || section < 0){
            return 0
        }else{
            let datalist = notebookarray[section] as [R_Notebook]!
            return datalist!.count
        }*/
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "NotebookContent View") as! NotebookContentViewController
        let currentNoteBook = notebookarray[indexPath.section]![indexPath.row] as R_Notebook
        viewController.selectedNotebook = currentNoteBook
        self.navigationController?.pushViewController(viewController, animated: true)
        //self.present(viewController, animated: true)
 */
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        /*
        let cell:NotebookTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: "notebook cell", for: indexPath) as! NotebookTableViewCell
        let currentitem = notebookarray[indexPath.section]![indexPath.row] as R_Notebook
        //print(indexPath.row)
        //print(currentitem.name)
        cell.label_ol_name?.text = currentitem.name
        
        return cell
 */
    }
    
}
