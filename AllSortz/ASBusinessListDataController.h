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



@interface ASZQuery : NSObject


@property(nonatomic, retain) NSMutableData *responseData;

@property(nonatomic, retain) NSString *searchText;
@property(nonatomic, retain) NSString *searchLocation;
@property(assign) BOOL goneToServer;



@property(nonatomic, retain) NSArray *allTypes;
@property(nonatomic, retain) NSArray *allSorts;
@property(nonatomic, retain) NSArray *selectedTypes;
@property(nonatomic, retain) NSArray *selectedSorts;
@property(nonatomic, retain) NSArray *distanceWeight;

/*@property(nonatomic,retain) NSNumber * distance;
 @property(nonatomic,retain) NSNumber * value;
 
 @property(nonatomic,retain) NSNumber * price;
 
 @property(nonatomic,retain) NSNumber * score;*/



- (id)initWithJSONObject:(NSDictionary *)aJSONObject;
- (NSDictionary *)serializeToDictionary;



@end

@interface ASBusinessListDataController : NSObject <NSURLConnectionDataDelegate, ASDeviceInterfaceDelegate>

@property (strong, readonly) ASBusinessList *businessList;
@property(strong, atomic) CLLocation * currentLocation;
@property (strong, nonatomic) ASDeviceInterfaceSingleton *deviceInterface;

- (BOOL)updateData;
- (BOOL)performUpdate;


- (BOOL)updateDataWithNewList:(ASBusinessList*)newList;
- (BOOL)updateWithQuery;

@property (nonatomic, assign) MKCoordinateRegion rect;
@property (nonatomic, strong) ASZQuery *searchQuery;


@property (nonatomic, assign) BOOL updateAList;

// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
