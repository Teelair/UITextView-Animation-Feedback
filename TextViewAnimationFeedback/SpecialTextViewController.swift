//
//  SpecialTextViewController.swift
//  TextViewAnimationFeedback
//
//  Created by Tyler R on 7/12/19.
//  Copyright © 2019 Tyler R. All rights reserved.
//

import Foundation
import UIKit

class SpecialTextViewController: UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var textView: UITextView!
    
    var dismissAnimation: SpecialAnimationController? = SpecialAnimationController()
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.dismissAnimation
    }
    
    override func viewDidLoad() {
        self.transitioningDelegate = self
    }
}

class SpecialAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var animator: UIViewPropertyAnimator? = nil
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.43
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator = self.animator {
            return animator
        }
        
        guard let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return UIViewPropertyAnimator() }
        
        let presentedFrame = transitionContext.finalFrame(for: presentedViewController)
        var dismissedFrame = CGRect(origin: presentedFrame.origin, size: presentedFrame.size)
        dismissedFrame.origin.y = (presentedViewController.view.window?.frame.height ?? 0) - 1
        
        let duration = self.transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration,
                                              controlPoint1: CGPoint(x: 0.3, y: 0.87),
                                              controlPoint2: CGPoint(x: 0.4, y: 1),
                                              animations: {
                                                let siblings = presentedViewController.view.superview?.subviews ?? []
                                                    
                                                for sibling in siblings {
                                                    let siblingClass = type(of:sibling)
                                                    guard sibling == presentedViewController.view || NSStringFromClass(siblingClass).contains("Replicant") else { continue }
                                                    sibling.frame = dismissedFrame
                                                }
        })
        
        animator.addCompletion { [weak presentedViewController] _ in
            if !transitionContext.transitionWasCancelled {
                presentedViewController?.view.removeFromSuperview()
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.animator = nil
        }
        
        self.animator = animator
        return animator
    }
}
