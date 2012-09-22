//
//  ASZTabBarViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZTabBarViewController.h"

@interface ASZTabBarViewController ()

@end

@implementation ASZTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tabBarController setHidesBottomBarWhenPushed:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end

