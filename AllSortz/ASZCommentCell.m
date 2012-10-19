//
//  ASZCommentCell.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/12/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZCommentCell.h"
#import "ASZCommentList.h"




@interface ASZCommentCell (Private)

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor
                        selectedColor:(UIColor *)selectedColor
                             fontSize:(CGFloat)fontSize
                                 bold:(BOOL)bold;

@end


@implementation ASZCommentCell

@synthesize  arrow, height,node;
@synthesize level, expanded;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              level:(NSUInteger)_level
           expanded:(BOOL)_expanded
             height:(CGFloat)cellHeight;
    {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.level = _level;
        self.expanded = _expanded;
        self.height = cellHeight;
        UIView *content = self.contentView;

        
        if (!self.expanded)
        {
            self.arrow = [[ASZTriangleAnnotation alloc]initWithFrame:CGRectMake(0,0,10,10) withColor:[UIColor blackColor]];

        }
        else
        {
            self.arrow = [[ASZTriangleAnnotation alloc]initWithFrame:CGRectMake(0,0,20,20) withColor:[UIColor lightGrayColor]];
            self.arrow.transform = CGAffineTransformMakeRotation(90 * M_PI / 180.0);

        }
        

        [content addSubview:self.arrow];
        
    }
    return self;
}


#pragma mark - Get Cell Heights

-(CGFloat)getCommentWidth: (ASZCommentCell*)cell
{
    CGFloat ret =  SCREEN_WIDTH - (XOFFSET+ cell.level * LEVEL_INDENT);
    return ret;
}

-(CGFloat)getCommentHeight: (ASZCommentCell*)cell
{
    return cell.height;
    
}

-(CGFloat)getCommentX: (ASZCommentCell*)cell
{
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;

    return XOFFSET + (boundsX + cell.level) * LEVEL_INDENT;
}

#pragma mark -
#pragma mark Other overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat kHeight = self.height;
    
    if (!self.editing) {
        
        // get the X pixel spot
        CGRect frame;
        
        frame = CGRectMake([self getCommentX:self],
                           0,
                           [self getCommentWidth:self],
                           [self getCommentHeight:self]);
        self.contentView.frame = frame;
        
        
        /* line view
         
        for(int i = 0; i <= self.level; i++)
        {
            UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(-i*LEVEL_INDENT,0,1,kHeight)];
            [lineView setBackgroundColor:[UIColor lightGrayColor]];
            [self.contentView addSubview:lineView];
        }*/
        
        
        CGRect imgFrame;
        imgFrame = CGRectMake(XOFFSET,
                              YOFFSET,
                              IMG_HEIGHT_WIDTH,
                              IMG_HEIGHT_WIDTH);
        self.arrow.frame = imgFrame;
    }
}





#pragma mark -
#pragma mark Private category

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor
                        selectedColor:(UIColor *)selectedColor
                             fontSize:(CGFloat)fontSize
                                 bold:(BOOL)bold {
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    newLabel.backgroundColor = [UIColor whiteColor];
    newLabel.opaque = YES;
    newLabel.textColor = primaryColor;
    newLabel.highlightedTextColor = selectedColor;
    newLabel.font = font;
    newLabel.numberOfLines = 0;
    
    return newLabel;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
