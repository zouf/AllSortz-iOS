//
//  ASAddBusinessViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAddBusiness.h"






@protocol NewBusinessDelegate;


@interface ASAddBusinessViewController : UITableViewController

@property(strong,nonatomic)id<NewBusinessDelegate>delegate;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

@end


@protocol NewBusinessDelegate <NSObject>

-(void)newASAddBusinessViewController:(ASAddBusinessViewController *)abvc didCreateNewBusiness:(ASAddBusiness *)business;
-(void)cancelASAddBusinessViewController:(ASAddBusinessViewController *)abvc;

@end