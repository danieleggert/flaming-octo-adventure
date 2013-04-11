//
//  NSDate+Helpers.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "NSDate+Helpers.h"

#import <string.h>
#import <time.h>
#include <xlocale.h>




@implementation NSDate (Helpers)

+ (instancetype)dateFromTransportString:(NSString *)string;
{
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    tzset();
    
    struct tm ctime = {};
    char const * const temp = [string UTF8String];
    locale_t const cLocale = newlocale(LC_ALL_MASK, NULL, NULL);
    if (NULL == strptime_l(temp, "%Y/%m/%d %T %z", &ctime, cLocale)) {
        return nil;
    }
    
    long ts = mktime(&ctime);
    return [NSDate dateWithTimeIntervalSince1970:ts];
}

@end
