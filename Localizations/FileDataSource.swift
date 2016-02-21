//
//  FileDataSource.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class FileDataSource: NSObject, NSOutlineViewDataSource {

	var region = [Region]()
	
	func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
		if item == nil {
			return self.region.count
		} else {
			return (item as! Region).files.count
		}
	}

	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		if item == nil {
			return self.region[index]
		} else {
			return (item as! Region).files[index]
		}
	}

	func buildDatasource(devRegion: String, knownRegions: [String], combinedFiles: [File]) {
		
	}
	
}
