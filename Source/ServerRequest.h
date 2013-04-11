//
//  ServerRequest.h
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ServerRequest : NSObject

+ (void)getResourceAtURL:(NSURL *)resourceURL handler:(void(^)(id object))handler;

@end
