//
//  TabViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 12/15/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    override func segueForUnwinding(to toViewController: UIViewController,
                                    from fromViewController: UIViewController,
                                                    identifier: String?) -> UIStoryboardSegue {
        return UIStoryboardSegue(identifier: identifier, source: fromViewController, destination: toViewController) {
            let fromView = fromViewController.view
            let toView = toViewController.view
            if let containerView = fromView?.superview {
                let initialFrame = fromView?.frame
                var offscreenRect = initialFrame
                offscreenRect?.origin.x -= initialFrame!.width
                toView?.frame = offscreenRect!
                containerView.addSubview(toView!)
                // Being explicit with the types NSTimeInterval and CGFloat are important
                // otherwise the swift compiler will complain
                let duration: TimeInterval = 0.8
                let delay: TimeInterval = 0.0
                let options = UIView.AnimationOptions.curveEaseInOut
                let damping: CGFloat = 0.3
                let velocity: CGFloat = 4.0
                UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: {
                                            toView?.frame = initialFrame!
                }, completion:
                    { finished in
                    toView?.removeFromSuperview()
//                    if let navController = toViewController.navigationController {
//                        navController.popToViewController(toViewController, animated: false)
                        if let tabViewController = toViewController.tabBarController {
                            tabViewController.selectedViewController = toViewController
                    }
                }
            )
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TabViewController: UITabBarControllerDelegate  {
    //MARK: dissolve effect
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
//            return false // Make sure you want this as false
//        }
//
//        if fromView != toView {
//            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
//        }
//
//        return true
//    }
    
    //MARK: slide effect
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        let tabViewControllers = tabBarController.viewControllers!
//        guard let toIndex = tabViewControllers.index(of: viewController) else {
//            return false
//        }
//
//        // Our method
//        animateToTab(toIndex: toIndex)
//
//        return true
//    }
//
//    func animateToTab(toIndex: Int) {
//        let tabViewControllers = viewControllers!
//        let fromView = selectedViewController!.view
//        let toView = tabViewControllers[toIndex].view
//        let fromIndex = tabViewControllers.index(of: selectedViewController!)
//
//        guard fromIndex != toIndex else {return}
//
//        // Add the toView to the tab bar view
//        fromView?.superview!.addSubview(toView!)
//
//        // Position toView off screen (to the left/right of fromView)
//        let screenWidth = UIScreen.main.bounds.size.width;
//        let scrollRight = toIndex > fromIndex!;
//        let offset = (scrollRight ? screenWidth : -screenWidth)
//        toView?.center = CGPoint(x: (fromView?.center.x)! + offset, y: (toView?.center.y)!)
//
//        // Disable interaction during animation
//        view.isUserInteractionEnabled = false
//
//        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
//
//            // Slide the views by -offset
//            fromView?.center = CGPoint(x: (fromView?.center.x)! - offset, y: (fromView?.center.y)!);
//            toView?.center   = CGPoint(x: (toView?.center.x)! - offset, y: (toView?.center.y)!);
//
//        }, completion: { finished in
//
//            // Remove the old view from the tabbar view.
//            fromView!.removeFromSuperview()
//            self.selectedIndex = toIndex
//            self.view.isUserInteractionEnabled = true
//        })
//    }
    //MARK: slide effect 2
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let fromView = tabBarController.selectedViewController?.view,
            let toView = viewController.view, fromView != toView,
            let controllerIndex = self.viewControllers?.firstIndex(of: viewController) {
            
            let viewSize = fromView.frame
            let scrollRight = controllerIndex > tabBarController.selectedIndex
            
            // Avoid UI issues when switching tabs fast
            if fromView.superview?.subviews.contains(toView) == true { return false }
            
            fromView.superview?.addSubview(toView)
            
            let screenWidth = UIScreen.main.bounds.size.width
            toView.frame = CGRect(x: (scrollRight ? screenWidth : -screenWidth), y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)
            
            UIView.animate(withDuration: 0.25, delay: TimeInterval(0.0), options: [.curveEaseOut, .preferredFramesPerSecond60], animations: {
                fromView.frame = CGRect(x: (scrollRight ? -screenWidth : screenWidth), y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)
                toView.frame = CGRect(x: 0, y: viewSize.origin.y, width: screenWidth, height: viewSize.size.height)
            }, completion: { finished in
                if finished {
                    fromView.removeFromSuperview()
                    tabBarController.selectedIndex = controllerIndex
                }
            })
            return true
        }
        return false
    }
}
