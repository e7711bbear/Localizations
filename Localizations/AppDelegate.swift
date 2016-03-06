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

	@IBOutlet var newMenuItem: NSMenuItem!
	@IBOutlet var saveMenuItem: NSMenuItem!
	
	var chooseProjectViewController: ChooseProjectViewController?
	var detailViewController: DetailViewController?
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	@IBAction func new(sender: AnyObject) {
		self.chooseProjectViewController?.startFresh()
	}
	
}
