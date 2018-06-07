//
//  ATStatusView.swift
//  Localizations
//
//  Created by Arnaud Thiercelin on 2/28/16.
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
	
	var newColor = NSColor(calibratedRed: 0, green: 0.871, blue: 0, alpha: 1)
	var editColor = NSColor.yellow
	var deleteColor = NSColor(calibratedRed: 0.871, green: 0, blue: 0, alpha: 1)
	var inProgressColor = NSColor(calibratedRed: 0, green: 0, blue: 0.871, alpha: 1)
	var successColor = NSColor.green
	var errorColor = NSColor.red
	var noneColor = NSColor.lightGray
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

		self.drawDashedFrame(rect: dirtyRect)

		switch self.state {
		case .New:
			self.drawNew(rect: dirtyRect)
		case .Edit:
			self.drawEdit(rect: dirtyRect)
		case .Delete:
			self.drawDelete(rect: dirtyRect)
		case .InProgress:
			self.drawInProgress(rect: dirtyRect)
		case .Success:
			self.drawSuccess(rect: dirtyRect)
		case .Error:
			self.drawError(rect: dirtyRect)
		case .None:
			self.drawNone(rect: dirtyRect)
		}
	}
	
	// The reason for the "/200" is because these drawing were made in a 200x200 
	// canvas in paintcode. - AT 02/2016
	func drawDashedFrame(rect: NSRect) {
		let framePath = NSBezierPath(ovalIn: NSMakeRect(3/200*rect.width, 3/200*rect.height, 194/200*rect.width, 194/200*rect.height))
		NSColor.lightGray.setStroke()
		framePath.lineWidth = 5/200*rect.width
		framePath.setLineDash([10/200*rect.width, 4/200*rect.width], count: 2, phase: 0)
		framePath.stroke()

	}
	
	func drawBackgroundCircle(rect: NSRect, color: NSColor) {
		let backgroundCirclePath = NSBezierPath(ovalIn: NSMakeRect(7/200*rect.width, 7/200*rect.height, 186/200*rect.width, 186/200*rect.height))
		color.setFill()
		backgroundCirclePath.fill()
	}
	
	func drawTextCenteredInRect(rect: NSRect, text: String) {
		//// Text Drawing
		let textRect = NSMakeRect(33/200*rect.width, 36/200*rect.height, 134/200*rect.width, 129/200*rect.height)
		let textTextContent = NSString(string: text)
		let textStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		textStyle.alignment = .center
		
		let textFontAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): NSFont.systemFont(ofSize: 144/200*rect.width), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): NSColor.white, convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textStyle]
		
		let textTextHeight: CGFloat = textTextContent.boundingRect(with: NSMakeSize(textRect.width, CGFloat.infinity), options: NSString.DrawingOptions.usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(textFontAttributes)).size.height
		let textTextRect: NSRect = NSMakeRect(textRect.minX, textRect.minY + (textRect.height - textTextHeight) / 2, textRect.width, textTextHeight)
		NSGraphicsContext.saveGraphicsState()
		__NSRectClip(textRect)
		textTextContent.draw(in: NSOffsetRect(textTextRect, 0, 0), withAttributes: convertToOptionalNSAttributedStringKeyDictionary(textFontAttributes))
		NSGraphicsContext.restoreGraphicsState()
	}
	
	func drawNew(rect: NSRect) {
		self.drawBackgroundCircle(rect: rect, color: self.newColor)
		self.drawTextCenteredInRect(rect: rect, text: "✚")
	}
	
	func drawEdit(rect: NSRect) {
		self.drawBackgroundCircle(rect: rect, color: self.editColor)
		self.drawTextCenteredInRect(rect: rect, text: "✎")
	}
	
	func drawDelete(rect: NSRect) {
		self.drawBackgroundCircle(rect: rect, color: self.deleteColor)
		self.drawTextCenteredInRect(rect: rect, text: "✖︎")
	}
	
	func drawInProgress(rect: NSRect) {
		self.drawBackgroundCircle(rect: rect, color: self.inProgressColor)
		self.drawTextCenteredInRect(rect: rect, text: "❀")
	}
	
	func drawSuccess(rect: NSRect) {
		self.drawBackgroundCircle(rect: rect, color: self.successColor)
		self.drawTextCenteredInRect(rect: rect, text: "✓")
	}
	
	func drawError(rect: NSRect) {
		self.drawBackgroundCircle(rect: rect, color: self.errorColor)
		self.drawTextCenteredInRect(rect: rect, text: "💩")
	}
	
	func drawNone(rect: NSRect) {
		self.drawBackgroundCircle(rect: rect, color: self.noneColor)
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
