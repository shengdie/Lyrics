//
//  ContextMenuDelegate.swift
//  Lyrics
//
//  Created by Eru on 16/1/14.
//  Copyright © 2016年 Eru. All rights reserved.
//

import Cocoa

protocol ContextMenuDelegate {
    func tableView(_ aTableView: NSTableView, menuForRows rows: IndexSet) -> NSMenu
}
