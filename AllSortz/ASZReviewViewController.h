//
//  ASZReviewViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASZReviewDataController.h"

@interface ASZReviewViewController : UITableViewController <UITableViewDelegate>

@property NSUInteger businessID;
@property NSInteger bustopicID;
@property NSInteger replyToID;

@property NSString * businessName;

@property IBOutlet ASZReviewDataController *dataController;


@end
