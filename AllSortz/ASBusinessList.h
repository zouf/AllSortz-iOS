//
//  ASBusinessList.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//
#import "ASBusiness.h"

#define IMAGE_VIEW 102
#define RATING_VIEW 100
#define DISTANCE_VIEW 105
#define TYPE_LABEL 104
#define PRICE_VIEW 107
#define RATE_VIEW 696




@class ASBusinessList;
@class ASBusiness;

@class ASListingsViewController;

@protocol ASIconDownloaderDelegate;

@interface ASIconDownloader : NSObject

@property (nonatomic, retain) ASBusiness *listing;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, strong) id <ASIconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol ASIconDownloaderDelegate

- (void)imageDidLoad:(NSIndexPath *)indexPath;


@end



@interface ASBusinessList : NSObject <UITableViewDataSource>
{
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app
}

- (id)initWithJSONObject:(NSDictionary *)aJSONObject;

// Key-value coding
- (NSUInteger)countOfBusinesses;
- (id)objectInBusinessesAtIndex:(NSUInteger)index;
- (NSArray *)businessesAtIndexes:(NSIndexSet *)indexes;
- (void)getBusinesses:(id __unsafe_unretained *)buffer range:(NSRange)inRange;

// the main data model for our UITableView
@property (nonatomic, retain) NSMutableArray *entries;
@property(nonatomic,assign) BOOL newAddress;
@property(nonatomic,retain) NSString* searchText;



@end
