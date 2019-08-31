//
//  appLanguage.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 1/11/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import Foundation

// constants
let APPLE_LANGUAGE_KEY = "AppleLanguages"

class AppLanguage {
    /// get current Apple language
    class func currentAppleLanguage() -> String{
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
        let current = langArray.firstObject as! String
//        let endIndex = current.startIndex
        let currentWithoutLocale = current.prefix(2)
        return String(currentWithoutLocale)
    }
    
    class func currentAppleLanguageFull() -> String{
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
        let current = langArray.firstObject as! String
        return current
    }
    
    /// set @lang to be the first in Applelanguages list
    class func setAppleLAnguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang,currentAppleLanguage()], forKey: APPLE_LANGUAGE_KEY)
        userdef.synchronize()
    }
    
    class var isRTL: Bool {
        return AppLanguage.currentAppleLanguage() == "ar"
    }
}
