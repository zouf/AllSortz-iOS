//
//  ASListingsViewController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASIconDownloader.h"
#import "ASSortViewController.h"
#import "ASAddBusinessViewController.h"
#import "ASActivityWaitingViewController.h"

#define NUM_TYPE_ICONS 6
#define ACTIVITY_WAITING_VIEW 800
#define TYPE_ICON_IMAGE_BASE 600

@interface ASListingsViewController : UIViewController <UITableViewDelegate, UITabBarControllerDelegate, UIScrollViewDelegate, UISearchBarDelegate, ASIconDownloaderDelegate, NewSortDelegate, NewBusinessDelegate>
{
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app    
}

// Key-value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@end
