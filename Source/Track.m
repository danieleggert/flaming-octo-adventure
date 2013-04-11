//
//  Track.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "Track.h"

#import "NSURL+Helpers.h"
#import "NSDate+Helpers.h"



@interface Track ()

@property(nonatomic) NSInteger identifier;

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSDate *creationDate;
@property(nonatomic, strong) NSURL *artworkURL;
@property(nonatomic, copy) NSString *descriptionText;
@property(nonatomic, strong) NSURL *streamURL;
@property(nonatomic) BOOL isStreamable;
@property(nonatomic, strong) NSURL *URI;
@property(nonatomic, strong) NSURL *waveformURL;
@property(nonatomic, strong) NSURL *permalinkURL;

@end



@implementation Track

+ (instancetype)trackFromTransportObject:(NSDictionary *)transport;
{
    Track *track = [[self alloc] init];
    NSNumber *identifier = transport[@"id"];
    track.identifier = [identifier integerValue];
    track.creationDate = [NSDate dateFromTransportString:transport[@"created_at"]];
    track.title = transport[@"title"];
    track.artworkURL = [NSURL gracefulURLWithString:transport[@"artwork_url"]];
    track.descriptionText = transport[@"description"];
    track.streamURL = [NSURL gracefulURLWithString:transport[@"stream_url"]];
    track.isStreamable = [transport[@"streamable"] boolValue];
    track.URI = [NSURL gracefulURLWithString:transport[@"uri"]];
    track.waveformURL = [NSURL gracefulURLWithString:transport[@"waveform_url"]];
    track.permalinkURL = [NSURL gracefulURLWithString:transport[@"permalink_url"]];
    return track;
}

- (NSURL *)openInSoundCloundURL;
{
    if (self.identifier == 0) {
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"soundcloud:tracks:%@", @(self.identifier)];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)openInSafariURL;
{
    return self.permalinkURL;
}

@end
