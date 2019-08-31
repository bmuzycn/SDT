//
//  MyCustomAxisValueFormatter.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 12/25/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import Foundation
import Charts
class MyCustomAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let intVal = Int(value)
        return "\(intVal)"
    }
    
    
}
