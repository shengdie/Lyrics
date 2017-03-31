//
//  MessageWindowController.swift
//  Lyrics
//
//  Created by Eru on 15/12/22.
//  Copyright © 2015年 Eru. All rights reserved.
//

import Cocoa

class MessageWindowController: NSWindowController {
    
    static let sharedMsgWindow = MessageWindowController()
    
    var msgText: CATextLayer!
    var attrs: [String:AnyObject]!
    var isOrderFront: Bool = false
    var timer: Timer!

    convenience init() {
        NSLog("Init MessageWindow")
        let win = NSWindow(contentRect: NSZeroRect, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.buffered, defer: false)
        self.init(window: win)
        self.window?.isOpaque = false
        self.window?.hasShadow = false
        self.window?.ignoresMouseEvents = true
        self.window?.level = Int(CGWindowLevelForKey(.floatingWindow))
        self.window?.backgroundColor = NSColor.clear
        self.window?.contentView?.layer = CALayer()
        self.window?.contentView?.wantsLayer = true
        self.window?.contentView?.layer?.backgroundColor = NSColor(calibratedWhite: 0, alpha: 0.65).cgColor
        self.window?.contentView?.layer?.cornerRadius = 15
        
        msgText = CATextLayer()
        msgText.anchorPoint = NSZeroPoint
        msgText.position = NSZeroPoint
        msgText.alignmentMode = kCAAlignmentCenter
        msgText.font = NSFont(name: "HiraginoSansGB-W6", size: 20)
        msgText.fontSize = 20
        msgText.foregroundColor = NSColor.white.cgColor
        msgText.speed = 12
        self.window?.contentView?.layer?.addSublayer(msgText)
        
        attrs = [NSFontAttributeName : NSFont(name: "HiraginoSansGB-W6", size: 20)!]
        self.window?.orderOut(nil)
    }
    
    func displayMessage(_ msgStr: String) {
        let attributedStr = NSAttributedString(string: msgStr, attributes: attrs)
        let size = attributedStr.size()
        let screenFrame = NSScreen.main()?.visibleFrame
        let x: CGFloat = (screenFrame?.size.width)! + (screenFrame?.origin.x)! - (size.width+100)
        let y: CGFloat = (screenFrame?.size.height)! + (screenFrame?.origin.y)! - (size.height+60)
        self.window!.setFrame(NSMakeRect(x, y, size.width + 30, size.height + 30), display: true)
        msgText.string = msgStr
        msgText.frame = NSMakeRect(0, 15, size.width + 30, size.height)
        if !isOrderFront {
            self.window!.alphaValue = 0
            self.window!.makeKeyAndOrderFront(nil)
            isOrderFront = true
            self.window!.animator().alphaValue = 1
        }
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(fadeOut), userInfo: nil, repeats: false)
    }
    
    func fadeOut() {
        let delay: TimeInterval = NSAnimationContext.current().duration + 0.1
        self.window!.perform(#selector(NSWindow.orderOut(_:)), with: nil, afterDelay: delay)
        self.window!.animator().alphaValue = 0
        msgText.string = ""
        isOrderFront = false
    }

}
