//
//  VLCBridge.m
//  Lyrics
//
//  Created by xinmm on 4/1/17.
//  Copyright © 2017 Eru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLCBridge.h"
#import "VLC.h"

@implementation VLCBridge {
    VLCApplication *vlc;
}

-(id)init {
    self = [super init];
    if (self) {
        vlc = [SBApplication applicationWithBundleIdentifier:@"org.videolan.vlc"];
    }
    return self;
}

-(BOOL) running {
    @autoreleasepool {
        return vlc.isRunning;
    }
}

-(BOOL) playing {
    @autoreleasepool {
        return (vlc.playing);
    }
}

-(NSString *) currentTitle {
    @autoreleasepool {
        NSString *titleWithExt = vlc.nameOfCurrentItem;
        if (!titleWithExt) {
            titleWithExt = @"";
            return titleWithExt;
        }
        else {
            // remove the extension of filename
            NSString *title = [titleWithExt substringToIndex:[titleWithExt length]-4];
            return title;
        }
    }
}
/*
-(NSString *) currentArtist {
    @autoreleasepool {
        NSString *artist = vox.artist;
        if (!artist) {
            artist = @"";
        }
        return artist;
    }
}*/

/*
-(NSString *) currentAlbum {
    @autoreleasepool {
        NSString *album = vox.album;
        if (!album) {
            album = @"";
        }
        return album;
    }
}*/

/*
-(NSString *) currentPersistentID {
    @autoreleasepool {
        NSString *persistentID = vox.uniqueID;
        if (!persistentID) {
            persistentID = @"";
        }
        return persistentID;
    }
}*/

-(NSInteger) playerPosition {
    @autoreleasepool {
        return (vlc.currentTime * 1000);
    }
}

/*
-(void) play {
    @autoreleasepool {
        if (!vlc.playing) { //Not Playing
            ;
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
*/

@end
