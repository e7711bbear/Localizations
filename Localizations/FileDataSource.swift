//
//  FileDataSource.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class FileDataSource: NSObject, NSOutlineViewDataSource {
	
	var regions = [Region]()
	
	func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
		if item == nil {
			return self.regions.count
		} else {
			return (item as! Region).files.count
		}
	}
	
	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		if item == nil {
			return self.regions[index]
		} else {
			return (item as! Region).files[index]
		}
	}
	
	func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
		if item is Region {
			return true
		}
		return false
	}
	
	func regionWithCode(code: String) -> Region? {
		for region in self.regions {
			if region.code == code {
				return region
			}
		}
		return nil
	}
	
	func buildDatasource(projectRoot: String, devRegion: String, knownRegions: [String], combinedFiles: [File]) {
		// Build regions based on devRegion & knownRegions
		for knownRegion in knownRegions {
			if let matchingRegion = Region.regionMatchingString(knownRegion) {
				self.regions.append(matchingRegion)
			}
		}
		
		for file in combinedFiles {
			if file.folder.characters.count != 0 {
				// Assign files with their respective region
				if let region = self.regionWithCode(file.languageCode) {
					region.files.append(file)
				} else { 
					// TODO: if region is not empty, add region & add file
					
					NSLog("Missing Region for file \(file)")
				}
			} else {
				// Duplicate those without to each regions.
				for region in regions {
					let newFile = file.mutableCopy() as! File
					
					newFile.folder = "\(region.code).lproj"
					newFile.path = "\(projectRoot)/\(newFile.folder)/\(newFile.name)"
					
					
					region.files.append(newFile)
				}
			}
		}
		
	}
}
