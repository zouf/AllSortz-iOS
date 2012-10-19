//
//  ASZCommentCell.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/12/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ASZCommentNode.h"
#import "ASZTriangleAnnotation.h"

#define IMG_HEIGHT_WIDTH 8
#define CELL_HEIGHT 60
#define SCREEN_WIDTH 320
#define LEVEL_INDENT 16
#define YOFFSET 4
#define XOFFSET 0

@class ASZTriangleAnnotation;

@interface ASZCommentCell : UITableViewCell {
    CGFloat height;
    ASZTriangleAnnotation *arrow;
    ASZCommentNode * node;
    
    int level;
    BOOL expanded;
}

@property (nonatomic, retain) ASZTriangleAnnotation *arrow;
@property (nonatomic) int level;
@property (nonatomic) BOOL expanded;
@property(nonatomic,retain)ASZCommentNode* node;
@property (nonatomic) CGFloat height;

-(CGFloat)getCommentWidth: (ASZCommentCell*)cell;

-(CGFloat)getCommentHeight: (ASZCommentCell*)cell;

-(CGFloat)getCommentX: (ASZCommentCell*)cell;



- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              level:(NSUInteger)_level
           expanded:(BOOL)_expanded
           height:(CGFloat)cellHeight;


@end