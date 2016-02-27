//
//  AppDelegate.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 1/28/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var mainWindow: NSWindow!
	
	@IBOutlet var newMenuItem: NSMenuItem!
	@IBOutlet var saveMenuItem: NSMenuItem!
	
	var chooseProjectViewController: ChooseProjectViewController!
	var detailViewController: DetailViewController!
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		
		self.chooseProjectViewController = ChooseProjectViewController(nibName: nil, bundle: nil)
		self.detailViewController = DetailViewController(nibName: nil, bundle: nil)
		
//		let basicAnimator = ATBasicAnimator()
		
//		basicAnimator.addSubviewAsFullSize(self.mainWindow.contentView!, subView: self.chooseProjectViewController.view)
		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	@IBAction func new(sender: AnyObject) {
		self.chooseProjectViewController.startFresh()
	}
	
}
