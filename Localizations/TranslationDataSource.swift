//
//  TranslationDataSource.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class TranslationDataSource: NSObject, NSTableViewDataSource {

	var translations = [Translation]()
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return self.translations.count
	}
	
	func key(row: Int) -> String {
		//TODO: Asserts
		return translations[row].key
	}
	
	func value(row: Int) -> String {
		//TODO: Asserts
		return translations[row].value
	}
	
	func comments(row: Int) -> String {
		//TODO: Asserts
		return translations[row].comments
	}
	
	func state(row: Int) -> Translation.State {
		// TODO: asserts
		return translations[row].state
	}
}
