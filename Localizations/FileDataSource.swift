//
//  FileDataSource.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class FileDataSource: NSObject, NSTableViewDataSource {

	var files = [File]()
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return files.count
	}
	
	func file(row: Int) -> File {
		// TODO: add asserts here.
		
		return self.files[row]
	}
	
	func fileName(row: Int) -> String {
		// TODO: add assert of row being valid
		return files[row].name
	}
}
