//
//  GroupTracksViewController.h
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Group;



@interface GroupTracksViewController : UITableViewController

- (instancetype)initWithGroup:(Group *)group;

@end
