//
//  Account.h
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Account : NSObject

+ (instancetype)sharedAccount;

@property(nonatomic, copy) NSString *username;
@property(nonatomic, copy) NSString *password;

@property(readonly, nonatomic) BOOL hasCredentials;

@end
