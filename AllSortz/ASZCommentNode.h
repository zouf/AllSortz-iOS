//
//  ASZCommentNode.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/12/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

//adapted from http://dotnet.kapenilattex.com/?p=566
#import <Foundation/Foundation.h>
#import "ASUser.h"

@interface ASZCommentNode : NSObject {
    ASZCommentNode *parent;
    NSMutableArray *children;
    int index;
    
    BOOL replyTo; 
    BOOL proposeChange;
    
    BOOL inclusive;

    NSInteger posRatings;
    NSInteger negRatings;
    NSInteger commentID;
    NSString *creator;
    ASUser * user;
    
    
    NSString *date;
    
    
    
    NSArray *flattenedTreeCache;
}

@property (nonatomic, retain) ASZCommentNode *parent;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic) int index;

@property (nonatomic) BOOL inclusive;
@property (nonatomic) BOOL replyTo;
@property (nonatomic) BOOL proposeChange;


@property (nonatomic, assign) NSInteger posRatings;
@property (nonatomic, assign) NSInteger negRatings;
@property (nonatomic, assign) NSInteger commentID;
@property (nonatomic, retain) NSString *creator;

@property (nonatomic, retain) ASUser *user;


@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSArray *flattenedTreeCache;

-(void)updateTree:(ASZCommentNode*)tree newComment:(ASZCommentNode*)newComment;


- (id)initWithContent:(NSString *)_content  proposedChange:(NSString*)_proposedChange;

- (void)addChild:(ASZCommentNode *)newChild;
- (NSUInteger)descendantCount;
- (NSUInteger)levelDepth;
- (NSArray *)flattenElements;
- (NSArray *)flattenElementsWithCacheRefresh:(BOOL)invalidate;
- (BOOL)isRoot;
- (BOOL)hasChildren;

-(BOOL)isProposingNewChange;
- (NSString*)getNodeText;

- (NSDictionary *) serializeToDictionary:(NSString*)commentContent proposedChange:(NSString*)newProposedChange;


@end