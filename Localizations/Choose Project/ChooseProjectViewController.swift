//
//  ChooseProjectViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 1/28/16.
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

class ChooseProjectViewController: NSViewController {
	
	weak var appDelegate: AppDelegate! = NSApplication.shared().delegate as! AppDelegate
	
	@IBOutlet var chooseLabel: NSTextField!
	@IBOutlet var chooseButton: NSButton!
	@IBOutlet var progressIndicator: NSProgressIndicator!
	
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
					randomFolderName.appendFormat("%c", letters.character(at: Int(arc4random_uniform(UInt32(letters.length)))))
				}
				
				_cacheDirectory = "/tmp/\(randomFolderName)"
				
				// Make Folder if not already existing
				let fileManager = FileManager.default
				
				// TODO: handle errors other than "can't create because already there"
				try! fileManager.createDirectory(atPath: _cacheDirectory! as String, withIntermediateDirectories: true, attributes: nil)
			}
			return _cacheDirectory
		}
		set {
			if newValue == nil && _cacheDirectory != nil {
				let fileManager = FileManager.default
				
				do {
					try fileManager.removeItem(atPath: _cacheDirectory! as String)
				} catch {
					NSLog("Failed to trash the cache directory \(_cacheDirectory)")
				}
			}
			self._cacheDirectory = newValue
		}
	}
	
	lazy var xcodeProject = XcodeProject()
	
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
		
	override func viewDidAppear() {
	}
	
	//MARK: - UI
	func startFresh() {
		self.cacheDirectory = nil
		self.ibFiles.removeAll()
		self.stringFiles.removeAll()
		self.localizations.removeAll()
		self.existingFiles.removeAll()
		self.freshlyGeneratedFiles.removeAll()
		self.combinedFiles.removeAll()
		self.dismissViewController(self.appDelegate.detailViewController!)
		self.appDelegate.newMenuItem.isEnabled = false
		self.appDelegate.saveMenuItem.isEnabled = false
		self.disableProgression()
	}
	
	func enableProgression() {
		self.chooseButton.isHidden = true
		self.progressIndicator.isHidden = false
	}
	
	func disableProgression() {
		self.chooseLabel.stringValue = NSLocalizedString("Choose the root folder of your Xcode project", comment: "Default label above the choose project button")
		self.chooseButton.isHidden = false
		self.progressIndicator.isHidden = true
	}
	
	func startProression(withCurrentValue currentValue: Double = 0.0 , maxValue: Double = 100.0, andMessage message: String) {
		self.enableProgression()
		self.progressIndicator.maxValue = maxValue
		self.progressIndicator.doubleValue = currentValue
		self.progressIndicator.startAnimation(nil)
		self.chooseLabel.stringValue = message
	}
	
	func stopProgression() {
		self.disableProgression()
		self.progressIndicator.stopAnimation(nil)
	}
	
	//MARK: -
	
	@IBAction func chooseXcodeFolder(sender: NSButton) {
		let openPanel = NSOpenPanel()
		
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.message = NSLocalizedString("Choose a directory", comment: "Open Panel Message to choose the xcode root directory")
		openPanel.title = NSLocalizedString("Please choose a directory containing your Xcode project.", comment: "Open Panel Title to choose the xcode root directory")
		
		let returnValue = openPanel.runModal()
		
		if returnValue == NSModalResponseOK {
			guard openPanel.url != nil else {
				// TODO: Error handling here
				return
			}
			
			self.startProression(maxValue: 3, andMessage: NSLocalizedString("Looking for localizations Files", comment: "Progression start message"))

			self.rootDirectory = openPanel.url!
			// TODO: To be used if and when this app is to be sandboxed.
			//			self.rootDirectory.startAccessingSecurityScopedResource()
			
			//			do {
			//				try self.rootDirectory.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SecurityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeToURL: nil)
			
			DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosUserInitiated).async(execute:  { [unowned self] () -> Void in
				
				// Find the xcode pbxproj.
				self.findPbxproj(startPath: self.rootDirectory!.path!)
				
				// Browsing the existing files
				self.findStringFiles(startPath: self.rootDirectory!.path!)
				self.sortFoundStringFiles()
				
				// Get fresh generation of files
				self.generateFreshFilesUsingGenstrings()
				self.generateFreshFilesWithIBTool()
				self.produceFreshListOfStringFiles()
				
				self.compareAndCombine()
				// show detail ui
				DispatchQueue.main.async(execute: { [unowned self] () -> Void in
					self.stopProgression()
					self.performSegue(withIdentifier: "detailsSegue", sender: nil)
					self.appDelegate.newMenuItem.isEnabled = true
					self.appDelegate.saveMenuItem.isEnabled = true
					})
				})
			//			} catch {
			//           // TODO: Implement error here if and when this app is sandboxed
			//			}
		}
	}
	
	// MARK: - Methods collecting existing localization data from .string files.
	
	func findPbxproj(startPath: NSString) {
		let fileManager = FileManager.default
		
		do {
			let content = try fileManager.contentsOfDirectory(atPath: startPath as String)
			
			for element in content {
				let elementPath = startPath.appendingPathComponent(element)
				var isDirectory: ObjCBool = false
				
				fileManager.fileExists(atPath: elementPath, isDirectory: &isDirectory)
				if isDirectory {
					// Skipping Directories that can't be open
					if !fileManager.isExecutableFile(atPath: elementPath) {
						continue
					}
					
					// Skipping Hidden Folders
					let dotRange = element.range(of: ".")
					if dotRange != nil && dotRange!.first! == element.startIndex {
						continue
					}
					
					// We open the folder and continue the process.
					self.findPbxproj(startPath: elementPath)
				}
				else // files - we are only interested in localizations files.
				{
					let stringsRange = element.rangeOfString(".pbxproj")
					
					if stringsRange != nil {
						if self.xcodeProject.pbxprojPath == "" {
							self.xcodeProject.pbxprojPath = elementPath
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
		self.xcodeProject.knownRegions.removeAll()
		self.xcodeProject.devRegion = ""
		
		do {
			self.xcodeProject.pbxprojContent = try NSString(contentsOfFile: self.xcodeProject.pbxprojPath as String, encoding: String.Encoding.utf8.rawValue) as String
		} catch {
			do {
				self.xcodeProject.pbxprojContent = try NSString(contentsOfFile: self.xcodeProject.pbxprojPath as String, encoding: String.Encoding.utf16.rawValue) as String
			} catch {
				//TODO: Eventually retry with even more encoding.
			}
		}
		
		guard self.xcodeProject.pbxprojContent != "" else {
			NSLog("Can't proceed with reading the pbxproj file (\(self.xcodeProject.pbxprojPath)), because it's empty.")
			return
		}
		let lines = self.xcodeProject.pbxprojContent.componentsSeparatedByString("\n")
		
		for line in lines {
			if line.characters.count == 0 {
				continue
			}
			
			if self.xcodeProject.devRegion == "" {
				let devRegionRange = line.rangeOfString("developmentRegion")
				
				if devRegionRange != nil {
					let foundDevRegion = self.parseDevRegion(line)
					
					if foundDevRegion != nil {
						self.xcodeProject.devRegion = foundDevRegion!
					} else {
						// TODO: Recovery here
					}
				}
			}
			if self.xcodeProject.knownRegions.count == 0 {
				let knownRegionRange = line.rangeOfString("knownRegions")
				
				if knownRegionRange != nil {
					let startingIndex =	lines.indexOf(line)
					
					let foundRegions = self.parseKnownRegions(lines, startingIndex: startingIndex!)
					
					// TODO: Eventually add here a test on the qty returned.
					self.xcodeProject.knownRegions.appendContentsOf(foundRegions)
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
		
		let fileManager = FileManager.default
		do {
			let content = try fileManager.contentsOfDirectory(atPath: startPath as String)
			
			for element in content {
				let elementPath = startPath.appendingPathComponent(element)
				var isDirectory: ObjCBool = false
				
				fileManager.fileExists(atPath: elementPath, isDirectory: &isDirectory)
				if isDirectory {
					// Skipping Directories that can't be open
					if !fileManager.isExecutableFile(atPath: elementPath) {
						continue
					}
					
					// Skipping Hidden Folders
					let dotRange = element.rangeOfString(".")
					if dotRange != nil && dotRange!.first! == element.startIndex {
						continue
					}
					
					// We open the folder and continue the process.
					self.findStringFiles(startPath: elementPath)
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
				fileContent = try NSString(contentsOfFile: path as String, encoding: String.Encoding.utf8.rawValue) as String
			} catch {
				do {
					fileContent = try NSString(contentsOfFile: path as String, encoding: String.Encoding.utf16.rawValue) as String
				} catch {
					//TODO: Eventually retry with even more encoding.
				}
			}
			let newFile = File()
			
			newFile.name = file
			newFile.path = path as String
			newFile.folder = folder
			newFile.rawContent = fileContent
			newFile.translations = self.parseTranslations(rawContent: newFile.rawContent)
			var localizationIsAlreadyRegistered = false
			
			for localization in self.localizations {
				if localization.isEqual(to: folder) {
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
		self.findAllIBFiles(startPath: self.rootDirectory.path!)
		
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
		
		let fileManager = FileManager.default
		do {
			let content = try fileManager.contentsOfDirectory(atPath: startPath as String)
			
			for element in content {
				let elementPath = startPath.appendingPathComponent(element)
				var isDirectory: ObjCBool = false
				
				fileManager.fileExists(atPath: elementPath, isDirectory: &isDirectory)
				if isDirectory {
					// Skipping Directories that can't be open
					if !fileManager.isExecutableFile(atPath: elementPath) {
						continue
					}
					
					// Skipping Hidden Folders
					let dotRange = element.rangeOfString(".")
					if dotRange != nil && dotRange!.first! == element.startIndex {
						continue
					}
					
					// We "open" the folder and continue the process.
					self.findAllIBFiles(startPath: elementPath)
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
		
		let fileManager = FileManager.default
		do {
			let content = try fileManager.contentsOfDirectory(atPath: self.cacheDirectory as String)
			
			for element in content {
				let elementPath = cacheDirectory.appendingPathComponent(element)
				var isDirectory:ObjCBool = false
				
				fileManager.fileExists(atPath: elementPath, isDirectory: &isDirectory)
				
				if !isDirectory {
					let stringsRange = element.rangeOfString(".strings")
					if stringsRange != nil {
						// files - we are only interested in localizations files.
						let newFile = File()

						newFile.name = element
						newFile.folder = "\(self.xcodeProject.devRegion).lproj"
						var fileContent = ""
						
						do {
							fileContent = try NSString(contentsOfFile: elementPath, encoding: String.Encoding.utf8.rawValue) as String
						} catch {
							do {
								fileContent = try NSString(contentsOfFile: elementPath, encoding: String.Encoding.utf16.rawValue) as String
							} catch {
								//TODO: Eventually retry with even more encoding.
							}
						}
						
						newFile.rawContent = fileContent
						newFile.translations = self.parseTranslations(rawContent: fileContent)
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
				combinedFile.path = "\(((self.xcodeProject.pbxprojPath as NSString).deletingLastPathComponent as NSString).deletingLastPathComponent)/\(newFile.folder)/\(newFile.name)"

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

