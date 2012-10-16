//
//  ASZBusinessTopicViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/16/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASZBusinessTopicDataController.h"
#import "ASBusiness.h"
#import "ASZCommentNode.h"

@interface ASZBusinessTopicViewController : UITableViewController <UITextViewDelegate>
@property NSUInteger businessTopicID;
@property (nonatomic) NSString*  businessTopicName;
@property (nonatomic,retain) ASBusiness*  business;

@property IBOutlet ASZBusinessTopicDataController *dataController;
@end
