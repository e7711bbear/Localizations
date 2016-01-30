//
//  DetailViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 1/30/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController {

	@IBOutlet weak var splitView: NSSplitView!
	@IBOutlet weak var filesTableView: NSTableView!
	@IBOutlet weak var contentTableView: NSTableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
