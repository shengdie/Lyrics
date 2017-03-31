//
//  TextPreview.swift
//  Lyrics
//
//  Created by Eru on 15/11/18.
//  Copyright © 2015年 Eru. All rights reserved.
//

import Cocoa

class TextPreview: NSView {
    
    fileprivate var attributes: [String:AnyObject]
    fileprivate var backgroundColor: NSColor
    fileprivate var image: NSImage
    fileprivate var bkLayer: CALayer!
    fileprivate var textLayer: CATextLayer!
    fileprivate var textYOffset: CGFloat!
    fileprivate var bgHeightIncreasement: CGFloat!
    fileprivate var lyricsHeightIncreasement: CGFloat!
    fileprivate let stringValue: String = NSLocalizedString("PREVIEW_TEXT", comment: "")

    required init?(coder: NSCoder) {
        attributes = [String:AnyObject]()
        backgroundColor = NSColor.black
        image = NSImage(named: "preview_bkground")!
        super.init(coder: coder)
        
        self.layer = CALayer()
        self.layer?.speed = 5
        self.wantsLayer = true
        self.layer?.contents = image
        
        
        bkLayer = CALayer()
        bkLayer.speed = 5
        bkLayer.anchorPoint = NSZeroPoint
        bkLayer.position = NSZeroPoint
        bkLayer.cornerRadius = 12
        self.layer?.addSublayer(bkLayer)
        
        textLayer = CATextLayer()
        textLayer.speed = 5
        textLayer.anchorPoint = NSZeroPoint
        textLayer.position = NSZeroPoint
        textLayer.alignmentMode = kCAAlignmentCenter
        bkLayer.addSublayer(textLayer)
    }
    
    func setAttributs(_ font:NSFont, textColor:NSColor, bkColor:NSColor, heightInrc:Float, enableShadow:Bool, shadowColor:NSColor, shadowRadius:Float, yOffset:Float) {
        backgroundColor = bkColor
        attributes.removeAll()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = font
        bgHeightIncreasement = CGFloat(heightInrc)
        if bgHeightIncreasement < 0 {
            lyricsHeightIncreasement = 0
        } else {
            lyricsHeightIncreasement = bgHeightIncreasement
        }
        textYOffset = CGFloat(yOffset)
        if enableShadow {
            textLayer.shadowColor = shadowColor.cgColor
            textLayer.shadowRadius = CGFloat(shadowRadius)
            textLayer.shadowOffset = NSZeroSize
            textLayer.shadowOpacity = 1
        } else {
            textLayer.shadowOpacity = 0
        }
        drawContents()
    }
    
    fileprivate func drawContents() {
        let viewSize = self.bounds.size
        let attrString: NSAttributedString = NSAttributedString(string: stringValue, attributes: attributes)
        var strSize: NSSize = attrString.size()
        strSize.width += 50
        bkLayer.backgroundColor = backgroundColor.cgColor
        bkLayer.frame.size = NSMakeSize(strSize.width, strSize.height+bgHeightIncreasement)
        bkLayer.frame.origin = NSMakePoint((viewSize.width-strSize.width)/2, (viewSize.height-strSize.height)/2)
        
        textLayer.frame = NSMakeRect(0, textYOffset, strSize.width, strSize.height+lyricsHeightIncreasement)
        textLayer.string = attrString
    }
    
}
