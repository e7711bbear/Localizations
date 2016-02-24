//
//  File.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/4/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class File: NSObject {
	enum State {
		case New
		case Edit
		case Obselete
		case None
	}
	
	var state = State.None
	var name = ""
	var folder = ""
	var path = ""
	var rawContent = ""
	var translations = [Translation] ()

	var languageCode: String {
		get {
			let folderParts = folder.componentsSeparatedByString(".")
			
			if folderParts.count > 0 {
				return folderParts[0]
			}
			return ""
		}
	}
	
	override var description: String {
		get {
			return self.debugDescription
		}
	}
	
	override var debugDescription: String {
		get {
			return "Name: \(self.name)\n" +
			"Folder: \(self.folder)\n" +
			"Path: \(self.path)\n" +
			"State: \(self.state)\n"
		}
	}

}
