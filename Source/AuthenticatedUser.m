//
//  AuthenticatedUser.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "AuthenticatedUser.h"

#import "ServerRequest.h"

#import "Group.h"
#import "SCAPI.h"



NSString * const AuthenticatedUserGroupsDidChange = @"AuthenticatedUserGroupsDidChange";


@interface AuthenticatedUser ()

@property(nonatomic, copy) NSArray *groups;

@end



@implementation AuthenticatedUser

- (id)init
{
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        return nil;
    }
    self = [super init];
    return self;
}

- (void)updateGroups;
{
    NSURL *url = [NSURL URLWithString:@"https://api.soundcloud.com/me/groups.json"];
    [ServerRequest getResourceAtURL:url handler:^(id object) {
        NSArray *groupsData = object;
        if (![groupsData isKindOfClass:[NSArray class]]) {
            NSLog(@"Expected array for groups, got %@", [groupsData class]);
            return;
        }
        NSMutableArray *groups = [NSMutableArray array];
        for (id groupData in groupsData) {
            Group *group = [Group groupFromTransportObject:groupData];
            if (group != nil) {
                [groups addObject:group];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.groups = groups;
            [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticatedUserGroupsDidChange object:self];
        });
    }];
}

@end
