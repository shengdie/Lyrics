//
//  VoxBridge.m
//  Lyrics
//
//  Created by xinmm on 3/31/17.
//  Copyright © 2017 Eru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoxBridge.h"
#import "Vox.h"

@implementation VoxBridge {
    VoxApplication *vox;
}

-(id)init {
    self = [super init];
    if (self) {
        vox = [SBApplication applicationWithBundleIdentifier:@"com.coppertino.Vox"];
    }
    return self;
}

-(BOOL) running {
    @autoreleasepool {
        return vox.isRunning;
    }
}

-(BOOL) playing {
    @autoreleasepool {
        return (vox.playerState == 1);
    }
}

-(NSString *) currentTitle {
    @autoreleasepool {
        NSString *title = vox.track;
        if (!title) {
            title = @"";
        }
        return title;
    }
}

-(NSString *) currentArtist {
    @autoreleasepool {
        NSString *artist = vox.artist;
        if (!artist) {
            artist = @"";
        }
        return artist;
    }
}

-(NSString *) currentAlbum {
    @autoreleasepool {
        NSString *album = vox.album;
        if (!album) {
            album = @"";
        }
        return album;
    }
}


-(NSString *) currentPersistentID {
    @autoreleasepool {
        NSString *persistentID = vox.uniqueID;
        if (!persistentID) {
            persistentID = @"";
        }
        return persistentID;
    }
}

-(NSInteger) playerPosition {
    @autoreleasepool {
        return (NSInteger)(vox.currentTime * 1000);
    }
}

-(void) play {
    @autoreleasepool {
        if (vox.playerState != 1) { //Not Playing
            [vox playpause];
        }
    }
}
-(void) pause {
    @autoreleasepool {
        if (vox.playerState == 1) {
            [vox playpause];
        }
    }
}

@end
