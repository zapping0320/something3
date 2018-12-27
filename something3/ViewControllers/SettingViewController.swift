//
//  SettingViewController.swift
//  something3
//
//  Created by 김동현 on 15/11/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var labelVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        self.labelVersion.text = appVersion
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        applyCurrentColor()
    }
    
    func applyCurrentColor(){
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
    }

    @IBAction func changeDarkModeChange(_ sender: UISwitch) {
        ColorHelper.changeCurrentAppBackground()
        self.view.backgroundColor = ColorHelper.getCurrentAppBackground()
    }
}
