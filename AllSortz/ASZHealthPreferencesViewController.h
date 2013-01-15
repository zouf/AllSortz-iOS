//
//  ASZHealthPreferencesViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/8/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASZHealthPreferencesDataController.h"
 
@interface ASZHealthPreferencesViewController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet ASZHealthPreferencesDataController *dataController;

@end
