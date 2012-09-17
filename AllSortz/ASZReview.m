//
//  ASZReview.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZReview.h"
#import "ASException.h"

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

@implementation ASZReview


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

- (NSDictionary *) serializeToDictionaryWithTopics:(NSArray*)topics
{
    
    NSError * error;
    

    NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:topics options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%d",self.ID], @"businessID",
                          self.reviewText ,@"content",
                          @"review", @"commentType",
                          jsonString ,@"topicIDs",nil];
        
    return dict;
}




#pragma mark - Custom setters
SIMPLE_SETTER(reviewText, ReviewText, NSString *)
SIMPLE_SETTER(allTopics, AllTopics, NSMutableArray *)
SIMPLE_SETTER(selectedTopics, SelectedTopics, NSMutableArray *)


@end
