//
//  RegionCellView.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/19/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class RegionCellView: NSTableCellView {

	@IBOutlet weak var name: NSTextField!
	@IBOutlet weak var code: NSTextField!

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
