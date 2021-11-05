//
//  SearchKeywordHelper.swift
//  something3
//
//  Created by 김동현 on 12/01/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import Foundation

class SearchKeywordHelper {
    static let keywordField = "SearchKeyword"
    
    static func updateKeywordList(keyword : String) {
        if var keywordList = UserDefaults.standard.array(forKey: keywordField) as? [String] {
            keywordList.insert(keyword, at: 0)
            if(keywordList.count > 5)
            {
                keywordList.remove(at: 5)
            }
            UserDefaults.standard.set(keywordList, forKey: keywordField)
        }
        else {
            var newList = [String]()
            newList.append(keyword)
            UserDefaults.standard.set(newList, forKey: keywordField)
        }
        
    }
    
    static func getKeywordList() -> [String] {
        return UserDefaults.standard.array(forKey: keywordField) as? [String] ?? []
    }
}
