//
//  ASZCommentList.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASZCommentNode.h"
//comment elements for all of the comments

#define COMMENTPOSRATING_TAG 1024
#define COMMENTNEGRATING_TAG 1025
#define COMMENTDATE_TAG 1026
#define COMMENTAUTHOR_TAG 1027
#define COMMENTTEXT_TAG 1028
#define COMMENTRATE_TAG 1029
#define REPLYLABEL_TAG 1030
#define COMMENTUPRAITNG_TAG 1031
#define COMMENTDOWNRAITNG_TAG 1032
#define COMMENTAUTHORPIC_TAG 1033
#define REPLYBOX_TAG 1034
#define PROPOSECHANGE_TAG 1035


#define CELL_WIDTH 235
#define CELL_MARGIN 4
#define TEXTBOX_MARGIN 2
#define DEFAULT_HEIGHT 60
#define COLLAPSED_HEIGHT 20
#define REPLY_TO_HEIGHT 50
#define DEFAULT_BUSTOPIC_CONTENT_HEIGHT 125
#define COMMENT_WIDTH 270
#define START_POSITION 5
@interface ASZCommentList : NSObject


@property (readonly) NSUInteger ID;
@property (nonatomic) NSMutableArray *comments;
@property (nonatomic) NSString  *busTopicInfo;
@property (nonatomic, retain) ASZCommentNode *treeRoot;





- (id)initWithID:(NSUInteger)anID;
- (NSDictionary *) serializeBusTopicInfo;


-(UITableViewCell*)getCommentCell;

@end
