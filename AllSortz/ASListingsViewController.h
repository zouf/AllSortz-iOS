//
//  ASListingsViewController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASIconDownloader.h"
#import "ASSortViewController.h"

@interface ASListingsViewController : UIViewController <UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, ASIconDownloaderDelegate, ASRateViewDelegate, NewSortDelegate>
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
