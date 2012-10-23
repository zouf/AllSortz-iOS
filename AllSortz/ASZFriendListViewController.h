//
//  ASZFriendListViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CELL_WIDTH 320
#define CELL_HEIGHT 60
@class ASZFriendListDataController;
@interface ASZFriendListViewController : UIViewController <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet ASZFriendListDataController *friendListDataController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
