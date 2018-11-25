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
    //normal
    static let mainAppBackgroundColor = UIColor(red: 255/255, green: 175/255, blue: 50/255, alpha: 1)
    static let mainButtonBackgroundColor = UIColor(red: 255/255, green: 142/255, blue: 87/255, alpha: 1)
    static let mainTextColor = UIColor.black
    
    //dark
    static let darkAppBackgroundColor = UIColor.lightGray
    static let darkButtonBackgroundColor = UIColor.gray
    static let darkTextColor = UIColor.white
    
    static func getCurrentAppBackground() -> UIColor {
        let defaults = UserDefaults.standard
        let darkmode = defaults.bool(forKey: "darkMode")
        if(darkmode == true)
        {
            return darkAppBackgroundColor
        }
        else
        {
            return mainAppBackgroundColor
        }
    }
    
    static func getCurrentMainButtonColor() -> UIColor {
        let defaults = UserDefaults.standard
        let darkmode = defaults.bool(forKey: "darkMode")
        if(darkmode == true)
        {
            return darkTextColor
        }
        else
        {
            return mainTextColor
        }
    }
    
    static func getCurrentTextColor() -> UIColor {
        let defaults = UserDefaults.standard
        let darkmode = defaults.bool(forKey: "darkMode")
        if(darkmode == true)
        {
            return darkButtonBackgroundColor
        }
        else
        {
            return mainButtonBackgroundColor
        }
    }
    
    static func changeCurrentAppBackground() {
        let defaults = UserDefaults.standard
        let darkmode = defaults.bool(forKey: "darkMode")
        defaults.set(!darkmode, forKey: "darkMode")
    }
}
