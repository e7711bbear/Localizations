//
//  DetailViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/6/16.
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

class DetailViewController: NSViewController, NSTableViewDelegate, NSTabViewDelegate, NSOutlineViewDelegate {

	weak var appDelegate: AppDelegate! = NSApplication.shared().delegate as! AppDelegate

	@IBOutlet var filesOutlineView: NSOutlineView!
	var filesDataSource = FileDataSource()
	
	@IBOutlet var tabView: NSTabView!
	
	@IBOutlet var translationsTableView: NSTableView!
	var translationsDataSource = TranslationDataSource()
	
	@IBOutlet var rawContentView: NSTextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.appDelegate.detailViewController = self
		
		self.filesOutlineView.delegate = self
		self.filesOutlineView.dataSource = self.filesDataSource
		self.translationsTableView.delegate = self
		self.translationsTableView.dataSource = self.translationsDataSource
	}
	
	override func viewWillAppear() {
		self.filesDataSource.buildDatasource(projectRoot: (self.appDelegate.chooseProjectViewController!.xcodeProject.pbxprojPath as NSString).deletingLastPathComponent,
			devRegion: self.appDelegate.chooseProjectViewController!.xcodeProject.devRegion,
			knownRegions:self.appDelegate.chooseProjectViewController!.xcodeProject.knownRegions,
			combinedFiles: self.appDelegate.chooseProjectViewController!.combinedFiles)
		self.filesOutlineView.reloadData()
	}
	
	// MARK: OutlineView Delegate
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if item is Region {
			return self.produceRegionCell(region: item as! Region)
		} else if item is File {
			return self.produceFileCell(file: item as! File)
		}
		// We should never end here.
		return nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		switch outlineView {
		case self.filesOutlineView:
			let item = self.filesOutlineView.item(atRow: row)
			
			switch item {
			case is Region:
				rowView.backgroundColor = self.backgroundColorForRegionCellView(region: item as! Region)
			case is File:
				rowView.backgroundColor = self.backgroundColorForFileCellView(file: item as! File)
			default:
				break
			}
			
		default:
			break
		}
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		self.prepareTranslationsForDisplay()
	}
	
	// MARK: TableView Delegate
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch tableView {
		case self.translationsTableView:
			return self.produceTranslationCell(row: row)
		default:
			return nil
		}
	}

	func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		self.prepareTranslationsForDisplay()
	}
	
	// MARK: - Cell production
	
	func produceRegionCell(region: Region) -> RegionCellView {
		let rowView = self.filesOutlineView.make(withIdentifier: "regionCell", owner: self) as! RegionCellView
		
		rowView.name.stringValue = region.label
		rowView.code.stringValue = region.code
		
		return rowView
	}
	
	func backgroundColorForRegionCellView(region: Region) -> NSColor {
		return NSColor(calibratedWhite: 0.9, alpha: 1.0)
	}

	
	func produceFileCell(file: File) -> FileCellView {
		let rowView = self.filesOutlineView.make(withIdentifier: "fileCell", owner: self) as! FileCellView
		
		rowView.fileName.stringValue = file.name
		rowView.folder.stringValue = file.folder
		
		return rowView
	}
	
	func backgroundColorForFileCellView(file: File) -> NSColor {
		let state = file.state
	
		switch state {
		case .Obselete:
			return NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
		case .New:
			return NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
		case .Edit:
			return NSColor(calibratedRed: 1.0, green: 1.0, blue: 0.0, alpha: 0.2) // yellow
		default:
			break
		}
		return NSColor.white
	}
	
	func produceTranslationCell(row: Int) -> TranslationCellView {
		let rowView = self.translationsTableView.make(withIdentifier: "translationCell", owner: self) as! TranslationCellView
		
		rowView.key.stringValue = self.translationsDataSource.key(row: row)
		rowView.value.stringValue = self.translationsDataSource.value(row: row)
		rowView.comments.stringValue = self.translationsDataSource.comments(row: row)
		
		let state = self.translationsDataSource.state(row: row)
		
		// TODO: Replace this below with something a little more sexy.
		rowView.wantsLayer = true
		
		switch state {
		case .Obselete:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.2).cgColor
		case .New:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.2).cgColor
		case .Edit:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 0.0, alpha: 0.2).cgColor // yellow
		default:
			rowView.layer?.backgroundColor = nil
		}
		
		return rowView
	}
	
	func prepareTranslationsForDisplay() {
		let fileSelectedIndex = self.filesOutlineView.selectedRow
		
		guard fileSelectedIndex != -1 else {
			return
		}
		
		let selectedItem = self.filesOutlineView.item(atRow: fileSelectedIndex)
		
		guard selectedItem is File else {
			return
		}
		let selectedFile = selectedItem as! File
		
		self.translationsDataSource.translations.removeAll()
		self.translationsDataSource.translations.append(contentsOf: selectedFile.translations)

		
		DispatchQueue.main.async { 
			self.translationsTableView.reloadData()
		}
		
		self.rawContentView.string = selectedFile.rawContent
	}
	
	
}
