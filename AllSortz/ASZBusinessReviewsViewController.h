//
//  ASZBusinessReviewsViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/9/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASZBusinessReviewsDataController.h"

@interface ASZBusinessReviewsViewController : UITableViewController
@property (strong, nonatomic) IBOutlet ASZBusinessReviewsDataController *dataController;

@end
