//
//  ASZEditBusinessDetailsViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/5/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASZEditBusinessDetailsDataController.h"

@interface ASZEditBusinessDetailsViewController : UITableViewController <UITableViewDelegate>

@property NSUInteger businessID;
@property IBOutlet ASZEditBusinessDetailsDataController *dataController;


@end
