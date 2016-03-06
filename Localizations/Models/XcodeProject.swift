//
//  XcodeProject.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 3/6/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class XcodeProject: NSObject {
	var pbxprojPath = ""
	var pbxprojContent = ""
	var devRegion = ""
	lazy var knownRegions = [String]()
}
