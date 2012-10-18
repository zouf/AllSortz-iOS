//
//  ASZCommentNode.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/12/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

//adapted from http://dotnet.kapenilattex.com/?p=566
#import <Foundation/Foundation.h>

@interface ASZCommentNode : NSObject {
    ASZCommentNode *parent;
    NSMutableArray *children;
    int index;
    NSString *content;
    
    
    BOOL replyTo; 
    
    BOOL inclusive;

    NSInteger posRatings;
    NSInteger negRatings;
    NSInteger commentID;
    NSString *creator;
    NSString *date;
    
    
    
    NSArray *flattenedTreeCache;
}

@property (nonatomic, retain) ASZCommentNode *parent;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic) int index;
@property (nonatomic, retain) NSString *content;
@property (nonatomic) BOOL inclusive;
@property (nonatomic) BOOL replyTo;

@property (nonatomic, assign) NSInteger posRatings;
@property (nonatomic, assign) NSInteger negRatings;
@property (nonatomic, assign) NSInteger commentID;
@property (nonatomic, retain) NSString *creator;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSArray *flattenedTreeCache;

- (id)initWithContent:(NSString *)_content;

- (void)addChild:(ASZCommentNode *)newChild;
- (NSUInteger)descendantCount;
- (NSUInteger)levelDepth;
- (NSArray *)flattenElements;
- (NSArray *)flattenElementsWithCacheRefresh:(BOOL)invalidate;
- (BOOL)isRoot;
- (BOOL)hasChildren;

- (NSDictionary *) serializeToDictionary:(NSString*)commentContent;


@end