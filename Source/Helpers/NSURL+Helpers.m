//
//  NSURL+Helpers.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "NSURL+Helpers.h"



@implementation NSURL (Helpers)

+ (instancetype)gracefulURLWithString:(NSString *)string;
{
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    return [NSURL URLWithString:string];
}

@end
