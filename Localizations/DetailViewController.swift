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
		
		self.filesOutlineView.setDelegate(self)
		self.filesOutlineView.setDataSource(self.filesDataSource)
		self.translationsTableView.setDelegate(self)
		self.translationsTableView.setDataSource(self.translationsDataSource)
	}
	
	// MARK: OutlineView funcs
	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		if item is Region {
			return self.produceRegionCell(item as! Region)
		} else if item is File {
			return self.produceFileCell(item as! File)
		}
		// We should never end here.
		return nil
	}
	
	// MARK: TableView funcs
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch tableView {
		case self.translationsTableView:
			return self.produceTranslationCell(row)
		default:
			return nil
		}
	}
	

	// MARK: - Cell production
	
	func produceRegionCell(region: Region) -> RegionCellView {
		let rowView = self.filesOutlineView.makeViewWithIdentifier("regionCell", owner: self) as! RegionCellView
		
		rowView.name.stringValue = region.label
		rowView.code.stringValue = region.code
		// TODO: Add here visuals to show status of containing files.
		
		return rowView
	}
	
	func produceFileCell(file: File) -> FileCellView {
		let rowView = self.filesOutlineView.makeViewWithIdentifier("fileCell", owner: self) as! FileCellView
		
		rowView.fileName.stringValue = file.name
		rowView.folder.stringValue = file.folder
		
		let state = file.state
		
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
	
	// MARK: - TabView Delegate
	
	func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
		self.prepareTranslationsForDisplay()
	}
	
}
