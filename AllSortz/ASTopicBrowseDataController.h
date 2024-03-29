//
//  ASUserProfileDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASUserTopicImportance.h"
#import "ASGlobal.h"
#import "ASDeviceInterfaceSingleton.h"

@interface ASTopicBrowseDataController : NSObject <NSURLConnectionDataDelegate>

@property (strong, readonly) ASUserTopicImportance *userProfile;

- (BOOL)updateData:(NSInteger)parentTopic;
- (void)updateWithArray:(NSArray*)newTopics;

- (BOOL)updateImportance:(NSInteger)topicID  importanceValue:(float)importance;
- (IBAction)importanceSelected:(id)sender;

// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
