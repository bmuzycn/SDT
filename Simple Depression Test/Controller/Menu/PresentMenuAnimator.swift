//
//  PresentMenuAnimator.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 1/2/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import UIKit

class PresentMenuAnimator : NSObject {
}

extension PresentMenuAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        toVC.view.center.x = -UIScreen.main.bounds.width/2
        toVC.view.layer.shadowOpacity = 0.7
        // replace main view with snapshot
        if let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) {
            snapshot.tag = MenuHelper.snapshotNumber
            snapshot.isUserInteractionEnabled = false
            snapshot.layer.shadowOpacity = 0.1
            
            containerView.insertSubview(snapshot, belowSubview: toVC.view)
            fromVC.view.isHidden = true
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                animations: {
                    toVC.view.center.x = UIScreen.main.bounds.width/2
//                    if UIDevice.current.orientation.isPortrait == true {
//                    snapshot.center.x += UIScreen.main.bounds.width * MenuHelper.menuWidth
//                    } else {
//                        snapshot.center.x += UIScreen.main.bounds.width * 0.55
//                    }
            },
                completion: { _ in
                    fromVC.view.isHidden = false
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            )
        }
    }
}
