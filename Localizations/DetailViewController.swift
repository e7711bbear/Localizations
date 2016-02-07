//
//  DetailViewController.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/6/16.
//  Copyright © 2016 Arnaud Thiercelin. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController {

	weak var appDelegate: AppDelegate! = NSApplication.sharedApplication().delegate as! AppDelegate

	@IBOutlet weak var filesTableView: NSTableView!
	@IBOutlet weak var translationsTableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
	}
    
}
