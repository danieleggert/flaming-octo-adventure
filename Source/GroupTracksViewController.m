//
//  GroupTracksViewController.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "GroupTracksViewController.h"

#import "Group.h"
#import "Track.h"
#import "TrackCell.h"
#import "TrackWaveformCache.h"


static NSString * const TrackCellReuseIdentifier = @"track";




@interface GroupTracksViewController ()

@property(nonatomic, strong) Group *group;

@end



@implementation GroupTracksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    return nil;
}

- (instancetype)initWithGroup:(Group *)group;
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.group = group;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[TrackCell class] forCellReuseIdentifier:TrackCellReuseIdentifier];
    self.tableView.rowHeight = [TrackCell height];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tracksDidChange:) name:GroupTracksDidChange object:self.group];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateWaveformImage:) name:TrackWaveformCacheDidCreateImage object:nil];
    [self.group fetchTracks];
    
    self.title = self.group.name;
}

- (void)tracksDidChange:(NSNotification *)note;
{
    [self.tableView reloadData];
}

- (void)didCreateWaveformImage:(NSNotification *)note;
{
    Track *track = note.object;
    for (TrackCell *cell in self.tableView.visibleCells) {
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        if (path != nil) {
            Track *cellTrack = self.group.tracks[path.row];
            if (cellTrack == track) {
                [cell updateImageForTrack:track];
                break;
            }
        }
    }
}

@end



@implementation GroupTracksViewController (TableViewDataSourceAndDelegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.group.tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:TrackCellReuseIdentifier forIndexPath:indexPath];
    Track *track = self.group.tracks[indexPath.row];
    [cell configureForTrack:track];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Track *track = self.group.tracks[indexPath.row];

    BOOL didOpen = NO;
    NSURL *openInAppURL = track.openInSoundCloundURL;
    if (openInAppURL != nil) {
        didOpen = [[UIApplication sharedApplication] openURL:openInAppURL];
    }
    if (!didOpen) {
        [[UIApplication sharedApplication] openURL:track.openInSafariURL];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
