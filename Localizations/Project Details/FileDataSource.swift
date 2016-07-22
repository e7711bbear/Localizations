//
//  FileDataSource.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
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
	
	func regionWithCode(code: String?) -> Region? {
		guard code != nil else {
			return nil
		}
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
			if let matchingRegion = Region.regionMatchingString(string: knownRegion) {
				self.regions.append(matchingRegion)
			}
		}
		
		for file in combinedFiles {
			if file.folder.characters.count != 0 {
				// Assign files with their respective region
				if let region = self.regionWithCode(code: Region.regionMatchingString(string: file.languageCode)?.code) {
					region.files.append(file)
				} else { 
					let newRegion = Region.regionMatchingString(string: file.languageCode)
					
					if newRegion != nil {
						newRegion!.files.append(file)
						self.regions.append(newRegion!)
					} else {
						NSLog("Missing Region for file \(file), and could not recognize it and recover")
					}
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
