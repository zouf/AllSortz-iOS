//
//  ASIconDownloader.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/10/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASListing.h"

@class ASBusinessList;
@class ASListingsViewController;

@protocol ASIconDownloaderDelegate;

@interface ASIconDownloader : NSObject

@property (nonatomic, retain) ASListing *listing;
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
