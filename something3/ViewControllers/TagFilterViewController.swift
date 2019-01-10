//
//  TagFilterViewController.swift
//  something3
//
//  Created by 김동현 on 09/01/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class TagFilterViewController: UIViewController {

    @IBOutlet weak var button_CloseVC: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func action_CloseVC(_ sender: Any) {
        self.closeViewController()
    }
    
    func closeViewController() {
        self.dismiss(animated: false, completion: nil)
    }
}
