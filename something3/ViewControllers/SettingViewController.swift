//
//  SettingViewController.swift
//  something3
//
//  Created by 김동현 on 15/11/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
    }
    

    @IBAction func changeDarkModeChange(_ sender: UISwitch) {
        ColorHelper.changeCurrentAppBackground()
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
    }
}
