//
//  ChangeTableViewDataSource.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/28/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ChangeTableViewDataSource: NSObject, NSTableViewDataSource {

	var changes = [File]()
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return self.changes.count
	}
	
	func buildDatasource(regions: [Region]) {
		self.changes.removeAll()
		for region in regions {
			self.changes.appendContentsOf(region.files)
		}
	}
	
}
