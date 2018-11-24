//
//  ColorHelper.swift
//  something3
//
//  Created by 김동현 on 24/11/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import Foundation
import UIKit

class ColorHelper {
    static let mainBackgroundColor = UIColor(red: 255/255, green: 175/255, blue: 50/255, alpha: 1)
    
    static func getCurrentAppBackground() -> UIColor {
        let defaults = UserDefaults.standard
        let darkmode = defaults.bool(forKey: "darkMode")
        if(darkmode == true)
        {
            return UIColor.lightGray
        }
        else
        {
            return mainBackgroundColor
        }
    }
    
    static func changeCurrentAppBackground() {
        let defaults = UserDefaults.standard
        let darkmode = defaults.bool(forKey: "darkMode")
        defaults.set(!darkmode, forKey: "darkMode")
    }
}
