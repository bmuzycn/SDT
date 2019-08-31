//
//  PrintPageRenderer.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 9/10/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit

class PrintPageRenderer: UIPrintPageRenderer {
    
    let LetterWidth: CGFloat = 540
    
    let LetterHeight: CGFloat = 720
    

    override init() {
        super.init()
        
        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: LetterWidth, height: LetterHeight)
        
        // Set the page frame.
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
        
        // Set the horizontal and vertical insets (that's optional).
        self.setValue(NSValue(cgRect: pageFrame), forKey: "printableRect")
    }
}
