//
//  ASZCommentList.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASZCommentList : NSObject


@property (readonly) NSUInteger ID;
@property (nonatomic) NSArray *comments;
@property (nonatomic) NSString  *busTopicInfo;





- (id)initWithID:(NSUInteger)anID;
- (NSDictionary *) serializeBusTopicInfo;


-(UITableViewCell*)getCommentCell;

@end
