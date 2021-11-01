//
//  AddNotebookViewController.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 8..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import UIKit

class AddNotebookViewController : UIViewController {

    public var dataChanged:(() -> Void)?
    
    @IBOutlet weak var tf_notebookName: UITextField!
    @IBOutlet weak var btn_SaveNotebook: UIButton!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
        self.btn_SaveNotebook.backgroundColor = ColorHelper.getCurrentMainButtonColor()
        
    }
    
    func closeViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btn_cancel_action(_ sender: UIButton) {
        closeViewController()
    }
    
    @IBAction func btn_save_action(_ sender: UIButton) {
        
        if(self.tf_notebookName.text == "")
        {
            let alert = UIAlertController(title: title,
                                          message: NSLocalizedString("you entered no text, please check", comment: ""),
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        NotebookManager.shared.addNotebook(name: self.tf_notebookName.text!)
        
        self.dataChanged?()

        
        closeViewController()
    }
    
}
