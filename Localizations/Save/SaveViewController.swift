//
//  SaveViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/27/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//  and associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
//  NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa

class SaveViewController: NSViewController, NSTableViewDelegate {
	let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
	
	@IBOutlet var changesTableView: NSTableView!
	var changesTableViewDatasource = ChangeTableViewDataSource()
	
	@IBOutlet var cancelButton: NSButton!
	@IBOutlet var proceedButton: NSButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.changesTableView.setDelegate(self)
		self.changesTableView.setDataSource(self.changesTableViewDatasource)
	}
	
	override func viewWillAppear() {
		self.proceedButton.enabled = true
		self.cancelButton.title = NSLocalizedString("Cancel", comment: "Cancel button's default title in save sheet")
		self.changesTableViewDatasource.buildDatasource((self.appDelegate.detailViewController?.filesDataSource.regions)!)
		self.changesTableView.reloadData()
	}
	
	// MARK: - IB Controls
	
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
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
					for index in 0..<self.changesTableViewDatasource.changes.count {
						let file = self.changesTableViewDatasource.changes[index]
						
						let cellView = self.changesTableView.viewAtColumn(0, row: index, makeIfNecessary: false) as! ChangeStepCellView
						
						cellView.stepStatus.state = .InProgress
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							cellView.stepStatus.setNeedsDisplayInRect(cellView.stepStatus.bounds)
							cellView.stepStatus.displayIfNeeded()
						})
						
						//TODO: add error handling here and .Error state
						switch file.state {
						case .New:
							self.createFile(file)
							cellView.stepStatus.state = .Success
						case .Edit:
							self.editFile(file)
							cellView.stepStatus.state = .Success
						case .Obselete:
							self.deleteFile(file)
							cellView.stepStatus.state = .Success
						default:
							continue
						}
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							cellView.stepStatus.setNeedsDisplayInRect(cellView.stepStatus.bounds)
							cellView.stepStatus.displayIfNeeded()
						})
					}
					
				})
				
			}
		}
		self.proceedButton.enabled = false
		self.cancelButton.title = NSLocalizedString("Close", comment: "Cancel button's close title in save sheet")

		// Sandboxing
		// self.appDelegate.chooseProjectViewController.rootDirectory.stopAccessingSecurityScopedResource()
		
	}
	
	// MARK: - FileSystem funcs
	
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
	
	//MARK: - TableView Delegate
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let changeView = tableView.makeViewWithIdentifier("changeCell", owner: self) as! ChangeStepCellView
		let fileChange = self.changesTableViewDatasource.changes[row]
		
		switch fileChange.state {
		case .New:
			changeView.stepStatus.state = .New
		case .Obselete:
			changeView.stepStatus.state = .Delete
		case .Edit:
			changeView.stepStatus.state = .Edit
		default:
			changeView.stepStatus.state = .None
		}
		
		changeView.fileName.stringValue = fileChange.name
		changeView.translationsInfo.stringValue = "\(fileChange.translations.count) Translation Keys"
		changeView.filePath.stringValue = fileChange.path
		
		return changeView
	}
	
}
