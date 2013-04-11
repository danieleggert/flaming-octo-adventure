//
//  Group.h
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const GroupTracksDidChange;



@interface Group : NSObject

+ (instancetype)groupFromTransportObject:(NSDictionary *)transport;

@property(readonly, nonatomic) NSInteger identifier;

@property(readonly, nonatomic, copy) NSString *name;
@property(readonly, nonatomic, copy) NSString *shortDescriptionText;
@property(readonly, nonatomic) NSInteger memberCount;

@property(readonly, nonatomic, copy) NSArray *tracks;

- (void)fetchTracks;

@end
