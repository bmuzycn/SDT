//
//  SwipeSegue.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 11/30/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
class SegueFromLeft: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                        
        },
                       completion: { finished in
                        if src.presentedViewController == nil {
                        src.present(dst, animated: false, completion: nil)
                        }
        }
        )
    }
}
class SegueFromRight: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                       completion: { finished in
                        if src.presentedViewController == nil {
                        src.present(dst, animated: false, completion: nil)
                        }
        }
        )
}
}
