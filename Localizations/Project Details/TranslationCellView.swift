//
//  TranslationCellView.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/7/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class TranslationCellView: NSTableCellView {

	@IBOutlet weak var key: NSTextField!
	@IBOutlet weak var value: NSTextField!
	@IBOutlet weak var comments: NSTextField!
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
