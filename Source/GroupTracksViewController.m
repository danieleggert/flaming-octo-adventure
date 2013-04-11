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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TrackCellReuseIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tracksDidChange:) name:GroupTracksDidChange object:self.group];
    [self.group fetchTracks];
    
    self.title = self.group.name;
}

- (void)tracksDidChange:(NSNotification *)note;
{
    [self.tableView reloadData];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TrackCellReuseIdentifier forIndexPath:indexPath];
    Track *track = self.group.tracks[indexPath.row];
    cell.textLabel.text = track.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 
}

@end
