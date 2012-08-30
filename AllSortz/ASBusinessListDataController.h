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
#import "ASCLController.h"

@interface ASBusinessListDataController : NSObject <NSURLConnectionDataDelegate, NewSortDelegate, ASCLControllerDelegate>

@property (strong, readonly) ASBusinessList *businessList;

- (BOOL)updateData;
- (BOOL)updateDataWithNewList:(ASBusinessList*)newList;
- (BOOL)updateWithQuery:(ASQuery*)query;


// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
