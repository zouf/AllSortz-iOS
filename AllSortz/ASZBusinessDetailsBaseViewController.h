//
//  ASZBusinessDetailsBaseViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/24/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

//tab info
#define DISCUSSION_TAB 0
#define INFO_TAB 1
#define REDEEM_TAB 2
#define REVIEW_TAB 3


//Row definitions
#define PHONE_ROW 0
#define WEBSITE_ROW 1
#define ADDRESS_ROW 0
#define MAP_ROW 1


//Heights
#define MAP_HEIGHT 100
#define PHONE_WEBSITE_HEIGHT 35
#define TYPE_HEIGHT 45

//Section info
#define NUM_INFO_SECTIONS 3
#define LAST_SECTION 2
#define PHONE_WEBSITE_SECTION 0
#define ADDRESS_MAP_SECTION 1
#define TYPE_SECTION 2


#define BUSINESSIMAGEVIEW_TAG 1000
#define BUSINESSNAMELABEL_TAG 1001
#define BUSINESSHEALTH_TAG 1002
#define BUSINESSTYPES_TAG 1003
#define BUSINESSPHONE_TAG 1004
#define BUSINESSURL_TAG 1005
#define BUSINESSADDRESS_TAG 1006
#define BUSINESSSCORE_TAG 1007
#define BUSINESSDIST_TAG 1008




#define TOPICNAMELABEL_TAG 1010
#define TOPICTEXTVIEW_TAG 1012
#define TOPICRATINGVIEW_TAG 1013
#define TOPICRATINGSLIDER_TAG 1014
#define TOPICRATINGSEGMENTED_TAG 1015
#define TOPICAVGRATINGSLABEL_TAG 1016
#define STAR_VIEW 1020



@class ASZRateView;
@class ASZBusinessDetailsDataController;


@interface ASZBusinessDetailsBaseViewController : UIViewController <UITableViewDelegate>
@property NSUInteger businessID;

@property IBOutlet ASZBusinessDetailsDataController *dataController;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet ASZRateView *rateView;
@property(weak,nonatomic) MKMapView* mapView;


@end
