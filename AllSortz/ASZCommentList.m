//
//  ASZCommentList.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZCommentList.h"

#ifndef CHECK_FOR_MULTI_ASSIGN
#define CHECK_FOR_MULTI_ASSIGN(ivar) \
do { \
if (ivar) { \
NSString *AS_reason = @"Cannot assign to " #ivar " more than once"; \
@throw [NSException exceptionWithName:ASMultipleAssignmentException \
reason:AS_reason \
userInfo:nil]; \
} \
} while(0)
#endif

#ifndef SIMPLE_SETTER
#define SIMPLE_SETTER(lower_name, caps_name, type) \
- (void)set ## caps_name:(type)lower_name \
{ \
CHECK_FOR_MULTI_ASSIGN(_ ## lower_name); \
_ ## lower_name = lower_name; \
}
#endif

@implementation ASZCommentList

- (id)initWithID:(NSUInteger)anID
{
    if (!(self = [super init]) || anID == 0)
        return nil;
    // TODO: Maintain unique instances of businesses
    _ID = anID;
    return self;
}

- (id)init
{
    // Instances *must* be created with an ID
    return nil;
}

- (NSDictionary *) serializeBusTopicInfo
{
   // NSError * error;
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          self.busTopicInfo ,@"content",nil];
    
    
    return dict;
}


-(UITableViewCell*)getCommentCell
{
    UITableViewCell * cell = nil;
    
    
    return cell;
    
    
    
}

+ (ASZCommentList *)commentListFromJSONResult:(NSDictionary *)result businessID:(NSInteger)busID
{
    ASZCommentList *reviewList = [[ASZCommentList alloc] initWithID:busID];
    if (!reviewList)
        return nil;
    
    
    reviewList.comments = [NSArray arrayWithArray:result[@"reviews"]];
    
    return reviewList;
    
}




#pragma mark - Custom setters



@end
