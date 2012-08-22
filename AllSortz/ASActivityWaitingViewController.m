//
//  ASActivityWaitingViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASActivityWaitingViewController.h"

@interface ASActivityWaitingViewController ()

@end

@implementation ASActivityWaitingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(id)initWithFrame:(CGRect)theFrame {
    if (self = [super init]) {
        frame = theFrame;
        self.view.frame = theFrame;
    }
    return self;
}


- (void)viewDidLoad
{
    [super loadView];
    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    activityLabel = [[UILabel alloc] init];
    activityLabel.text = NSLocalizedString(@"Loading", @"string1");
    activityLabel.textColor = [UIColor lightGrayColor];
    activityLabel.font = [UIFont boldSystemFontOfSize:17];
    [container addSubview:activityLabel];
    activityLabel.frame = CGRectMake(0, 3, 70, 25);
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [container addSubview:activityIndicator];
    activityIndicator.frame = CGRectMake(80, 0, 30, 30);
    
    [self.view addSubview:container];
    container.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [activityIndicator startAnimating];
}

-(void)viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
    [activityIndicator stopAnimating];
}




@end
