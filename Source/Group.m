//
//  Group.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "Group.h"

#import "ServerRequest.h"
#import "Track.h"


NSString * const GroupTracksDidChange = @"GroupTracksDidChange";



@interface Group ()

@property(nonatomic) NSInteger identifier;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *shortDescriptionText;
@property(nonatomic) NSInteger memberCount;

@property(nonatomic, copy) NSArray *tracks;

@end




@implementation Group

+ (instancetype)groupFromTransportObject:(NSDictionary *)transport;
{
    Group *group = [[self alloc] init];
    NSNumber *identifier = transport[@"id"];
    group.identifier = [identifier integerValue];
    group.name = transport[@"name"];
    group.shortDescriptionText = transport[@"short_description"];
    group.memberCount = [transport[@"members_count"] integerValue];
    return group;
}

- (void)fetchTracks;
{
    if (self.tracks != nil) {
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"https://api.soundcloud.com/groups/%@/tracks.json", @(self.identifier)];
    NSURL *url = [NSURL URLWithString:urlString];
    [ServerRequest getResourceAtURL:url handler:^(id object) {
        NSArray *transportData = object;
        if (![transportData isKindOfClass:[NSArray class]]) {
            NSLog(@"Expected array for tracks, got %@", [transportData class]);
            return;
        }
        NSMutableArray *tracks = [NSMutableArray array];
        for (id trackData in transportData) {
            Track *track = [Track trackFromTransportObject:trackData];
            if (track != nil) {
                [tracks addObject:track];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tracks = tracks;
            [[NSNotificationCenter defaultCenter] postNotificationName:GroupTracksDidChange object:self];
        });
    }];
}

@end
