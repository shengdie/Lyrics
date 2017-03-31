//
//  VoxBridge.h
//  Lyrics
//
//  Created by xinmm on 3/31/17.
//  Copyright © 2017 Eru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoxBridge : NSObject

-(BOOL) running;
-(BOOL) playing;

-(NSString *) currentTitle;
-(NSString *) currentArtist;
-(NSString *) currentAlbum;
-(NSString *) currentPersistentID;
-(NSInteger) playerPosition;
//-(NSData *) artwork;
-(void) play;
-(void) pause;

@end
