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
	
	var newColor = NSColor(calibratedRed: 0, green: 0.871, blue: 0, alpha: 1)
	var editColor = NSColor.yellowColor()
	var deleteColor = NSColor(calibratedRed: 0.871, green: 0, blue: 0, alpha: 1)
	var inProgressColor = NSColor(calibratedRed: 0, green: 0, blue: 0.871, alpha: 1)
	var successColor = NSColor.greenColor()
	var errorColor = NSColor.redColor()
	var noneColor = NSColor.lightGrayColor()
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

		self.drawDashedFrame(dirtyRect)

		switch self.state {
		case .New:
			self.drawNew(dirtyRect)
		case .Edit:
			self.drawEdit(dirtyRect)
		case .Delete:
			self.drawDelete(dirtyRect)
		case .InProgress:
			self.drawInProgress(dirtyRect)
		case .Success:
			self.drawSuccess(dirtyRect)
		case .Error:
			self.drawError(dirtyRect)
		case .None:
			self.drawNone(dirtyRect)
		}
	}
	
	// The reason for the "/200" is because these drawing were made in a 200x200 
	// canvas in paintcode. - AT 02/2016
	func drawDashedFrame(rect: NSRect) {
		let framePath = NSBezierPath(ovalInRect: NSMakeRect(3/200*rect.width, 3/200*rect.height, 194/200*rect.width, 194/200*rect.height))
		NSColor.lightGrayColor().setStroke()
		framePath.lineWidth = 5/200*rect.width
		framePath.setLineDash([10/200*rect.width, 4/200*rect.width], count: 2, phase: 0)
		framePath.stroke()

	}
	
	func drawBackgroundCircle(rect: NSRect, color: NSColor) {
		let backgroundCirclePath = NSBezierPath(ovalInRect: NSMakeRect(7/200*rect.width, 7/200*rect.height, 186/200*rect.width, 186/200*rect.height))
		color.setFill()
		backgroundCirclePath.fill()
	}
	
	func drawTextCenteredInRect(rect: NSRect, text: String) {
		//// Text Drawing
		let textRect = NSMakeRect(33/200*rect.width, 36/200*rect.height, 134/200*rect.width, 129/200*rect.height)
		let textTextContent = NSString(string: text)
		let textStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
		textStyle.alignment = .Center
		
		let textFontAttributes = [NSFontAttributeName: NSFont.systemFontOfSize(144/200*rect.width), NSForegroundColorAttributeName: NSColor.whiteColor(), NSParagraphStyleAttributeName: textStyle]
		
		let textTextHeight: CGFloat = textTextContent.boundingRectWithSize(NSMakeSize(textRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes).size.height
		let textTextRect: NSRect = NSMakeRect(textRect.minX, textRect.minY + (textRect.height - textTextHeight) / 2, textRect.width, textTextHeight)
		NSGraphicsContext.saveGraphicsState()
		NSRectClip(textRect)
		textTextContent.drawInRect(NSOffsetRect(textTextRect, 0, 0), withAttributes: textFontAttributes)
		NSGraphicsContext.restoreGraphicsState()
	}
	
	func drawNew(rect: NSRect) {
		self.drawBackgroundCircle(rect, color: self.newColor)
		self.drawTextCenteredInRect(rect, text: "✚")
	}
	
	func drawEdit(rect: NSRect) {
		self.drawBackgroundCircle(rect, color: self.editColor)
		self.drawTextCenteredInRect(rect, text: "✎")
	}
	
	func drawDelete(rect: NSRect) {
		self.drawBackgroundCircle(rect, color: self.deleteColor)
		self.drawTextCenteredInRect(rect, text: "✖︎")
	}
	
	func drawInProgress(rect: NSRect) {
		self.drawBackgroundCircle(rect, color: self.inProgressColor)
		self.drawTextCenteredInRect(rect, text: "❀")
	}
	
	func drawSuccess(rect: NSRect) {
		self.drawBackgroundCircle(rect, color: self.successColor)
		self.drawTextCenteredInRect(rect, text: "✓")
	}
	
	func drawError(rect: NSRect) {
		self.drawBackgroundCircle(rect, color: self.errorColor)
		self.drawTextCenteredInRect(rect, text: "💩")
	}
	
	func drawNone(rect: NSRect) {
		self.drawBackgroundCircle(rect, color: self.noneColor)
	}
}
