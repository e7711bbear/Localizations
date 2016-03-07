//
//  Translation.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/3/16.
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

class Translation: NSObject {
	enum State {
		case Edit // Something Changed
		case New // This translation is new
		case Obselete // This translation is no longer used
		case None // Nothing has changed
	}
	
	var key: String = ""
	var value: String = ""
	var comments: String = ""
	var state = State.None
	
	convenience init(key: String, value: String, comments: String) {
		self.init()
		
		self.key = key
		self.value = value
		self.comments = comments
	}
	
	override var description: String {
		get {
			return self.debugDescription
		}
	}
	
	override var debugDescription: String {
		get {
			return "\(comments)\n" +
			"\(self.key) = \(self.value)\n"
		}
	}
}
