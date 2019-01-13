//
//  StringHelper.swift
//  something3
//
//  Created by 김동현 on 15/11/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import Foundation

class StringHelper {
    static func makeHeaderStringCopied(title : String) -> String {
        return String.localizedStringWithFormat(NSLocalizedString("%@-Copied", comment: ""), title)
    }
    
    static func makeHeaderStringAlarmed(title : String) -> String {
        return String.localizedStringWithFormat(NSLocalizedString("%@(alarmed)", comment: ""), title)
    }
}
