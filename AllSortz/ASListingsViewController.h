//
//  ASListingsViewController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASIconDownloader.h"
#import "ASAddBusinessViewController.h"
#import "ASBusinessListDataController.h"
#import "ASActivityWaitingViewController.h"
#import "ASMapViewController.h"

#define NUM_TYPE_ICONS 6
#define ACTIVITY_WAITING_VIEW 800
#define TYPE_ICON_IMAGE_BASE 600

@class ASMapViewController;

@interface ASListingsViewController : UIViewController <UITableViewDelegate, ASIconDownloaderDelegate, NewBusinessDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet ASBusinessListDataController *listingsTableDataController;
@property (strong, nonatomic) IBOutlet ASMapViewController *mapViewController;


// Key-value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;


-(void)loadListElements;

// the set of IconDownloader objects for each app
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;



@property (nonatomic) NSInteger result_base_counter;


@end
