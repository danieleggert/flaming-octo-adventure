//
//  AuthenticatedUser.h
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const AuthenticatedUserGroupsDidChange;



@interface AuthenticatedUser : NSObject

- (void)updateGroups;

@property(readonly, nonatomic, copy) NSArray *groups;

@end
