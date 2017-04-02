//
//  VLCBridge.h
//  Lyrics
//
//  Created by xinmm on 4/1/17.
//  Copyright © 2017 Eru. All rights reserved.
//

#ifndef VLCBridge_h
#define VLCBridge_h

#import <Foundation/Foundation.h>

@interface VLCBridge : NSObject

-(BOOL) running;
-(BOOL) playing;

-(NSString *) currentTitle;
//-(NSString *) currentArtist;
//-(NSString *) currentAlbum;
//-(NSString *) currentPersistentID;
-(NSInteger) playerPosition;
//-(NSData *) artwork;
//-(void) play;
//-(void) pause;

@end

#endif /* VLCBridge_h */
