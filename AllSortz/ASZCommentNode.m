//
//  ASZCommentNode.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/12/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZCommentNode.h"

@interface ASZCommentNode()

@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *proposedChange;
@end

@implementation ASZCommentNode

@synthesize parent, children;
@synthesize index, content, proposedChange, negRatings, commentID,date, creator, posRatings, flattenedTreeCache;
@synthesize inclusive, replyTo, user, proposeChange;


#pragma mark - Custom methods

-(void)updateTree:(ASZCommentNode*)tree newComment:(ASZCommentNode*)newComment
{
    NSInteger sz = [[tree flattenElements] count];
    for(int i = 0; i < sz; i++)
    {
        ASZCommentNode * n = [[tree flattenElements] objectAtIndex:i];
        if(n.commentID == newComment.commentID)
        {
            n.posRatings = newComment.posRatings;
            n.negRatings = newComment.negRatings;
            n.content = newComment.content;
            n.creator = newComment.creator;
            n.date = newComment.date;
            n.user = newComment.user;
            
        }
    }
    
}
#pragma mark -
#pragma mark Initializers

- (id)initWithContent:(NSString *)_content  proposedChange:(NSString*)_proposedChange
{
	self = [super init];
	if (self) {
		content = _content;
		inclusive = YES;
        replyTo = NO;
        proposeChange = NO;
        proposedChange = _proposedChange;
	}
    
	return self;
}

#pragma mark -
#pragma mark Custom Properties

- (NSMutableArray *)children {
	if (!children) {
		children = [[NSMutableArray alloc] initWithCapacity:1];
	}
    
	return children;
}



- (NSUInteger)descendantCount {
	NSUInteger cnt = 0;
    
	for (ASZCommentNode *child in self.children) {
		if (self.inclusive) {
			cnt++;
			if (child.children.count > 0) {
				cnt += [child descendantCount];
			}
		}
	}
    
	return cnt;
}

- (NSArray *)flattenElements {
	return [self flattenElementsWithCacheRefresh:YES];
}

- (NSArray *)flattenElementsWithCacheRefresh:(BOOL)invalidate {
	if (!flattenedTreeCache || invalidate) {
		//if there was a previous cache and due for invalidate, release resources first
		if (flattenedTreeCache) {
			flattenedTreeCache = nil;
		}
        
		NSMutableArray *allElements = [[NSMutableArray alloc] initWithCapacity:[self descendantCount]] ;
		[allElements addObject:self];
        
		if (inclusive)
        {
			for (ASZCommentNode *child in self.children) {
                [allElements addObjectsFromArray:[child flattenElementsWithCacheRefresh:invalidate]];
			}
		}
        
		flattenedTreeCache = [[NSArray alloc] initWithArray:allElements];
	}
    
	return flattenedTreeCache;
}

- (void)addChild:(ASZCommentNode *)newChild {
	newChild.parent = self;
	[self.children addObject:newChild];
}

- (NSUInteger)levelDepth {
	if (!parent) return 0;
    
	NSUInteger cnt = 0;
	cnt++;
	cnt += [parent levelDepth];
    
	return cnt;
}

- (BOOL)isRoot {
	return (!parent);
}

- (BOOL)hasChildren {
	return (self.children.count > 0);
}


#pragma mark - Determining the type of info the cell is displaying (the proposed change or comment itself)(

/* returns either the proposed content or the content of the comment*/
-(NSString*)getNodeText
{
    if([self.proposedChange isEqualToString:@""])
    {
        return self.content;
    }
    else
    {
        return self.proposedChange;
    }
    
}

/* returns either the proposed content or the content of the comment*/
-(BOOL)isProposingNewChange
{
    if([self.proposedChange isEqualToString:@""])
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
}

- (NSDictionary *) serializeToDictionary:(NSString*)commentContent proposedChange:(NSString*)newProposedChange
{
    
    
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          commentContent ,@"content",
                          newProposedChange ,@"proposedChange",
                          @"comment", @"commentType",
                          [NSString stringWithFormat:@"%d",self.commentID], @"replyToID", nil];
    
    return dict;
}



@end