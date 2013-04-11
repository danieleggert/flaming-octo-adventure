//
//  NSAttributedString+Helpers.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "NSAttributedString+Helpers.h"



@implementation NSString (AttributedString)

- (NSAttributedString *)attributedStringWithAttributes:(NSDictionary *)attributes;
{
    return [[NSAttributedString alloc] initWithString:self attributes:attributes];
}

@end
