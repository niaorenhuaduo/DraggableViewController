//
//  MiniToLargeViewInteractive.swift
//  DraggableViewController
//
//  Created by Jiri Ostatnicky on 18/05/16.
//  Copyright © 2016 Jiri Ostatnicky. All rights reserved.
//

import UIKit

class MiniToLargeViewInteractive: UIPercentDrivenInteractiveTransition {
    
    var viewController: UIViewController?
    var presentViewController: UIViewController?
    var pan: UIPanGestureRecognizer!
    
    var shouldComplete = false
    var lastProgress: CGFloat?
    
    func attachToViewController(viewController: UIViewController, withView view: UIView, presentViewController: UIViewController?) {
        self.viewController = viewController
        self.presentViewController = presentViewController
        pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPan(_:)))
        view.addGestureRecognizer(pan)
    }
    
    func onPan(pan: UIPanGestureRecognizer) {
        let translation = pan.translationInView(pan.view?.superview)
        
        //Represents the percentage of the transition that must be completed before allowing to complete.
        let percentThreshold: CGFloat = 0.2
        //Represents the difference between progress that is required to trigger the completion of the transition.
        let automaticOverrideThreshold: CGFloat = 0.03
        
        let screenHeight: CGFloat = UIScreen.mainScreen().bounds.size.height - BottomBar.bottomBarHeight
        let dragAmount: CGFloat = (presentViewController == nil) ? screenHeight : -screenHeight
        var progress: CGFloat = translation.y / dragAmount
        
        progress = fmax(progress, 0)
        progress = fmin(progress, 1)
        
        switch pan.state {
        case .Began:
            if let presentViewController = presentViewController {
                viewController?.presentViewController(presentViewController, animated: true, completion: nil)
            } else {
                viewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            
        case .Changed:
            guard let lastProgress = lastProgress else {return}
            
            // When swiping back
            if lastProgress > progress {
                shouldComplete = false
                // When swiping quick to the right
            } else if progress > lastProgress + automaticOverrideThreshold {
                shouldComplete = true
            } else {
                // Normal behavior
                shouldComplete = progress > percentThreshold
            }
            updateInteractiveTransition(progress)
            
        case .Ended, .Cancelled:
            if pan.state == .Cancelled || shouldComplete == false {
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition()
            }
            
        default:
            break
        }
        
        lastProgress = progress
    }
}
