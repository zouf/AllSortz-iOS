//
//  ASUserProfileDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASUserProfile.h"
#import "ASURLEncoding.h"

@interface ASUserProfileDataController : NSObject <NSURLConnectionDataDelegate>

@property (strong, readonly) ASUserProfile *userProfile;

- (BOOL)updateData:(NSInteger)parentTopic;
- (void)updateWithArray:(NSArray*)newTopics;
- (BOOL)updateImportance:(NSInteger)topicID  importanceValue:(float)importance;



// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
