//
//  ASZMenuViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/8/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASZMenuDataController.h"

@interface ASZMenuViewController : UIViewController <UITableViewDelegate>
@property (strong, nonatomic) IBOutlet ASZMenuDataController *dataController;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *selectedDescription;
@property (weak, nonatomic) IBOutlet UITableView *tv;

@end
