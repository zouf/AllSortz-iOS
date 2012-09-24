//
//  ASZBusinessDetailsBaseViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/24/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASZBusinessDetailsDataController;


@interface ASZBusinessDetailsBaseViewController : UIViewController <UITableViewDelegate>
@property NSUInteger businessID;

@property IBOutlet ASZBusinessDetailsDataController *dataController;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;

- (IBAction)dialBusinessPhone;
- (IBAction)goToURL:(id)sender;

@end
