//
//  TrackWaveformCache.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//
//
//
//
// This code relies on the fact that the waveformURL propery on Track is thread safe.
// It's treadsafe, because it's immutable.
//

#import "TrackWaveformCache.h"

#import "Track.h"

#import <libkern/OSAtomic.h>



NSString * const TrackWaveformCacheDidCreateImage = @"TrackWaveformCacheDidCreateImage";
static int const ImageProcessingConcurrencyCount = 8;
static int const CacheMaxCount = 400;




static CGFloat deviceScale(void)
{
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}



@interface TrackWaveformCacheEntry : NSObject

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) Track *track;

@end



@interface TrackWaveformCache ()

@property(nonatomic, strong) dispatch_queue_t cacheIsolation;
@property(nonatomic, strong) NSMutableArray *cachedImages;

@property(nonatomic, strong) dispatch_queue_t creationIsolation;
@property(nonatomic, strong) NSMutableArray *pendingTracks;
@property(nonatomic, strong) NSMutableArray *inPorcessTracks;

@property(nonatomic, strong) NSOperationQueue *urlConnectionQueue;

@end



@implementation TrackWaveformCache

+ (instancetype)sharedCache;
{
    static TrackWaveformCache *sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] init];
    });
    return sharedCache;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.cacheIsolation = dispatch_queue_create("TrackWaveformCache.isolation", DISPATCH_QUEUE_CONCURRENT);
        self.cachedImages = [NSMutableArray array];
        
        self.creationIsolation = dispatch_queue_create("TrackWaveformCache.create.isolation", 0);
        dispatch_set_target_queue(self.creationIsolation, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
        self.pendingTracks = [NSMutableArray array];
        self.inPorcessTracks = [NSMutableArray array];
        
        self.urlConnectionQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (UIImage *)waveformImageForTrack:(Track *)track;
{
    if (track.waveformURL == nil) {
        return nil;
    }
    __block UIImage *result = nil;
    dispatch_sync(self.cacheIsolation, ^{
        NSInteger idx = [self.cachedImages indexOfObjectPassingTest:^BOOL(TrackWaveformCacheEntry *entry, NSUInteger idx, BOOL *stop) {
            (void) idx;
            (void) stop;
            return (entry.track == track);
        }];
        if (idx != NSNotFound) {
            // Move to end of LRU cache:
            TrackWaveformCacheEntry *entry = self.cachedImages[idx];
            [self.cachedImages removeObjectAtIndex:idx];
            [self.cachedImages addObject:entry];
            result = entry.image;
        }
    });
    if (result == nil) {
        [self asyncCreateImageForTrack:track];
    }
    return result;
}

- (void)asyncCreateImageForTrack:(Track *)track;
{
    dispatch_async(self.creationIsolation, ^{
        BOOL isEnqueued = NO;
        for (Track *otherTrack in self.pendingTracks) {
            if (otherTrack == track) {
                isEnqueued = YES;
                break;
            }
        }
        if (!isEnqueued) {
            for (Track *otherTrack in self.inPorcessTracks) {
                if (otherTrack == track) {
                    isEnqueued = YES;
                    break;
                }
            }
        }
        if (!isEnqueued) {
            [self.pendingTracks addObject:track];
            [self maybeProcessNextTrack];
        }
    });
}

- (void)maybeProcessNextTrack;
{
    dispatch_async(self.creationIsolation, ^{
        if ([self.inPorcessTracks count] < ImageProcessingConcurrencyCount) {
            Track *nextTrack = [self.pendingTracks lastObject];
            if (nextTrack != nil) {
                [self.inPorcessTracks addObject:nextTrack];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [self downloadWaveformForTrack:nextTrack];
                });
            }
        }
    });
}

- (void)downloadWaveformForTrack:(Track *)track;
{
    NSURLRequest *request = [NSURLRequest requestWithURL:track.waveformURL];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Need this to run on the main queue which as has a run loop:
        [NSURLConnection sendAsynchronousRequest:request queue:self.urlConnectionQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            if (data == nil) {
                [self blacklistTrack:track];
            } else {
                NSHTTPURLResponse *httpResponse = (id) response;
                NSString *contentType = [httpResponse allHeaderFields][@"Content-Type"];
                if (![contentType isEqualToString:@"image/png"]) {
                    [self blacklistTrack:track];
                } else {
                    [self processImageData:data forTrack:track];
                }
            }
        }];
    });
}

- (void)blacklistTrack:(Track *)track;
{
    dispatch_barrier_async(self.cacheIsolation, ^{
        TrackWaveformCacheEntry *entry = [[TrackWaveformCacheEntry alloc] init];
        entry.track = track;
        if (CacheMaxCount <= [self.cachedImages count]) {
            [self.cachedImages removeObjectAtIndex:0];
        }
        [self.cachedImages addObject:entry];
        dispatch_async(self.creationIsolation, ^{
            [self.inPorcessTracks removeObject:track];
        });
    });
}

- (void)processImageData:(NSData *)data forTrack:(Track *)track;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *maskImage = [[UIImage alloc] initWithData:data];
        
        CGSize const size = CGSizeMake(320 - 8, 45);
        UIGraphicsBeginImageContextWithOptions(size, YES, deviceScale());
        
        CGRect const bounds = {CGPointZero, size};
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        // Fill background:
        {
            CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef) @[(__bridge id) [UIColor colorWithHue:0.066 saturation:1 brightness:1 alpha:1].CGColor, (__bridge id) [UIColor colorWithHue:0.035 saturation:1 brightness:1 alpha:1].CGColor], (CGFloat const []){0, 1});
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, CGRectGetMinY(bounds)), CGPointMake(0, CGRectGetMaxY(bounds)), 0);
            CGGradientRelease(gradient);
        }
        
        // We want to stomp the top half of the maskImage on top of everything:
        CGRect stretchedBounds = bounds;
        stretchedBounds.size.height *= 2;
        CGContextDrawImage(ctx, stretchedBounds, maskImage.CGImage);
        
        CGColorSpaceRelease(space);
        
        UIImage *waveform = UIGraphicsGetImageFromCurrentImageContext();
        if (NO) {
            NSData *pngData = UIImagePNGRepresentation(waveform);
            NSString *path = [NSString stringWithFormat:@"/Users/deggert/Desktop/%d.png", [track.waveformURL hash]];
            [pngData writeToFile:path atomically:NO];
        }
        UIGraphicsEndImageContext();
        [self addImage:waveform forTrack:track];
    });
}

- (void)addImage:(UIImage *)waveform forTrack:(Track *)track;
{
    dispatch_barrier_async(self.cacheIsolation, ^{
        TrackWaveformCacheEntry *entry = [[TrackWaveformCacheEntry alloc] init];
        entry.track = track;
        entry.image = waveform;
        if (CacheMaxCount <= [self.cachedImages count]) {
            [self.cachedImages removeObjectAtIndex:0];
        }
        [self.cachedImages addObject:entry];
        dispatch_async(self.creationIsolation, ^{
            [self.inPorcessTracks removeObject:track];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TrackWaveformCacheDidCreateImage object:track];
        });
    });
}

@end



@implementation TrackWaveformCacheEntry

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> track %d, image %p",
            [self class], self, self.track.identifier, self.image];
}

@end
