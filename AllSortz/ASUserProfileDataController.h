//
//  ASSocialDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASUser.h"
#import "ASDeviceInterface.h"

@interface ASUserProfileDataController : NSObject <NSURLConnectionDataDelegate, ASDeviceInterfaceDelegate>

@property (strong, readonly) ASUser *userProfile;

- (BOOL)updateData;
-(BOOL)uploadProfilePic:(UIImage *)imageToPost;

- (BOOL)updateUserData;


// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end
