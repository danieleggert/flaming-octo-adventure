//
//  GroupsViewController.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 11/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "GroupsViewController.h"


#import "SCAPI.h"
#import "SCUI.h"

#import "AuthenticatedUser.h"
#import "Group.h"
#import "GroupTracksViewController.h"



static NSString * const GroupCellReuseIdentifier = @"group";



@interface GroupsViewController ()

@property(nonatomic, strong) AuthenticatedUser *user;

@end



@implementation GroupsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCSoundCloudAccountDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AuthenticatedUserGroupsDidChange object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:GroupCellReuseIdentifier];
    
    self.user = [[AuthenticatedUser alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountDidChange:) name:SCSoundCloudAccountDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupsDidChange:) name:AuthenticatedUserGroupsDidChange object:self.user];
    [self.user updateGroups];
    
    self.title = NSLocalizedString(@"GROUPS_TITLE", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done!");
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL completionHandler:handler];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    if ([SCSoundCloud account] == nil) {
        [self login:nil];
    }
}

- (void)accountDidChange:(NSNotification *)note;
{
    [self.user updateGroups];
}

- (void)groupsDidChange:(NSNotification *)note;
{
    [self.tableView reloadData];
}

@end



@implementation GroupsViewController (TableViewDataSourceAndDelegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.user.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCellReuseIdentifier forIndexPath:indexPath];
    Group *group = self.user.groups[indexPath.row];
    cell.textLabel.text = group.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Group *group = self.user.groups[indexPath.row];
    GroupTracksViewController *vc = [[GroupTracksViewController alloc] initWithGroup:group];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
