//
//  MainWindowController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/27/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

	let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
	
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

	@IBAction func save(sender: AnyObject) {
		// TODO: Some check here to back up toolbar de/activation
		self.appDelegate.detailViewController?.performSegueWithIdentifier("saveSegue", sender: sender)
	}
	
	@IBAction func projectInfo(sender: AnyObject) {
		
	}

}
