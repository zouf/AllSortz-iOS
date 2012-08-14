//
//  ASAddBusinessViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASAddBusiness.h"

#define BUSINESS_NAME 200
#define BUSINESS_STREET 201
#define BUSINESS_CITY 202
#define BUSINESS_STATE 203
#define BUSINESS_URL 204
#define BUSINESS_PHONE 205



@protocol NewBusinessDelegate;


@interface ASAddBusinessViewController : UITableViewController
{
    id<NewBusinessDelegate>delegate;
    UITextField *businessNameField;
}

@property(strong,nonatomic)id<NewBusinessDelegate>delegate;
@property(strong,nonatomic)IBOutlet UITextField *businessNameField;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

@end


@protocol NewBusinessDelegate <NSObject>

-(void)newASAddBusinessViewController:(ASAddBusinessViewController *)abvc didCreateNewBusiness:(ASAddBusiness *)business;
-(void)cancelASAddBusinessViewController:(ASAddBusinessViewController *)abvc;

@end