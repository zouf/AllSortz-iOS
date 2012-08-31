//
//  ASZBusinessDetailsDataController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

typedef enum ASZBusinessDetailsSection : NSInteger {
    ASZBusinessDetailsHeaderSection,
    ASZBusinessDetailsInfoSection,
    ASZBusinessDetailsTopicSection
} ASZBusinessDetailsSection;

typedef enum ASZBusinessDetailsInfoRow : NSInteger {
    ASZBusinessDetailsTypesRow,
    ASZBusinessDetailsAddressRow,
    ASZBusinessDetailsHoursRow,
    ASZBusinessDetailsPhoneRow,
    ASZBusinessDetailsWebsiteRow
} ASZBusinessDetailsInfoRow;

@class ASBusiness;


@interface ASZBusinessDetailsDataController : NSObject <UITableViewDataSource>

@property ASBusiness *business;

- (void)refreshBusinessAsynchronouslyWithID:(NSUInteger)ID;

@end
