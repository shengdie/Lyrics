//
//  LrcParser.swift
//  Lyrics
//
//  Created by Eru on 16/3/25.
//  Copyright © 2016年 Eru. All rights reserved.
//

import Cocoa

enum LrcType: Int {
    case lyrics, title, album, titleAndAlbum, titleAndAlbumSimillar, other
}

class LrcParser: NSObject {
    
    var lyrics: [LyricsLineModel]!
    var idTags: [String]!
    var timeDly: Int = 0
    fileprivate var regexForTimeTag: NSRegularExpression!
    fileprivate var regexForIDTag: NSRegularExpression!
    
    override init() {
        super.init()
        lyrics = [LyricsLineModel]()
        idTags = [String]()
        do {
            regexForTimeTag = try NSRegularExpression(pattern: "\\[\\d+:\\d+.\\d+\\]|\\[\\d+:\\d+\\]", options: [])
        } catch let theError as NSError {
            NSLog("%@", theError.localizedDescription)
            return
        }
        //the regex below should only use when the string doesn't contain time-tags
        //because all time-tags would be matched as well.
        do {
            regexForIDTag = try NSRegularExpression(pattern: "\\[[^\\]]+:[^\\]]+\\]", options: [])
        } catch let theError as NSError {
            NSLog("%@", theError.localizedDescription)
            return
        }
    }
    
    func testLrc(_ lrcContents: String) -> Bool {
        // test whether the string is lrc
        let newLineCharSet: CharacterSet = CharacterSet.newlines
        let lrcParagraphs: [String] = lrcContents.components(separatedBy: newLineCharSet)
        var numberOfMatched: Int = 0
        for str in lrcParagraphs {
            numberOfMatched = regexForTimeTag.numberOfMatches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
            if numberOfMatched > 0 {
                return true
            }
        }
        return false
    }
    
    func regularParse(_ lrcContents: String) {
        NSLog("Start to Parse lrc")
        cleanCache()
        
        var tempLyrics = [LyricsLineModel]()
        var tempIDTags = [String]()
        var tempTimeDly: Int = 0
        let newLineCharSet: CharacterSet = CharacterSet.newlines
        let lrcParagraphs: [String] = lrcContents.components(separatedBy: newLineCharSet)
        
        for str in lrcParagraphs {
            let timeTagsMatched: [NSTextCheckingResult] = regexForTimeTag.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
            if timeTagsMatched.count > 0 {
                let index: Int = timeTagsMatched.last!.range.location + timeTagsMatched.last!.range.length
                let lyricsSentence: String = str.substring(from: str.characters.index(str.startIndex, offsetBy: index))
                for result in timeTagsMatched {
                    let matchedRange: NSRange = result.range
                    let lrcLine: LyricsLineModel = LyricsLineModel()
                    lrcLine.lyricsSentence = lyricsSentence
                    lrcLine.setMsecPositionWithTimeTag((str as NSString).substring(with: matchedRange) as NSString)
                    let currentCount: Int = tempLyrics.count
                    var j: Int = 0
                    while j < currentCount {
                        if lrcLine.msecPosition < tempLyrics[j].msecPosition {
                            tempLyrics.insert(lrcLine, at: j)
                            break
                        }
                        j += 1
                    }
                    if j == currentCount {
                        tempLyrics.append(lrcLine)
                    }
                }
            }
            else {
                let idTagsMatched: [NSTextCheckingResult] = regexForIDTag.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
                if idTagsMatched.count == 0 {
                    continue
                }
                for result in idTagsMatched {
                    let matchedRange: NSRange = result.range
                    let idTag: NSString = (str as NSString).substring(with: matchedRange) as NSString
                    let colonRange: NSRange = idTag.range(of: ":")
                    let idStr: String = idTag.substring(with: NSMakeRange(1, colonRange.location-1))
                    if idStr.replacingOccurrences(of: " ", with: "").lowercased() != "offset" {
                        tempIDTags.append(idTag as String)
                        continue
                    }
                    else {
                        let idContent: String = idTag.substring(with: NSMakeRange(colonRange.location+1, idTag.length-colonRange.length-colonRange.location-1))
                        tempTimeDly = (idContent as NSString).integerValue
                    }
                }
            }
        }
        lyrics = tempLyrics
        idTags = tempIDTags
        timeDly = tempTimeDly
    }
    
