//
//  TrackWaveformCache.h
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Track;

extern NSString * const TrackWaveformCacheDidCreateImage;



@interface TrackWaveformCache : NSObject

+ (instancetype)sharedCache;

- (UIImage *)waveformImageForTrack:(Track *)track;

@end
