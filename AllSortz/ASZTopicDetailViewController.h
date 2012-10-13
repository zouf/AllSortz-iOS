//
//  ASZTopicDetailViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/2/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASZTopicDetailDataController.h"



@interface ASZTopicDetailViewController : UITableViewController <UITableViewDelegate>



@property NSUInteger topicID;
@property IBOutlet ASZTopicDetailDataController *dataController;
 @property (nonatomic) int openSection;
@end

@class FamilyCauseSection;

@protocol FamilyCauseSectionDelegate
@optional
- (void)clickedSection:(FamilyCauseSection*)familyCauseSection;
@end
