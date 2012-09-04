//
//  ASUserProfileViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASUserProfileDataController.h"


@interface ASUserProfileViewController : UIViewController

// Key-value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

@property (nonatomic) NSInteger questionPosition;
@property (nonatomic) NSInteger parentTopicID;
@property (nonatomic) NSMutableArray *questionPath;


@end
