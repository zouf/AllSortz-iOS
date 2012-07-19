//
//  ASFirstViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ASFirstViewController.h"

@interface ASFirstViewController ()

@end

@implementation ASFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
