//
//  File.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/4/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class File: NSObject {
	var name = ""
	var folder = ""
	var path = ""
	var rawContent = ""
	var translations = [Translation] ()
}
