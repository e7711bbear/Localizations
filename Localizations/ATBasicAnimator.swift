//
//  ATBasicAnimator.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//  and associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
//  NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
