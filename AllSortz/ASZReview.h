//
//  ASZReview.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASZReview : NSObject

@property (readonly) NSUInteger ID;


@property (nonatomic) NSString *reviewText;
@property (nonatomic) NSMutableArray *selectedTopics;
@property (nonatomic) NSMutableArray *allTopics;



- (id)initWithID:(NSUInteger)anID;
- (NSDictionary *) serializeToDictionaryWithTopics:(NSArray*)topics;

@end
