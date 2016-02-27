//
//  ATReplacingSegue.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/27/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

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
			let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview" : destinationViewController.view])
			let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview" : destinationController.view])
			sourceViewController.view.addConstraints(horizontalConstraints)
			sourceViewController.view.addConstraints(verticalConstraints)
		} else {
			super.perform()
		}
	}
	
}
