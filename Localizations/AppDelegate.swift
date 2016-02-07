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

	@IBOutlet weak var mainWindow: NSWindow!
	
	var mainViewController: MainViewController!
	var detailViewController: DetailViewController!
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		
		self.mainViewController = MainViewController(nibName: nil, bundle: nil)
		self.detailViewController = DetailViewController(nibName: nil, bundle: nil)
		
		let basicAnimator = ATBasicAnimator()
		
		basicAnimator.addSubviewAsFullSize(self.mainWindow.contentView!, subView: self.mainViewController.view)
		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

}
