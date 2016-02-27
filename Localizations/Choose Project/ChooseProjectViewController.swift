//
//  ChooseProjectViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 1/28/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ChooseProjectViewController: NSViewController {
	
	weak var appDelegate: AppDelegate! = NSApplication.sharedApplication().delegate as! AppDelegate
	
	@IBOutlet var chooseButton: NSButton!
	
	var rootDirectory: NSURL!

	private var _cacheDirectory: NSString?
	
	var cacheDirectory: NSString! {
		get {
			if _cacheDirectory == nil {
				// Randomize
				let size = 12
				let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
				let randomFolderName = NSMutableString(capacity: size)
				for _ in 0..<size {
					randomFolderName.appendFormat("%c", letters.characterAtIndex(Int(arc4random_uniform(UInt32(letters.length)))))
				}
				
				_cacheDirectory = "/tmp/\(randomFolderName)"
				
				// Make Folder if not already existing
				let fileManager = NSFileManager.defaultManager()
				
				// TODO: handle errors other than "can't create because already there"
				try! fileManager.createDirectoryAtPath(_cacheDirectory! as String, withIntermediateDirectories: true, attributes: nil)
			}
			return _cacheDirectory
		}
		set {
			if newValue == nil && _cacheDirectory != nil {
				let fileManager = NSFileManager.defaultManager()
				
				do {
					try fileManager.removeItemAtPath(_cacheDirectory! as String)
				} catch {
					NSLog("Failed to trash the cache directory \(_cacheDirectory)")
				}
			}
			self._cacheDirectory = newValue
		}
	}
	
	// TODO: Move this to an xcodefile model
	var pbxprojPath = ""
	var pbxprojContent = ""
	var devRegion = ""
	lazy var knownRegions = [String]()
	
	lazy var ibFiles = [NSString]()
	lazy var stringFiles = [NSString]()
	
	lazy var localizations = [NSString]()
	
	lazy var existingFiles = [File]()
	lazy var freshlyGeneratedFiles = [File]()
	lazy var combinedFiles = [File]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.appDelegate.chooseProjectViewController = self
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	override func viewDidAppear() {
	}
	
	func startFresh() {
		self.cacheDirectory = nil
		self.ibFiles.removeAll()
		self.stringFiles.removeAll()
		self.localizations.removeAll()
		self.existingFiles.removeAll()
		self.freshlyGeneratedFiles.removeAll()
		self.combinedFiles.removeAll()
		self.dismissViewController(self.appDelegate.detailViewController)
		self.appDelegate.newMenuItem.enabled = false
		self.appDelegate.saveMenuItem.enabled = false
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
				
				// Find the xcode pbxproj.
				self.findPbxproj(self.rootDirectory!.path!)
				
				// Browsing the existing files
				self.findStringFiles(self.rootDirectory!.path!)
				self.sortFoundStringFiles()
				
				// Get fresh generation of files
				self.generateFreshFilesUsingGenstrings()
				self.generateFreshFilesWithIBTool()
				self.produceFreshListOfStringFiles()
				
				self.compareAndCombine()
				// show detail ui
				dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
					self.performSegueWithIdentifier("detailsSegue", sender: nil)
					self.appDelegate.newMenuItem.enabled = true
					self.appDelegate.saveMenuItem.enabled = true
					})
				})
			//			} catch {
			//           // TODO: Implement error here if and when this app is sandboxed
			//			}
		}
	}
	
	// MARK: - Methods collecting existing localization data from .string files.
	
	func findPbxproj(startPath: NSString) {
		let fileManager = NSFileManager.defaultManager()
		
		do {
			let content = try fileManager.contentsOfDirectoryAtPath(startPath as String)
			
			for element in content {
				let elementPath = startPath.stringByAppendingPathComponent(element)
				var isDirectory: ObjCBool = false
				
				fileManager.fileExistsAtPath(elementPath, isDirectory: &isDirectory)
				if isDirectory {
					// Skipping Directories that can't be open
					if !fileManager.isExecutableFileAtPath(elementPath) {
						continue
					}
					
					// Skipping Hidden Folders
					let dotRange = element.rangeOfString(".")
					if dotRange != nil && dotRange!.first! == element.startIndex {
						continue
					}
					
					// We open the folder and continue the process.
					self.findPbxproj(elementPath)
				}
				else // files - we are only interested in localizations files.
				{
					let stringsRange = element.rangeOfString(".pbxproj")
					
					if stringsRange != nil {
						if self.pbxprojPath == "" {
							self.pbxprojPath = elementPath
							self.readPbxproj()
						} else {
							NSLog("Error: Found multiple pbxproj - \(elementPath)")
							//TODO: Implement critical error here as we have multiple xcode project under the folder.
							// We could offer to choose manually or crash directly.
						}
					}
				}
			}
		} catch {
			// TODO: error handling
		}
	}
	
	func readPbxproj() {
		self.knownRegions.removeAll()
		self.devRegion = ""
		
		do {
			self.pbxprojContent = try NSString(contentsOfFile: self.pbxprojPath as String, encoding: NSUTF8StringEncoding) as String
		} catch {
			do {
				self.pbxprojContent = try NSString(contentsOfFile: self.pbxprojPath as String, encoding: NSUTF16StringEncoding) as String
			} catch {
				//TODO: Eventually retry with even more encoding.
			}
		}
		
		guard self.pbxprojContent != "" else {
			NSLog("Can't proceed with reading the pbxproj file (\(self.pbxprojPath)), because it's empty.")
			return
		}
		let lines = self.pbxprojContent.componentsSeparatedByString("\n")
		
		for line in lines {
			if line.characters.count == 0 {
				continue
			}
			
			if self.devRegion == "" {
				let devRegionRange = line.rangeOfString("developmentRegion")
				
				if devRegionRange != nil {
					let foundDevRegion = self.parseDevRegion(line)
					
					if foundDevRegion != nil {
						self.devRegion = foundDevRegion!
					} else {
						// TODO: Recovery here
					}
				}
			}
			if self.knownRegions.count == 0 {
				let knownRegionRange = line.rangeOfString("knownRegions")
				
				if knownRegionRange != nil {
					let startingIndex =	lines.indexOf(line)
					
					let foundRegions = self.parseKnownRegions(lines, startingIndex: startingIndex!)
					
					// TODO: Eventually add here a test on the qty returned.
					self.knownRegions.appendContentsOf(foundRegions)
				}
			}
		}
	}
	
	func parseDevRegion(line: String) -> String? {
		let lineParts = line.componentsSeparatedByString("=")
		var cleanedString = lineParts[1].stringByReplacingOccurrencesOfString(" ", withString: "")
		cleanedString = cleanedString.stringByReplacingOccurrencesOfString(";", withString: "")
		
		return cleanedString
	}
	
	func parseKnownRegions(lines: [String], startingIndex: Int) -> [String] {
		var foundRegions = [String]()
		
		for index in startingIndex+1..<lines.count {
			let line = lines[index]
			
			if line.rangeOfString(");") == nil { // we are in a line of a region
				var cleanedLine = line.stringByReplacingOccurrencesOfString(" ", withString: "")
				cleanedLine = cleanedLine.stringByReplacingOccurrencesOfString("\t", withString: "")
				cleanedLine = cleanedLine.stringByReplacingOccurrencesOfString(",", withString: "")
				
				foundRegions.append(cleanedLine)
			} else {
				break
			}
		}
		
		return foundRegions
	}
	
	
	func findStringFiles(startPath: NSString) {
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
					if !fileManager.isExecutableFileAtPath(elementPath) {
						continue
					}
					
					// Skipping Hidden Folders
					let dotRange = element.rangeOfString(".")
					if dotRange != nil && dotRange!.first! == element.startIndex {
						continue
					}
					
					// We open the folder and continue the process.
					self.findStringFiles(elementPath)
				}
				else // files - we are only interested in localizations files.
				{
					let stringsRange = element.rangeOfString(".strings")
					
					if stringsRange != nil && self.stringFiles.contains(elementPath) == false {
						self.stringFiles.append(elementPath)
					}
				}
			}
		} catch {
			// TODO: error handling
		}
	}
	
	func sortFoundStringFiles() {
		self.existingFiles.removeAll()
		self.localizations.removeAll()
		self.localizations.append("Base.lproj")
		
		for path in self.stringFiles {
			let components = path.pathComponents
			let componentsCount = components.count
			let folder = components[componentsCount - 2]
			let file = components[componentsCount - 1]

			var fileContent = ""
			
			do {
				fileContent = try NSString(contentsOfFile: path as String, encoding: NSUTF8StringEncoding) as String
			} catch {
				do {
					fileContent = try NSString(contentsOfFile: path as String, encoding: NSUTF16StringEncoding) as String
				} catch {
					//TODO: Eventually retry with even more encoding.
				}
			}
			let newFile = File()
			
			newFile.name = file
			newFile.path = path as String
			newFile.folder = folder
			newFile.rawContent = fileContent
			newFile.translations = self.parseTranslations(newFile.rawContent)
			var localizationIsAlreadyRegistered = false
			
			for localization in self.localizations {
				if localization.isEqualToString(folder) {
					localizationIsAlreadyRegistered = true
					break
				}
			}
			
			if localizationIsAlreadyRegistered == false {
				self.localizations.append(folder)
			}
			self.existingFiles.append(newFile)
		}
	}
	
	// MARK: - Methods building fresh localization data from source
	func generateFreshFilesUsingGenstrings() {
		let commandString = "/usr/bin/genstrings -o \"\(self.cacheDirectory)\" `find \"\(self.rootDirectory.path!)\" -name '*.[hm]' -o -name '*.swift'`"
		
		NSLog("Running: \(commandString)")
		
		system(commandString)
	}
	
	func generateFreshFilesWithIBTool() {
		//find . -name '*.xib'
		// ibtool --generate-strings-file MainMenu.strings MainMenu.xib
		
		self.ibFiles.removeAll()
		self.findAllIBFiles(self.rootDirectory.path!)
		
		for filePath in self.ibFiles {
			let pathExtension = filePath.pathExtension
			let fileName = filePath.lastPathComponent
			let stringFileName = fileName.stringByReplacingOccurrencesOfString(pathExtension, withString: "strings")
			
			let commandString = "ibtool --generate-strings-file \"\(self.cacheDirectory)/\(stringFileName)\" \"\(filePath)\""
			
			NSLog("Running: \(commandString)")

			system(commandString)
		}
	}
	
	func findAllIBFiles(startPath: NSString) {
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
					if !fileManager.isExecutableFileAtPath(elementPath) {
						continue
					}
					
					// Skipping Hidden Folders
					let dotRange = element.rangeOfString(".")
					if dotRange != nil && dotRange!.first! == element.startIndex {
						continue
					}
					
					// We "open" the folder and continue the process.
					self.findAllIBFiles(elementPath)
				}
				else // files - we are only interested in localizations files.
				{
					let xibRange = element.rangeOfString(".xib")
					let storyboardRange = element.rangeOfString(".storyboard")
					
					if (xibRange != nil || storyboardRange != nil) &&
						self.ibFiles.contains(elementPath) == false {
						self.ibFiles.append(elementPath)
					}
				}
			}
		} catch {
			// TODO: Error Handling here
		}
	}
	
	func produceFreshListOfStringFiles() {
		self.freshlyGeneratedFiles.removeAll()
		
		let fileManager = NSFileManager.defaultManager()
		do {
			let content = try fileManager.contentsOfDirectoryAtPath(self.cacheDirectory as String)
			
			for element in content {
				let elementPath = cacheDirectory.stringByAppendingPathComponent(element)
				var isDirectory:ObjCBool = false
				
				fileManager.fileExistsAtPath(elementPath, isDirectory: &isDirectory)
				
				if !isDirectory {
					let stringsRange = element.rangeOfString(".strings")
					if stringsRange != nil {
						// files - we are only interested in localizations files.
						let newFile = File()

						newFile.name = element
						// TODO: it'll be great here to ready the conf of the xcode proj and deduce what is the default language.
						newFile.folder = "Base.lproj"
						var fileContent = ""
						
						do {
							fileContent = try NSString(contentsOfFile: elementPath, encoding: NSUTF8StringEncoding) as String
						} catch {
							do {
								fileContent = try NSString(contentsOfFile: elementPath, encoding: NSUTF16StringEncoding) as String
							} catch {
								//TODO: Eventually retry with even more encoding.
							}
						}
						
						newFile.rawContent = fileContent
						newFile.translations = self.parseTranslations(fileContent)
						self.freshlyGeneratedFiles.append(newFile)
					}
				}
			}
		} catch {
			// TODO: Error handling
		}
	}
	
	func compareAndCombine() {
		self.combinedFiles.removeAll()
		
		// starting by comparing fresh vs existing for diff
		for newFile in self.freshlyGeneratedFiles {
			var found = false
			var matchingFile: File!

			for existingFile in self.existingFiles {
				
				// Testing presence
				if newFile.name == existingFile.name &&
					newFile.folder == existingFile.folder {
					found = true
					matchingFile = existingFile
					break
				}
			}
			
			let combinedFile = File()
			combinedFile.name = newFile.name
			combinedFile.path = newFile.path
			combinedFile.folder = newFile.folder
			combinedFile.rawContent = newFile.rawContent
			
			if found == false {
				combinedFile.state = .New
				combinedFile.path = "\((self.pbxprojPath as NSString).stringByDeletingLastPathComponent)/\(newFile.folder)/\(newFile.name)"

				// TODO: Make an actual copy here
				combinedFile.translations = newFile.translations
				for translation in combinedFile.translations {
					translation.state = .New
				}
			} else {
				//We search for the diff
				for newTranslation in newFile.translations {
					var found = false
					var matchingTranslation: Translation!
					
					for existingTranslation in matchingFile.translations {
						if newTranslation.key == existingTranslation.key {
							found = true
							matchingTranslation = existingTranslation
							break
						}
					}
					let combinedTranslation = Translation()
					
					combinedTranslation.key = newTranslation.key
					combinedTranslation.value = newTranslation.value
					combinedTranslation.comments = newTranslation.comments
					
					if found {
						if newTranslation.value != matchingTranslation.value {
							combinedTranslation.state = .Edit
						}
					} else {
						combinedTranslation.state = .New
					}
					combinedFile.translations.append(combinedTranslation)
				}
				
				// We search for the obselete translations
				for existingTranslation in matchingFile.translations {
					var found = false
					
					for newTranslation in newFile.translations {
						if newTranslation.key == existingTranslation.key {
							found = true
							break
						}
					}
					
					if found == false {
						let combinedTranslation = Translation()
						
						combinedTranslation.key = existingTranslation.key
						combinedTranslation.value = existingTranslation.value
						combinedTranslation.comments = existingTranslation.comments
						combinedTranslation.state = .Obselete
						combinedFile.translations.append(combinedTranslation)
					}
				}
			}
			
			self.combinedFiles.append(combinedFile)
		}
		
		// then comparing existing vs fresh for obselete files
		for existingFile in self.existingFiles {
			var found = false
			
			for newFile in self.freshlyGeneratedFiles {
				if newFile.name == existingFile.name &&
				newFile.folder == existingFile.folder {
					found = true
				}
			}
			
			if found == false {
				let combinedFile = File()

				combinedFile.name = existingFile.name
				combinedFile.path = existingFile.path
				combinedFile.folder = existingFile.folder
				combinedFile.rawContent = existingFile.rawContent
				combinedFile.state = .Obselete
				
				combinedFile.translations = existingFile.translations
				
				for translation in combinedFile.translations {
					translation.state = .Obselete
				}
				self.combinedFiles.append(combinedFile)
			}
		}
	}
}

