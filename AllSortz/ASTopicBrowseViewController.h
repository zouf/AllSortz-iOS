//
//  ASTopicBrowseViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASUserProfileDataController.h"
#define TOPIC_TEXT 900
#define TOPIC_WEIGHT 901
@interface ASTopicBrowseViewController : UIViewController

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;



- (void)segmentSelected:(id)sender;

@property (nonatomic,retain) NSArray * children;
@property (nonatomic) NSInteger  parentTopicID;


@end
