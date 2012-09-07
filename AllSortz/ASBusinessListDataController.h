//
//  ASBusinessDataController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/28/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessList.h"
#import "ASQuery.h"
#import "ASURLEncoding.h"
#import "ASSortViewController.h"
#import "ASDeviceInterface.h"
#import <MapKit/MapKit.h>

#define NUM_RESULTS 20

@interface ASBusinessListDataController : NSObject <NSURLConnectionDataDelegate, NewSortDelegate, ASDeviceInterfaceDelegate>

@property (strong, readonly) ASBusinessList *businessList;
@property(strong, atomic) CLLocation * currentLocation;
@property (strong, nonatomic) ASDeviceInterface *deviceInterface;

- (BOOL)updateData;
- (BOOL)performUpdate;


- (BOOL)updateDataWithNewList:(ASBusinessList*)newList;
- (BOOL)updateWithQuery;

@property (nonatomic, assign) MKCoordinateRegion rect;
@property (nonatomic, strong) ASQuery *searchQuery;

@property (nonatomic, assign) BOOL updateAList;

// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
