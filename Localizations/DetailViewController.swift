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
		
		return rowView
	}
	
	func produceTranslationCell(row: Int) -> TranslationCellView {
		let rowView = self.translationsTableView.makeViewWithIdentifier("translationCell", owner: self) as! TranslationCellView
		
		rowView.key.stringValue = self.translationsDataSource.translationKey(row)
		rowView.value.stringValue = self.translationsDataSource.translationValue(row)
		rowView.comments.stringValue = self.translationsDataSource.translationComments(row)
		
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
