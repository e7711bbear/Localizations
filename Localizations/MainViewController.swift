//
//  MainViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 1/28/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

	@IBOutlet weak var chooseButton: NSButton!
	var rootDirectory: NSURL!
	// TODO: Add here a random cache directory generator
	let cacheDirectory = "/tmp/"

	var xibFiles = [NSString]()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	@IBAction func chooseXcodeFolder(sender: NSButton) {
		let openPanel = NSOpenPanel()
		
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.message = NSLocalizedString("Choose a directory", comment: "Open Panel Message to choose the xcode root directory")
		openPanel.title = NSLocalizedString("Please choose a directory containing your Xcode project.", comment: "Open Panel Title to choose the xcode root directory")
		
		let returnValue = openPanel.runModal()
		
		if returnValue == NSModalResponseOK {
			guard openPanel.URL != nil else {
				// TODO: Error handling here
				return
			}
			self.rootDirectory = openPanel.URL!
			// TODO: To be used if and when this app is to be sandboxed.
			//			self.rootDirectory.startAccessingSecurityScopedResource()
			
			//			do {
			//				try self.rootDirectory.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SecurityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeToURL: nil)
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { [unowned self] () -> Void in
				
				// TODO: to be implemented to show what was found
				// search for localization files starting at root
				// sort paths
				
				// Get fresh generation of files
				self.generateFreshFilesUsingGenstrings()
				self.generateFreshFilesWithIBTool()
				self.produceFreshListOfStringFiles()
				
				//generate files with gentstrings
				// generate files with ibtool
				// build fresh list of generated files.
				
				// show detail ui
				dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
				NSLog("show something")
				})
			})
			//			} catch {
			//           // TODO: Implement error here if and when this app is to be sandboxed
			//			}
		}
	}
	
	func generateFreshFilesUsingGenstrings() {
		let commandString = "/usr/bin/genstrings -o \(self.cacheDirectory) `find \(self.rootDirectory.path!) -name '*.[hm]'`"

		system(commandString)
	}
	
	func generateFreshFilesWithIBTool() {
		//find . -name '*.xib'
		// ibtool --generate-strings-file MainMenu.strings MainMenu.xib

		self.xibFiles.removeAll()
		self.findAllXibFiles(self.rootDirectory.path!)
		
		for filePath in self.xibFiles {
			
		//		NSArray *filePathComponents = [filePath pathComponents];
			let pathExtension = filePath.pathExtension
			let fileName = filePath.lastPathComponent
			let stringFileName = fileName.stringByReplacingOccurrencesOfString(pathExtension, withString: "strings")

			let commandString = "ibtool --generate-strings-file \(self.cacheDirectory)\(stringFileName) \(filePath)"
		
			system(commandString)
		}
	}
	
	func findAllXibFiles(startPath: NSString) {
		//NOTE: Could be replaced by fts_open from libc (man)
		
		let fileManager = NSFileManager.defaultManager()
		do {
			let content = try fileManager.contentsOfDirectoryAtPath(startPath as String)
			
			for element in content {
				let elementPath = startPath.stringByAppendingPathComponent(element)
				var isDirectory: ObjCBool = false
				
				fileManager.fileExistsAtPath(elementPath, isDirectory: &isDirectory)
				if isDirectory {
					// Skipping Directories that can't be open
					if fileManager.isExecutableFileAtPath(elementPath) {
						continue
					}
					
					// Skipping Hidden Folders
					let dotRange = element.rangeOfString(".")
					if dotRange != nil && dotRange!.first! == element.startIndex {
						continue
					}
					
					// We "open" the folder and continue the process.
					self.findAllXibFiles(elementPath)
				}
				else // files - we are only interested in localizations files.
				{
					let xibRange = element.rangeOfString(".xib")
					
					if xibRange != nil && self.xibFiles.contains(elementPath) == false {
						self.xibFiles.append(elementPath)
					}
				}				
			}
		} catch {
			// TODO: Error Handling here
		}
	}
	
	func produceFreshListOfStringFiles() {
		
	}
}

