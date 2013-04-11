//
//  Track.h
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Track : NSObject

+ (instancetype)trackFromTransportObject:(NSDictionary *)transport;

@property(readonly, nonatomic) NSInteger identifier;

@property(readonly, nonatomic, copy) NSString *title;
@property(readonly, nonatomic, strong) NSDate *creationDate;
@property(readonly, nonatomic, strong) NSURL *artworkURL;
@property(readonly, nonatomic, copy) NSString *descriptionText;
@property(readonly, nonatomic, strong) NSURL *streamURL;
@property(readonly, nonatomic) BOOL isStreamable;
@property(readonly, nonatomic, strong) NSURL *URI;
@property(readonly, nonatomic, strong) NSURL *waveformURL;

@property(readonly, nonatomic, strong) NSURL *openInSoundCloundURL;
@property(readonly, nonatomic, strong) NSURL *openInSafariURL;

@end
