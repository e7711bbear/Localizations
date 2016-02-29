//
//  ATStatusView.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/28/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ATStatusView: NSView {

	enum State {
		case New
		case Edit
		case Delete
		case InProgress
		case Success
		case Error
		case None
	}
	
	var state: State = .None
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
	
	func drawNew(rect: NSRect) {
		
	}
	
	func drawEdit(rect: NSRect) {
		
	}
	
	func drawDelete(rect: NSRect) {
		
	}
	
	func drawInProgress(rect: NSRect) {
		
	}
	
	func drawSuccess(rect: NSRect) {
		
	}
	
	func drawError(rect: NSRect) {
		
	}
	
	func drawNone(rect: NSRect) {
		
	}
}
