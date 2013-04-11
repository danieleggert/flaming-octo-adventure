//
//  TrackCell.h
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Track.h"



@interface TrackCell : UITableViewCell

+ (CGFloat)height;

- (void)configureForTrack:(Track *)track;
- (void)updateImageForTrack:(Track *)track;

@end
