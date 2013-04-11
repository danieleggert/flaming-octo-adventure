//
//  TrackCell.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "TrackCell.h"

#import "Track.h"
#import "NSAttributedString+Helpers.h"
#import "TrackWaveformCache.h"



@interface TrackCell ()

@property(nonatomic, strong) UILabel *creationDateLabel;

@end



@implementation TrackCell
{
    NSDateFormatter *_dateFormatter;
}

+ (CGFloat)height;
{
    return 100;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup;
{
    self.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0.937 alpha:1];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeBottomLeft;
    
    self.creationDateLabel = self.detailTextLabel;
    self.creationDateLabel.textAlignment = NSTextAlignmentLeft;
    self.creationDateLabel.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    UILabel *titleLabel = self.textLabel;
    UILabel *creationLabel = self.creationDateLabel;
    UIImageView *imageView = self.imageView;
    
    CGRect const bounds = self.contentView.bounds;
    CGRect titleLabelFrame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(1, 4, 4, 4));
    titleLabelFrame.size.height = 30;
    CGRect creationLabelFrame = titleLabelFrame;
    creationLabelFrame.origin.y = CGRectGetMaxY(titleLabelFrame) - 6;
    CGRect imageViewFrame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(50, 4, 4, 4));
    
    titleLabel.frame = titleLabelFrame;
    creationLabel.frame = creationLabelFrame;
    imageView.frame = imageViewFrame;
    [self.contentView insertSubview:imageView atIndex:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForTrack:(Track *)track;
{
    self.textLabel.attributedText = [track.title attributedStringWithAttributes:self.titleAttributes];
    
    if (track.creationDate == nil) {
        self.creationDateLabel.attributedText = [@"A" attributedStringWithAttributes:self.creationLabelAttributes];
        self.creationDateLabel.hidden = NO;
    } else {
        NSString *string = [self.dateFormatter stringFromDate:track.creationDate];
        self.creationDateLabel.attributedText = [string attributedStringWithAttributes:self.creationLabelAttributes];
        self.creationDateLabel.hidden = NO;
    }
    
    [self updateImageForTrack:track];
}

- (void)updateImageForTrack:(Track *)track;
{
    UIImage *waveform = [[TrackWaveformCache sharedCache] waveformImageForTrack:track];
    self.imageView.image = waveform;
}

- (NSDictionary *)titleAttributes;
{
    return @{NSFontAttributeName: [UIFont boldSystemFontOfSize:24], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.1 alpha:1], NSKernAttributeName: [NSNull null]};
}

- (NSDictionary *)creationLabelAttributes;
{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2;
    shadow.shadowColor = [UIColor colorWithWhite:1 alpha:0.5];
    shadow.shadowOffset = CGSizeMake(0, 0);
    
    return @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.3 alpha:1], NSKernAttributeName: [NSNull null], NSShadowAttributeName: shadow};
}

- (NSDateFormatter *)dateFormatter;
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.doesRelativeDateFormatting = YES;
    }
    return _dateFormatter;
}

@end
