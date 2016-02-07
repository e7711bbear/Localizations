//
//  FileCellView.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class FileCellView: NSTableCellView {

	@IBOutlet weak var fileName: NSTextField!
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
