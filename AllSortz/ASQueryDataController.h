//
//  ASQueryDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/13/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASQuery.h"
#import "ASBusinessList.h"


@interface ASQueryDataController : NSObject  <NSURLConnectionDataDelegate>

@property (strong, readonly) ASQuery *query;
@property (strong, readonly) ASBusinessList *searchResults;

- (BOOL)updateData;

// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (NSURLRequest *)postRequestWithAddress:(NSString *)address data: (NSData *)data;      // IN


@end
