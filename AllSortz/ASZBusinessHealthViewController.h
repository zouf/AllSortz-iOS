//
//  ASZHealthMenuViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/3/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "ASZBusinessHealthDataController.h"

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
#define DEFAULT_CELL_HEIGHT 55

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
#define TOPICUPBUTTON_TAG 1017
#define TOPICDOWNBUTTON_TAG 1018

#define TOPICUSER_RATING 1019
#define TOPICAVG_RATING 1020
#define TOPICRATING_TAG 1021

#define STAR_VIEW 1020



#define PICKER_VIEW 1022


@class ASZNewRateView;

@interface ASZBusinessHealthViewController :  UIViewController <UITableViewDelegate>

@property id businessID;

@property (strong, nonatomic) IBOutlet ASZBusinessHealthDataController *dataController;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (strong, nonatomic)  ASZNewRateView *customRateView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
