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
@property(nonatomic, strong) UIBarButtonItem *loginItem;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupsDidChange:) name:AuthenticatedUserGroupsDidChange object:nil];
    [self.user updateGroups];
    
    self.loginItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NAVBAR_LOGOUT", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
    self.loginItem.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"NAVBAR_LOGOUT", @""), NSLocalizedString(@"NAVBAR_LOGIN", @""), nil];
    self.navigationItem.rightBarButtonItem = self.loginItem;
    
    self.title = NSLocalizedString(@"GROUPS_TITLE", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(id)sender
{
    if (self.user == nil) {
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
    } else {
        [SCSoundCloud removeAccess];
    }
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
    self.user = [[AuthenticatedUser alloc] init];
    [self.user updateGroups];
    [self.tableView reloadData];
    
    self.loginItem.title = ((self.user == nil) ?
                            NSLocalizedString(@"NAVBAR_LOGIN", @"") :
                            NSLocalizedString(@"NAVBAR_LOGOUT", @""));
}

- (void)groupsDidChange:(NSNotification *)note;
{
    if (note.object == self.user) {
        [self.tableView reloadData];
    }
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
