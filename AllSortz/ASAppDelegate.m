//
//  ASAppDelegate.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/18/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAppDelegate.h"
#import "ASBusinessListDataController.h"


#import "ASMapViewController.h"



@implementation ASAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"cb592ed379f3f8a7e6757b36f11dcee2_MTMzOTk2MjAxMi0wOS0xOSAxNjowMDoxOS4wOTU4Nzk"];
    self.mainTabNavController = (UITabBarController *)_window.rootViewController;
    self.mainTabNavController.delegate = self;
    [self.mainTabNavController setHidesBottomBarWhenPushed:YES];

    
    
    // set global states here
    [[UINavigationBar appearance] setTintColor:AS_DARK_BLUE];

    
    return YES;
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

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {


}


@end
