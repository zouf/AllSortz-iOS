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
    ASZBusinessDetailsReviewButton,
    ASZBusinessDetailsTopicSection
} ASZBusinessDetailsSection;

typedef enum ASZBusinessDetailsInfoRow : NSInteger {
    ASZBusinessDetailsTypesRow,
    ASZBusinessDetailsAddressRow,
    ASZBusinessDetailsHoursRow,
    ASZBusinessDetailsPhoneRow,
    ASZBusinessDetailsWebsiteRow
} ASZBusinessDetailsInfoRow;
@class ASZCommentList;

@class ASBusiness;


@interface ASZBusinessDetailsDataController : NSObject <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property ASBusiness *business;

@property NSString *username;
@property NSString *password;
@property CGFloat currentLatitude;
@property CGFloat currentLongitude;
@property NSString *UUID;
@property ASZCommentList *reviewList;

- (UIImage*)getImageForGrade:(NSString*)healthGrade;
- (void)refreshBusinessAsynchronouslyWithID:(NSUInteger)ID;
-(void)rateBusinessTopicAsynchronously:(NSUInteger)btID withRating:(CGFloat)rating;
-(void)rateCommentAsynchronously:(NSUInteger)cID withRating:(NSInteger)rating;

- (void)getAllReviews:(NSUInteger)busID;

@end
