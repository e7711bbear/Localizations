//
//  ProjectInfoViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/27/16.
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

class ProjectInfoViewController: NSViewController {

	let appDelegate = NSApplication.shared().delegate as! AppDelegate
	
	@IBOutlet var projectName: NSTextField!
	@IBOutlet var rootPath: NSTextField!
	@IBOutlet var pbxprojPath: NSTextField!
	@IBOutlet var ibFiles: NSTextField!
	@IBOutlet var stringFiles: NSTextField!
	
	@IBOutlet var closeButton: NSButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.projectName.stringValue = "No Project"
		self.rootPath.stringValue = "Please choose a project root directory"
		self.pbxprojPath.stringValue = "None"
		self.ibFiles.stringValue = "0"
		self.stringFiles.stringValue = "0"
	}
	
	override func viewWillAppear() {
		guard self.appDelegate.chooseProjectViewController != nil &&
		self.appDelegate.chooseProjectViewController!.rootDirectory != nil else {
			return
		}
		self.projectName.stringValue = self.appDelegate.chooseProjectViewController!.rootDirectory.lastPathComponent!
		self.rootPath.stringValue = self.appDelegate.chooseProjectViewController!.rootDirectory.path!
		self.pbxprojPath.stringValue = self.appDelegate.chooseProjectViewController!.xcodeProject.pbxprojPath
		self.ibFiles.stringValue = "\(self.appDelegate.chooseProjectViewController!.ibFiles.count)"
		self.stringFiles.stringValue = "\(self.appDelegate.chooseProjectViewController!.stringFiles.count)"
	}
    
}