    func parseForLyrics(_ lrcContents: String) {
        cleanCache()
        var tempLyrics = [LyricsLineModel]()
        let newLineCharSet: CharacterSet = CharacterSet.newlines
        let lrcParagraphs: [String] = lrcContents.components(separatedBy: newLineCharSet)
        
        for str in lrcParagraphs {
            let timeTagsMatched: [NSTextCheckingResult] = regexForTimeTag.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
            if timeTagsMatched.count > 0 {
                let index: Int = timeTagsMatched.last!.range.location + timeTagsMatched.last!.range.length
                let lyricsSentence: String = str.substring(from: str.characters.index(str.startIndex, offsetBy: index))
                for result in timeTagsMatched {
                    let matchedRange: NSRange = result.range
                    let lrcLine: LyricsLineModel = LyricsLineModel()
                    lrcLine.lyricsSentence = lyricsSentence
                    lrcLine.setMsecPositionWithTimeTag((str as NSString).substring(with: matchedRange) as NSString)
                    let currentCount: Int = tempLyrics.count
                    var j: Int = 0
                    while j < currentCount {
                        if lrcLine.msecPosition < tempLyrics[j].msecPosition {
                            tempLyrics.insert(lrcLine, at: j)
                            break
                        }
                        j += 1
                    }
                    if j == currentCount {
                        tempLyrics.append(lrcLine)
                    }
                }
            }
        }
        lyrics = tempLyrics
    }
    
