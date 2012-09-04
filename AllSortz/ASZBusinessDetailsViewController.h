//
//  ASZBusinessDetailsViewController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@class ASZBusinessDetailsDataController;


@interface ASZBusinessDetailsViewController : UITableViewController <UITableViewDelegate,UIGestureRecognizerDelegate>

@property NSUInteger businessID;
@property IBOutlet ASZBusinessDetailsDataController *dataController;


- (IBAction)dialBusinessPhone;

@end
