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
	let appDelegate = NSApplication.shared().delegate as! AppDelegate
	
	@IBOutlet var changesTableView: NSTableView!
	var changesTableViewDatasource = ChangeTableViewDataSource()
	
	@IBOutlet var cancelButton: NSButton!
	@IBOutlet var proceedButton: NSButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.changesTableView.delegate = self
		self.changesTableView.dataSource = self.changesTableViewDatasource
	}
	
	override func viewWillAppear() {
		self.proceedButton.isEnabled = true
		self.cancelButton.title = NSLocalizedString("Cancel", comment: "Cancel button's default title in save sheet")
		self.changesTableViewDatasource.buildDatasource(regions: (self.appDelegate.detailViewController?.filesDataSource.regions)!)
		self.changesTableView.reloadData()
	}
	
	// MARK: - IB Controls
	
	@IBAction func cancel(sender:AnyObject) {
		//TODO: Do some check here and cleanup
		self.dismiss(sender)
	}
	
	@IBAction func proceed(sender: AnyObject) {
		let fileManager = FileManager.default
		
		guard self.appDelegate.chooseProjectViewController!.rootDirectory != nil else {
			// TODO: Error handling here.
			return
		}
		
		//TODO: implementation
		
		var isDirectory: ObjCBool = false
		
		// Sandboxing
		//		self.appDelegate.chooseProjectViewController.rootDirectory.startAccessingSecurityScopedResource()
		
		if fileManager.fileExists(atPath: self.appDelegate.chooseProjectViewController!.rootDirectory!.path!, isDirectory: &isDirectory) {
			if isDirectory.boolValue {
				// TODO: Alert here -- about to publish
				
				// If yes at alert ->
				DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
					for index in 0..<self.changesTableViewDatasource.changes.count {
						let file = self.changesTableViewDatasource.changes[index]
						
						let cellView = self.changesTableView.view(atColumn: 0, row: index, makeIfNecessary: false) as! ChangeStepCellView
						
						cellView.stepStatus.state = .InProgress
						DispatchQueue.main.async(execute: { () -> Void in
							cellView.stepStatus.setNeedsDisplay(cellView.stepStatus.bounds)
							cellView.stepStatus.displayIfNeeded()
						})
						
						//TODO: add error handling here and .Error state
						switch file.state {
						case .New:
							self.createFile(file: file)
							cellView.stepStatus.state = .Success
						case .Edit:
							self.editFile(file: file)
							cellView.stepStatus.state = .Success
						case .Obselete:
							self.deleteFile(file: file)
							cellView.stepStatus.state = .Success
						default:
							continue
						}
						DispatchQueue.main.async(execute: { () -> Void in
							cellView.stepStatus.setNeedsDisplay(cellView.stepStatus.bounds)
							cellView.stepStatus.displayIfNeeded()
						})
					}
				})
			}
		}
		self.proceedButton.isEnabled = false
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
		let fileContent = self.writableContent(file: file)
		do {
			#if DEBUG
				NSLog("Creating file at \(file.path)")
			#endif
			let fileManager = FileManager.default
			try fileManager.createDirectory(atPath: (file.path as NSString).deletingLastPathComponent,
				withIntermediateDirectories: true,
				attributes: nil)
			try fileContent.write(toFile: file.path, atomically: true, encoding: String.Encoding.utf8)
		} catch {
			NSLog("Error creating file \(file) - \(error)")
			// TODO: Error handling
		}
	}
	
	func editFile(file: File) {
		let fileContent = self.writableContent(file: file)
		do {
			#if DEBUG
				NSLog("Editing file at \(file.path)")
			#endif
			try fileContent.write(toFile: file.path, atomically: true, encoding: String.Encoding.utf8)
		} catch {
			NSLog("Error editing file \(file) - \(error)")
			// TODO: Error handling
		}
	}
	
	func deleteFile(file: File) {
		let fileManager = FileManager.default
		
		do {
			#if DEBUG
				NSLog("Deleting file at \(file.path)")
			#endif
			try fileManager.removeItem(atPath: file.path)
		} catch {
			NSLog("Error deleting file \(file) - \(error)")
			// TODO: Error Handling
		}
	}
	
	//MARK: - TableView Delegate
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let changeView = tableView.make(withIdentifier: "changeCell", owner: self) as! ChangeStepCellView
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
