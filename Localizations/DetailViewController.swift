//
//  DetailViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/6/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController, NSTableViewDelegate {

	weak var appDelegate: AppDelegate! = NSApplication.sharedApplication().delegate as! AppDelegate

	@IBOutlet weak var filesTableView: NSTableView!
	var filesDataSource = FileDataSource()
	@IBOutlet weak var translationsTableView: NSTableView!
	var translationsDataSource = TranslationDataSource()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.filesTableView.setDelegate(self)
		self.filesTableView.setDataSource(self.filesDataSource)
		self.translationsTableView.setDelegate(self)
		self.translationsTableView.setDataSource(self.translationsDataSource)
	}
	
	// MARK: Table View funcs
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch tableView {
		case self.filesTableView:
			return self.produceFileCell(row)
		case self.translationsTableView:
			return self.produceTranslationCell(row)
		default:
			return nil
		}
	}
	
	func tableViewSelectionDidChange(notification: NSNotification) {
		let tableView = notification.object as? NSTableView

		guard tableView != nil else {
			return
		}

		switch tableView! {
		case self.filesTableView:
			self.prepareTranslationsForDisplay()
		default:
			return
		}
	}
	
	func produceFileCell(row: Int) -> FileCellView {
		let rowView = self.filesTableView.makeViewWithIdentifier("fileCell", owner: self) as! FileCellView
		
		rowView.fileName.stringValue = self.filesDataSource.fileName(row)
		rowView.folder.stringValue = self.filesDataSource.folder(row)
		
		let state = self.filesDataSource.state(row)
		
		// TODO: Replace this below with something a little more sexy.
		rowView.wantsLayer = true
		
		switch state {
		case .Obselete:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.5).CGColor
		case .New:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
		case .Edit:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor // yellow
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
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.5).CGColor
		case .New:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
		case .Edit:
			rowView.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor // yellow
		default:
			rowView.layer?.backgroundColor = nil
		}
		
		return rowView
	}
	
	func prepareTranslationsForDisplay() {
		let fileSelectedIndex = self.filesTableView.selectedRow
		
		guard fileSelectedIndex != -1 else {
			return
		}
		
		let selectedFile = self.filesDataSource.file(fileSelectedIndex)
		
		self.translationsDataSource.translations.removeAll()
		self.translationsDataSource.translations.appendContentsOf(selectedFile.translations)
		self.translationsTableView.performSelectorOnMainThread("reloadData", withObject: nil, waitUntilDone: true)
		
	}
	
}
