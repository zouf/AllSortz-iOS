//
//  ASZBusinessHealthDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/4/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASBusiness.h"

typedef enum ASZBusinessHealthDetailsSection : NSInteger {
    ASZBusinessHealthDetailsHeaderSection,
    ASZBusinessHealthDetailsInfoSection,
    ASZBusinessHealthDetailsReviewButton,
    ASZBusinessHealthDetailsTopicSection
} ASZBusinessHealthDetailsSection;

typedef enum ASZBusinessHealthDetailsInfoRow : NSInteger {
    ASZBusinessHealthDetailsTypesRow,
    ASZBusinessHealthDetailsAddressRow,
    ASZBusinessHealthDetailsHoursRow,
    ASZBusinessHealthDetailsPhoneRow,
    ASZBusinessHealthDetailsWebsiteRow
} ASZBusinessHealthDetailsInfoRow;
@class ASZCommentList;

@class ASBusiness;


@interface ASZBusinessHealthDataController : NSObject <UITableViewDataSource>


- (void)getAdditionalBusinessData;

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property ASBusiness *business;
@end