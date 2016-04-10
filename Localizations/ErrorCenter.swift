//
//  ErrorCenter.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 3/25/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

struct Event {
	var time = NSDate()
	var message: String
	var details: String
	
	init(message: String, details: String) {
		self.message = message
		self.details = details
	}
}


class ErrorCenter: NSObject {

	var appDelegate: AppDelegate!
	
	var errors = [Event]()
	var warnings = [Event]()
	
	
	
	func logError(withMessage message: String, andDetails details: String) {
		// Here is the perfect spot to do additional work with these.
		// Passing _cmd would be nice too AT - 03-2016
		NSLog("ERROR: \(message) - \(details)")
		errors.append(Event(message: message, details: details))
	}
	
	func logWarning(withMessage message: String, andDetails details: String) {
		// Here is the perfect spot to do additional work with these.
		// Passing _cmd would be nice too AT - 03-2016
		NSLog("WARNING: \(message) - \(details)")
		errors.append(Event(message: message, details: details))
	}
}
