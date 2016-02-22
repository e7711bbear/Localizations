//
//  DetailViewController+Save.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/14/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Foundation

extension DetailViewController {
	
	func writableContent(file: File) -> String {
		var returnableString = ""
		
		for translation in file.translations {
			switch translation.state {
			case .New:
				returnableString += "/* \(translation.comments) */ \n"
				returnableString += "\"\(translation.key)\" = \"\(translation.value)\";  /* NEW */\n"
			case .Edit:
				returnableString += "/* \(translation.comments) */ \n"
				returnableString += "\"\(translation.key)\" = \"\(translation.value)\";  /* EDITED */\n"
			case .Obselete:
				continue
			default:
				returnableString += "/* \(translation.comments) */ \n"
				returnableString += "\"\(translation.key)\" = \"\(translation.value)\";\n"
			}
		}
		
		return returnableString
	}
	
	func createFile(file: File) {
		let fileContent = self.writableContent(file)
		do {
			
			
			try fileContent.writeToFile(file.path, atomically: true, encoding: NSUTF8StringEncoding)
		} catch {
			NSLog("Error creating file \(file) - \(error)")
			// TODO: Error handling
		}
	}
	
	func editFile(file: File) {
		let fileContent = self.writableContent(file)
		do {
			try fileContent.writeToFile(file.path, atomically: true, encoding: NSUTF8StringEncoding)
		} catch {
			NSLog("Error editing file \(file) - \(error)")
			// TODO: Error handling
		}
	}
	
	func deleteFile(file: File) {
		let fileManager = NSFileManager.defaultManager()

		do {
			try fileManager.removeItemAtPath(file.path)
		} catch {
			NSLog("Error deleting file \(file) - \(error)")
			// TODO: Error Handling
		}
	}
	
	func publish() {
		let fileManager = NSFileManager.defaultManager()
		
		guard self.appDelegate.mainViewController.rootDirectory != nil else {
			// TODO: Error handling here.
			return
		}
		
		//TODO: implementation
		
		var isDirectory: ObjCBool = false
		
		// Sandboxing
		//		self.appDelegate.mainViewController.rootDirectory.startAccessingSecurityScopedResource()
		
		if fileManager.fileExistsAtPath(self.appDelegate.mainViewController.rootDirectory!.path!, isDirectory: &isDirectory) {
			if isDirectory {
				// TODO: Alert here -- about to publish
				
				// If yes at alert ->
				
				for file in self.appDelegate.mainViewController.combinedFiles {
					switch file.state {
					case .New:
						self.createFile(file)
					case .Edit:
						self.editFile(file)
					case .Obselete:
						self.deleteFile(file)
					default:
						continue
					}
				}
			}
		}
		// Sandboxing
		// self.appDelegate.mainViewController.rootDirectory.stopAccessingSecurityScopedResource()
	}

}