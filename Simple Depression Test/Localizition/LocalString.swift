//
//  .String.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/28/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import Foundation
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }

}
