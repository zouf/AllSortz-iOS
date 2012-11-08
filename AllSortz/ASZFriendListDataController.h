//
//  ASZFriendListDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ASDeviceInterfaceSingleton.h"
#import "ASUser.h"
#define USERNAME_LABEL_TAG 1
#define USERPIC_VIEW_TAG 2
@class ASZFriendListViewController;
@class ASZFriendList;
@class ASDeviceInterfaceSingleton;


@interface ASZFriendListDataController : NSObject <UITableViewDataSource, NSURLConnectionDataDelegate, ASDeviceInterfaceDelegate, DownloadUserPicturesDelegate>
@property (weak, nonatomic) IBOutlet ASZFriendListViewController *viewController;

@property ASZFriendList *friendList;

@property (strong, nonatomic) CLLocation * currentLocation;
@property (strong, nonatomic) ASDeviceInterfaceSingleton *deviceInterface;


- (void)pullFriendListFromServer;

@end
