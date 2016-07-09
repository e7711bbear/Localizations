//
//  ATReplacingSegue.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/27/16.
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

/**
This Segue only works with NSViewControllers.
If provided with other classes, it defaults to super behavior.
It adds destination's view to source's view as a full size subview.
*/
class ATReplacingSegue: NSStoryboardSegue {

	override func perform() {
		if self.sourceController is NSViewController &&
		self.destinationController is NSViewController {
			let sourceViewController = self.sourceController as! NSViewController
			let destinationViewController = self.destinationController as! NSViewController
			
			sourceViewController.view.addSubview(destinationViewController.view)
			destinationController.view.translatesAutoresizingMaskIntoConstraints = false
			let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview" : destinationViewController.view])
			let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview" : destinationController.view])
			sourceViewController.view.addConstraints(horizontalConstraints)
			sourceViewController.view.addConstraints(verticalConstraints)
		} else {
			super.perform()
		}
	}
	
}
