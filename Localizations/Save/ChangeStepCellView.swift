//
//  ChangeStepCellView.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/28/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class ChangeStepCellView: NSTableCellView {

	@IBOutlet var fileName: NSTextField!
	@IBOutlet var translationsInfo: NSTextField!
	@IBOutlet var filePath: NSTextField!
	@IBOutlet var stepStatus: ATStatusView!
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
