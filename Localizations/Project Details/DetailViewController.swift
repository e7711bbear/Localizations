//
//  DetailViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/6/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController, NSTableViewDelegate, NSTabViewDelegate, NSOutlineViewDelegate {

	weak var appDelegate: AppDelegate! = NSApplication.sharedApplication().delegate as! AppDelegate

	@IBOutlet var filesOutlineView: NSOutlineView!
	var filesDataSource = FileDataSource()
	
	@IBOutlet var tabView: NSTabView!
	
	@IBOutlet var translationsTableView: NSTableView!
	var translationsDataSource = TranslationDataSource()
	
	@IBOutlet var rawContentView: NSTextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.appDelegate.detailViewController = self
		
		self.filesOutlineView.setDelegate(self)
		self.filesOutlineView.setDataSource(self.filesDataSource)
		self.translationsTableView.setDelegate(self)
		self.translationsTableView.setDataSource(self.translationsDataSource)
	}
	
	override func viewWillAppear() {
		self.filesDataSource.buildDatasource((self.appDelegate.chooseProjectViewController!.xcodeProject.pbxprojPath as NSString).stringByDeletingLastPathComponent,
			devRegion: self.appDelegate.chooseProjectViewController!.xcodeProject.devRegion,
			knownRegions:self.appDelegate.chooseProjectViewController!.xcodeProject.knownRegions,
			combinedFiles: self.appDelegate.chooseProjectViewController!.combinedFiles)
		self.filesOutlineView.reloadData()
	}
	
	// MARK: OutlineView Delegate
	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		if item is Region {
			return self.produceRegionCell(item as! Region)
		} else if item is File {
			return self.produceFileCell(item as! File)
		}
		// We should never end here.
		return nil
	}
	
	func outlineView(outlineView: NSOutlineView, didAddRowView rowView: NSTableRowView, forRow row: Int) {
		switch outlineView {
		case self.filesOutlineView:
			let item = self.filesOutlineView.itemAtRow(row)
			
			switch item {
			case is Region:
				rowView.backgroundColor = self.backgroundColorForRegionCellView(item as! Region)
			case is File:
				rowView.backgroundColor = self.backgroundColorForFileCellView(item as! File)
			default:
				break
			}
			
		default:
			break
		}
	}
	
	func outlineViewSelectionDidChange(notification: NSNotification) {
		self.prepareTranslationsForDisplay()
	}
	
	// MARK: TableView Delegate
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch tableView {
		case self.translationsTableView:
			return self.produceTranslationCell(row)
		default:
			return nil
		}
	}

	func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
		self.prepareTranslationsForDisplay()
	}
	
	// MARK: - Cell production
	
	func produceRegionCell(region: Region) -> RegionCellView {
		let rowView = self.filesOutlineView.makeViewWithIdentifier("regionCell", owner: self) as! RegionCellView
		
		rowView.name.stringValue = region.label
		rowView.code.stringValue = region.code
		
		return rowView
	}
	
	func backgroundColorForRegionCellView(region: Region) -> NSColor {
		return NSColor(calibratedWhite: 0.9, alpha: 1.0)
	}

	
	func produceFileCell(file: File) -> FileCellView {
		let rowView = self.filesOutlineView.makeViewWithIdentifier("fileCell", owner: self) as! FileCellView
		
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
		return NSColor.whiteColor()
	}
	
	func produceTranslationCell(row: Int) -> TranslationCellView {
		let rowView = self.translationsTableView.makeViewWithIdentifier("translationCell", owner: self) as! TranslationCellView
		
		rowView.key.stringValue = self.translationsDataSource.key(row)
		rowView.value.stringValue = self.translationsDataSource.value(row)
		rowView.comments.stringValue = self.translationsDataSource.comments(row)
		
		let state = self.translationsDataSource.state(row)
		
		// TODO: Replace this below with something a little more sexy.
		rowView.wantsLayer = true
		
		switch state {
		case .Obselete:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.2).CGColor
		case .New:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.2).CGColor
		case .Edit:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 0.0, alpha: 0.2).CGColor // yellow
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
		
		let selectedItem = self.filesOutlineView.itemAtRow(fileSelectedIndex)
		
		guard selectedItem is File else {
			return
		}
		let selectedFile = selectedItem as! File
		
		self.translationsDataSource.translations.removeAll()
		self.translationsDataSource.translations.appendContentsOf(selectedFile.translations)
		self.translationsTableView.performSelectorOnMainThread("reloadData", withObject: nil, waitUntilDone: true)
		
		self.rawContentView.string = selectedFile.rawContent
	}
	
	
}
