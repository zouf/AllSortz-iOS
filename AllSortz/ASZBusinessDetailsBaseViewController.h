//
//  ASZBusinessDetailsBaseViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/24/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DISCUSSION_TAB 0
#define INFO_TAB 1
#define REDEEM_TAB 2
#define REVIEW_TAB 3


#define CELL_WIDTH 215
#define CELL_MARGIN 8
#define DEFAULT_HEIGHT 52
#define COMMENT_WIDTH 215
#define COMMENT_HEIGHT 65

#define NUM_INFO_SECTIONS 3
#define LAST_SECTION 2

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

#define COMMENTAUTHOR_TAG 1030
#define COMMENTTEXT_TAG 1031
#define COMMENTDATE_TAG 1032
#define COMMENTRATE_TAG 1033
#define COMMENTPOSRATING_TAG 1034
#define COMMENTNEGRATING_TAG 1035

@class ASZRateView;
@class ASZBusinessDetailsDataController;


@interface ASZBusinessDetailsBaseViewController : UIViewController <UITableViewDelegate>
@property NSUInteger businessID;

@property IBOutlet ASZBusinessDetailsDataController *dataController;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet ASZRateView *rateView;



@end
