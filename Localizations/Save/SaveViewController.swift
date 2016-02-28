//
//  SaveViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/27/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class SaveViewController: NSViewController {
	let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate

	@IBOutlet var changesTableView: NSTableView!
	
	@IBOutlet var cancelButton: NSButton!
	@IBOutlet var proceedButton: NSButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	
	
	@IBAction func cancel(sender:AnyObject) {
		//TODO: Do some check here and cleanup
		self.dismissController(sender)
	}
	
	@IBAction func proceed(sender: AnyObject) {
		let fileManager = NSFileManager.defaultManager()
		
		guard self.appDelegate.chooseProjectViewController!.rootDirectory != nil else {
			// TODO: Error handling here.
			return
		}
		
		//TODO: implementation
		
		var isDirectory: ObjCBool = false
		
		// Sandboxing
		//		self.appDelegate.chooseProjectViewController.rootDirectory.startAccessingSecurityScopedResource()
		
		if fileManager.fileExistsAtPath(self.appDelegate.chooseProjectViewController!.rootDirectory!.path!, isDirectory: &isDirectory) {
			if isDirectory {
				// TODO: Alert here -- about to publish
				
				// If yes at alert ->
				
				for file in self.appDelegate.chooseProjectViewController!.combinedFiles {
					// FIXME:					here we need to change.
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
		// self.appDelegate.chooseProjectViewController.rootDirectory.stopAccessingSecurityScopedResource()
		
	}
	
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
			#if DEBUG
				NSLog("Creating file at \(file.path)")
			#endif
			let fileManager = NSFileManager.defaultManager()
			try fileManager.createDirectoryAtPath((file.path as NSString).stringByDeletingLastPathComponent,
				withIntermediateDirectories: true,
				attributes: nil)
			try fileContent.writeToFile(file.path, atomically: true, encoding: NSUTF8StringEncoding)
		} catch {
			NSLog("Error creating file \(file) - \(error)")
			// TODO: Error handling
		}
	}
	
	func editFile(file: File) {
		let fileContent = self.writableContent(file)
		do {
			#if DEBUG
				NSLog("Editing file at \(file.path)")
			#endif
			try fileContent.writeToFile(file.path, atomically: true, encoding: NSUTF8StringEncoding)
		} catch {
			NSLog("Error editing file \(file) - \(error)")
			// TODO: Error handling
		}
	}
	
	func deleteFile(file: File) {
		let fileManager = NSFileManager.defaultManager()
		
		do {
			#if DEBUG
				NSLog("Deleting file at \(file.path)")
			#endif
			try fileManager.removeItemAtPath(file.path)
		} catch {
			NSLog("Error deleting file \(file) - \(error)")
			// TODO: Error Handling
		}
	}	
}
