//
//  ServerRequest.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "ServerRequest.h"

#import "SCAPI.h"





@implementation ServerRequest

+ (void)getResourceAtURL:(NSURL *)resourceURL handler:(void(^)(id object))handler;
{
    handler = [handler copy];
    
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        return;
    }
    
    //NSString *resourceURL = @"https://api.soundcloud.com/me/tracks.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:resourceURL
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 if (data == nil) {
                     handler(nil);
                 } else {
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                         NSError *jsonError = nil;
                         id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                         if (object == nil) {
                             NSLog(@"Unable to parser response for \"%@\": %@", resourceURL, jsonError);
                         }
                         handler(object);
                     });
                 }
             }];
}

@end
