//
//  Translation.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/3/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class Translation: NSObject {
	enum State {
		case Edit // Something Changed
		case New // This translation is new
		case Obselete // This translation is no longer used
		case None // Nothing has changed
	}
	
	var key: String = ""
	var value: String = ""
	var comments: String = ""
	var state = State.None
	
	convenience init(key: String, value: String, comments: String) {
		self.init()
		
		self.key = key
		self.value = value
		self.comments = comments
	}
	
	override var description: String {
		get {
			return self.debugDescription
		}
	}
	
	override var debugDescription: String {
		get {
			let returnableString = "\(comments)\n" +
			"\(self.key) = \(self.value)\n"
			
			return returnableString
		}
	}
}
