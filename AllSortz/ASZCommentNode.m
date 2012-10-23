//
//  ASZCommentNode.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/12/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZCommentNode.h"

@implementation ASZCommentNode

@synthesize parent, children;
@synthesize index, content, negRatings, commentID,date, creator, posRatings, flattenedTreeCache;
@synthesize inclusive, replyTo;


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

- (id)initWithContent:(NSString *)_content {
	self = [super init];
	if (self) {
		content = _content;
		inclusive = YES;
        replyTo = NO;
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
        else
        {
            
            NSLog(@"%@ not included",[self description]);
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



- (NSDictionary *) serializeToDictionary:(NSString*)commentContent
{
    
    
    NSDictionary * dict= [NSDictionary dictionaryWithObjectsAndKeys:
                          commentContent ,@"content",
                          @"comment", @"commentType",
                          [NSString stringWithFormat:@"%d",self.commentID], @"replyToID", nil];
    
    return dict;
}



@end