    func parseWithFilter(_ lrcContents: String, VoxTitle: String?, VoxAlbum: String?) {
        NSLog("Start to Parse lrc")
        cleanCache()
        
        var tempLyrics = [LyricsLineModel]()
        var tempIDTags = [String]()
        var tempTimeDly: Int = 0
        var title = String()
        var album = String()
        var otherIDInfos = [String]()
        let colons = [":","：","∶"]
        
        let newLineCharSet: CharacterSet = CharacterSet.newlines
        let lrcParagraphs: [String] = lrcContents.components(separatedBy: newLineCharSet)
        
        for str in lrcParagraphs {
            let timeTagsMatched: [NSTextCheckingResult] = regexForTimeTag.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
            if timeTagsMatched.count > 0 {
                let index: Int = timeTagsMatched.last!.range.location + timeTagsMatched.last!.range.length
                let lyricsSentence: String = str.substring(from: str.characters.index(str.startIndex, offsetBy: index))
                for result in timeTagsMatched {
                    let matchedRange: NSRange = result.range
                    let lrcLine: LyricsLineModel = LyricsLineModel()
                    lrcLine.lyricsSentence = lyricsSentence
                    lrcLine.setMsecPositionWithTimeTag((str as NSString).substring(with: matchedRange) as NSString)
                    let currentCount: Int = tempLyrics.count
                    var j: Int = 0
                    while j < currentCount {
                        if lrcLine.msecPosition < tempLyrics[j].msecPosition {
                            tempLyrics.insert(lrcLine, at: j)
                            break
                        }
                        j += 1
                    }
                    if j == currentCount {
                        tempLyrics.append(lrcLine)
                    }
                }
            }
            else {
                let idTagsMatched: [NSTextCheckingResult] = regexForIDTag.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
                if idTagsMatched.count == 0 {
                    continue
                }
                for result in idTagsMatched {
                    let matchedRange: NSRange = result.range
                    let idTag: NSString = (str as NSString).substring(with: matchedRange) as NSString
                    let colonRange: NSRange = idTag.range(of: ":")
                    let idStr: String = idTag.substring(with: NSMakeRange(1, colonRange.location-1)).replacingOccurrences(of: " ", with: "")
                    let idContent: String = idTag.substring(with: NSMakeRange(colonRange.location+1, idTag.length-colonRange.length-colonRange.location-1)).replacingOccurrences(of: " ", with: "")
                    switch idStr.lowercased() {
                    case "offset":
                        tempTimeDly = (idContent as NSString).integerValue
                    case "ti":
                        tempIDTags.append(idTag as String)
                        title = idContent
                    case "al":
                        tempIDTags.append(idTag as String)
                        album = idContent
                    default:
                        tempIDTags.append(idTag as String)
                        otherIDInfos.append(idContent)
                    }
                }
            }
        }
        //Filter
        //过滤主要的思路是：1.歌词中若出现"直接过滤列表"中的关键字则直接清除该行
        //               2.歌词中若出现"条件过滤列表"中的关键字以及各种形式冒号则清除该行
        //               3.如果开启智能过滤，则将lrc文件中的ID-Tag内容（包含歌曲名、专辑名、制作者等）作为过滤关键字，
        //                 由于在歌词中嵌入的歌曲信息主要集中在前10行并连续出现，为了防止误过滤（有些歌词本身就含有歌
        //                 曲名），过滤需要参照上下文，如果上下文有空行则顺延。如果连续出现歌曲名或者专辑名则认为是歌词
        //                 本身有该字符串，比如歌曲名是"You"，歌词为"You are great"，如果歌词大于等于歌曲名的5倍也认
        //                 为歌词本身有歌曲名。
        let userDefaults = UserDefaults.standard
        let directFilter = NSKeyedUnarchiver.unarchiveObject(with: userDefaults.data(forKey: LyricsDirectFilterKey)!) as! [FilterString]
        let conditionalFilter = NSKeyedUnarchiver.unarchiveObject(with: userDefaults.data(forKey: LyricsConditionalFilterKey)!) as! [FilterString]
        let isIDTagTitleAlbumSimillar: Bool = (title.range(of: album) != nil) || (album.range(of: title) != nil)
        let isVoxTitleAlbumSimillar: Bool
        if VoxTitle != nil && VoxAlbum != nil {
            isVoxTitleAlbumSimillar = (VoxTitle!.range(of: VoxAlbum!) != nil) || (VoxAlbum!.range(of: VoxTitle!) != nil)
        }
        else {
            isVoxTitleAlbumSimillar = false
        }
        let isTitleAlbumSimillar: Bool = isIDTagTitleAlbumSimillar || isVoxTitleAlbumSimillar
        var prevLrcType: LrcType = .lyrics
        var emptyLine: Int = 0
        var lastTitleAlbumSimillarIdx = -1
        
        MainLoop: for index in 0 ..< tempLyrics.count {
            var currentLrcType: LrcType = .lyrics
            let line = tempLyrics[index].lyricsSentence.replacingOccurrences(of: " ", with: "")
            if line == "" {
                emptyLine += 1
                continue MainLoop
            }
            for filter in directFilter {
                let searchResult: Bool
                if filter.caseSensitive {
                    searchResult = line.range(of: filter.keyword) != nil
                }
                else {
                    searchResult = line.range(of: filter.keyword, options: [.caseInsensitive], range: nil, locale: nil) != nil
                }
                if searchResult {
                    if prevLrcType == .title || prevLrcType == .album {
                        tempLyrics[index-1-emptyLine].enabled = false
                    }
                    else if prevLrcType == .titleAndAlbumSimillar {
                        if lastTitleAlbumSimillarIdx != -1 {
                            tempLyrics[lastTitleAlbumSimillarIdx].enabled = false
                            lastTitleAlbumSimillarIdx = -1
                        }
                        tempLyrics[index-1-emptyLine].enabled = false
                    }
                    tempLyrics[index].enabled = false
                    prevLrcType = .other
                    continue MainLoop
                }
            }
            
            for filter in conditionalFilter {
                let searchResult: Bool
                if filter.caseSensitive {
                    searchResult = line.range(of: filter.keyword) != nil
                }
                else {
                    searchResult = line.range(of: filter.keyword, options: [.caseInsensitive], range: nil, locale: nil) != nil
                }
                if searchResult {
                    for aColon in colons {
                        if line.range(of: aColon) != nil {
                            if prevLrcType == .title || prevLrcType == .album {
                                tempLyrics[index-1-emptyLine].enabled = false
                            }
                            else if prevLrcType == .titleAndAlbumSimillar {
                                if lastTitleAlbumSimillarIdx != -1 {
                                    tempLyrics[lastTitleAlbumSimillarIdx].enabled = false
                                    lastTitleAlbumSimillarIdx = -1
                                }
                                tempLyrics[index-1-emptyLine].enabled = false
                            }
                            tempLyrics[index].enabled = false
                            prevLrcType = .other
                            continue MainLoop
                        }
                    }
                }
            }
            
            if userDefaults.bool(forKey: LyricsEnableSmartFilter) {
                var ignoreTitle: Bool = false
                var ignoreAlbum: Bool = false
                
                let hasIDTagTitle: Bool = (line.range(of: title, options: [.caseInsensitive], range: nil, locale: nil) != nil) || (title.range(of: line, options: [.caseInsensitive], range: nil, locale: nil) != nil)
                
                if hasIDTagTitle {
                    if line.characters.count/title.characters.count > 4 {
                        ignoreTitle = true
                    }
                }
                
                let hasIDTagAlbum: Bool = (line.range(of: album, options: [.caseInsensitive], range: nil, locale: nil) != nil) || (album.range(of: line, options: [.caseInsensitive], range: nil, locale: nil) != nil)
                
                if hasIDTagAlbum {
                    if line.characters.count/album.characters.count > 4 {
                        ignoreAlbum = true
                    }
                }
                
                let hasVoxTitle: Bool
                if VoxTitle == nil {
                    hasVoxTitle = false
                }
                else {
                    hasVoxTitle = (line.range(of: VoxTitle!, options: [.caseInsensitive], range: nil, locale: nil) != nil) || (VoxTitle!.range(of: line, options: [.caseInsensitive], range: nil, locale: nil) != nil)
                    if !ignoreTitle && hasVoxTitle {
                        if line.characters.count/VoxTitle!.characters.count > 4 {
                            ignoreTitle = true
                        }
                    }
                }
                
                let hasVoxAlbum: Bool
                if VoxAlbum == nil {
                    hasVoxAlbum = false
                }
                else {
                    hasVoxAlbum = (line.range(of: VoxAlbum!, options: [.caseInsensitive], range: nil, locale: nil) != nil) || (VoxAlbum!.range(of: line, options: [.caseInsensitive], range: nil, locale: nil) != nil)
                    if !ignoreAlbum && hasVoxAlbum {
                        if line.characters.count/VoxAlbum!.characters.count > 4 {
                            ignoreAlbum = true
                        }
                    }
                }
                
                let hasTitle: Bool = hasIDTagTitle || hasVoxTitle
                let hasAlbum: Bool = hasIDTagAlbum || hasVoxAlbum
                
                for str in otherIDInfos {
                    if line.range(of: str, options: [.caseInsensitive], range: nil, locale: nil) != nil {
                        if prevLrcType == .title || prevLrcType == .album {
                            tempLyrics[index-1-emptyLine].enabled = false
                        }
                        else if prevLrcType == .titleAndAlbumSimillar {
                            if lastTitleAlbumSimillarIdx != -1 {
                                tempLyrics[lastTitleAlbumSimillarIdx].enabled = false
                                lastTitleAlbumSimillarIdx = -1
                            }
                            tempLyrics[index-1-emptyLine].enabled = false
                        }
                        tempLyrics[index].enabled = false
                        prevLrcType = .other
                        continue MainLoop
                    }
                }
                
                if hasTitle && hasAlbum {
                    if isTitleAlbumSimillar {
                        if !ignoreTitle && !ignoreAlbum {
                            currentLrcType = .titleAndAlbumSimillar
                            if prevLrcType == .titleAndAlbumSimillar {
                                if lastTitleAlbumSimillarIdx == -1 {
                                    lastTitleAlbumSimillarIdx = index-1-emptyLine
                                }
                                else {
                                    currentLrcType = .lyrics
                                }
                            }
                        }
                    }
                    else {
                        if prevLrcType == .title || prevLrcType == .album {
                            tempLyrics[index-1-emptyLine].enabled = false
                        }
                        tempLyrics[index].enabled = false
                        prevLrcType = .titleAndAlbum
                        continue MainLoop
                    }
                }
                else if hasAlbum && !ignoreAlbum {
                    if prevLrcType == .title {
                        tempLyrics[index-1-emptyLine].enabled = false
                        tempLyrics[index].enabled = false
                        prevLrcType = .album
                        continue MainLoop
                    }
                    else if prevLrcType == .other || prevLrcType == .titleAndAlbum {
                        tempLyrics[index].enabled = false
                        prevLrcType = .album
                        continue MainLoop
                    }
                    else if prevLrcType == .titleAndAlbumSimillar {
                        if lastTitleAlbumSimillarIdx == -1 {
                            tempLyrics[index-1-emptyLine].enabled = false
                            tempLyrics[index].enabled = false
                        }
                        else {
                            currentLrcType = .lyrics
                        }
                    }
                    else {
                        currentLrcType = .album
                    }
                }
                else if hasTitle && !ignoreTitle {
                    if prevLrcType == .album {
                        tempLyrics[index-1-emptyLine].enabled = false
                        tempLyrics[index].enabled = false
                        prevLrcType = .title
                        continue MainLoop
                    }
                    else if prevLrcType == .other || prevLrcType == .titleAndAlbum {
                        tempLyrics[index].enabled = false
                        prevLrcType = .title
                        continue MainLoop
                    }
                    else if prevLrcType == .titleAndAlbumSimillar {
                        if lastTitleAlbumSimillarIdx == -1 {
                            tempLyrics[index-1-emptyLine].enabled = false
                            tempLyrics[index].enabled = false
                        }
                        else {
                            currentLrcType = .lyrics
                        }
                    }
                    else {
                        currentLrcType = .title
                    }
                }
            }
            
            if currentLrcType == .lyrics && lastTitleAlbumSimillarIdx != -1 {
                lastTitleAlbumSimillarIdx = -1
            }
            prevLrcType = currentLrcType
            if line != "" {
                emptyLine = 0
            }
        }
        lyrics = tempLyrics
        idTags = tempIDTags
        timeDly = tempTimeDly
    }
    
    func cleanCache() {
        lyrics.removeAll()
        idTags.removeAll()
        timeDly = 0
    }
    
}
