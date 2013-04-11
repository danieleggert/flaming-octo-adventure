//
//  AppDelegate.m
//  AwesomeCodeChallenge
//
//  Created by Daniel Eggert on 10/04/2013.
//  Copyright (c) 2013 Bödewadt. All rights reserved.
//

#import "AppDelegate.h"

#import "SCAPI.h"
#import "SCUI.h"
#import "GroupsViewController.h"



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountDidChange:) name:SCSoundCloudAccountDidChangeNotification object:nil];
    
    [SCSoundCloud setClientID:@"af0f4e719232ea98b681cdab929a0371"
                       secret:@"67410c9555dd5492da4ae2d57e276f38"
                  redirectURL:[NSURL URLWithString:@"danielsoundcloudchallenge://soundcloudoauth"]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[GroupsViewController alloc] init]];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)accountDidChange:(NSNotification *)note;
{
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
