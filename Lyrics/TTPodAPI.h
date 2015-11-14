//
//  TTPodAPI.h
//  LrcSeeker
//
//  Created by Eru on 15/10/23.
//  Copyright © 2015年 Eru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongInfos.h"

extern NSString *const TTPodLrcLoadedNotification;

@interface TTPodAPI : NSObject

@property SongInfos *songInfo;


-(void)getLyricsWithTitle:(NSString *)theTitle artist:(NSString *)theArtist;

@end