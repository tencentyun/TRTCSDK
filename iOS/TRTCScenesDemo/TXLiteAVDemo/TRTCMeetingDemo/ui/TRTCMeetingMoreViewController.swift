//
//  TRTCMeetingMoreViewController.swift
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/14.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import UIKit

//定义获取高度协议
public protocol PresentBottomVCProtocol {
    var controllerHeight: CGFloat {get}
}

public class TRTCMeetingMoreViewController: UIViewController, PresentBottomVCProtocol {

    public var controllerHeight: CGFloat {
        return 0
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(presentBottomShouldHide), name: NSNotification.Name( "ShouldHidePresentBottom"), object: nil)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func presentBottomShouldHide() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

/// use an instance to show the transition
public class PresentBottom:UIPresentationController {
    
    /// black layer
    lazy var blackView: UIView = {
        let view = UIView()
        if let frame = self.containerView?.bounds {
            view.frame = frame
        }
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(sendHideNotification))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    /// value to control height of bottom view
    public var controllerHeight:CGFloat
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        //get height from an objec of PresentBottomVC class
        if case let vc as TRTCMeetingMoreViewController = presentedViewController {
            controllerHeight = vc.controllerHeight
        } else {
            controllerHeight = UIScreen.main.bounds.width
        }
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    /// add blackView to the container and let alpha animate to 1 when show transition will begin
    public override func presentationTransitionWillBegin() {
        blackView.alpha = 0
        containerView?.addSubview(blackView)
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
        }
    }
    
    /// let blackView's alpha animate to 0 when hide transition will begin.
    public override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
        }
    }
    
    /// remove the blackView when hide transition end
    ///
    /// - Parameter completed: completed or no
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            blackView.removeFromSuperview()
        }
    }
    
    /// define the frame of bottom view
    public override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: UIScreen.main.bounds.height-controllerHeight, width: UIScreen.main.bounds.width, height: controllerHeight + 20)
    }
    
    @objc func sendHideNotification() {
        NotificationCenter.default.post(name: NSNotification.Name("ShouldHidePresentBottom"), object: nil)
    }
    
}

// MARK: - add function to UIViewController to call easily
extension UIViewController: UIViewControllerTransitioningDelegate {
    
    /// function to show the bottom view
    ///
    /// - Parameter vc: class name of bottom view
    public func presentBottom(_ vc: TRTCMeetingMoreViewController ) {
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    // function refers to UIViewControllerTransitioningDelegate
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present = PresentBottom(presentedViewController: presented, presenting: presenting)
        return present
    }
}
