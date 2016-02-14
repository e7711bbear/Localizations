//
//  DetailViewController+Save.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/14/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Foundation

extension DetailViewController {
	
	func createFile(file: File) {
		
	}
	
	func editFile(file: File) {
		
	}
	
	func deleteFile(file: File) {
		
	}
	
	func publish() {
		let fileManager = NSFileManager.defaultManager()
		
		guard self.appDelegate.mainViewController.rootDirectory != nil else {
			// TODO: Error handling here.
			return
		}
		
		//TODO: implementation
		
		var isDirectory: ObjCBool = false
		
		// Sandboxing
		//		self.appDelegate.mainViewController.rootDirectory.startAccessingSecurityScopedResource()
		
		if fileManager.fileExistsAtPath(self.appDelegate.mainViewController.rootDirectory!.path!, isDirectory: &isDirectory) {
			if isDirectory {
				// TODO: Alert here -- about to publish
				
				// If yes at alert ->
				
				for file in self.appDelegate.mainViewController.combinedFiles {
					switch file.state {
					case .New:
						self.createFile(file)
					case .Edit:
						self.editFile(file)
					case .Obselete:
						self.deleteFile(file)
					default:
						continue
					}
				}
			}
		}
		// Sandboxing
		// self.appDelegate.mainViewController.rootDirectory.stopAccessingSecurityScopedResource()
	}

}