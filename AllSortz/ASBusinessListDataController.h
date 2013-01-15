//
//  ASBusinessDataController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/28/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessList.h"
#import "ASGlobal.h"
#import "ASDeviceInterfaceSingleton.h"
#import <MapKit/MapKit.h>

#define NUM_RESULTS 20



@interface ASBusinessListDataController : NSObject <NSURLConnectionDataDelegate, ASDeviceInterfaceDelegate>

@property (nonatomic,retain) NSString* searchTerm;


@property (strong, readonly) ASBusinessList *businessList;
@property(strong, atomic) CLLocation * currentLocation;
@property (strong, nonatomic) ASDeviceInterfaceSingleton *deviceInterface;

- (BOOL)performUpdate;

@property (nonatomic, assign) MKCoordinateRegion rect;

@end
