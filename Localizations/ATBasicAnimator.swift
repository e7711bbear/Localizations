//
//  ATBasicAnimator.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ATBasicAnimator: NSObject, NSViewControllerPresentationAnimator {

	func addSubviewAsFullSize(containingView: NSView, subView: NSView) {
		subView.translatesAutoresizingMaskIntoConstraints = false
		
		containingView.addSubview(subView)
		let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|",
			options: .DirectionLeadingToTrailing,
			metrics: nil,
			views: ["view" : subView])
		let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
			options: .DirectionLeadingToTrailing,
			metrics: nil,
			views: ["view" : subView])
		containingView.addConstraints(horizontalConstraints)
		containingView.addConstraints(verticalConstraints)
	}
	
	func animatePresentationOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
		let fromView = fromViewController.view
		let view = viewController.view
		
		self.addSubviewAsFullSize(fromView, subView: view)
	}
	
	func animateDismissalOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
		viewController.view.removeFromSuperview()
	}	
}
