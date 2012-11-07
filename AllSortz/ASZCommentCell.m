//
//  ASZCommentCell.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/12/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZCommentCell.h"
#import "ASZCommentList.h"

#import  <QuartzCore/QuartzCore.h>


@interface ASZCommentCell (Private)

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor
                        selectedColor:(UIColor *)selectedColor
                             fontSize:(CGFloat)fontSize
                                 bold:(BOOL)bold;

@end


@implementation ASZCommentCell

@synthesize  arrow, node, delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
               treeNode:(ASZCommentNode*)treeNode
       busTopicInfo:(NSString*)proposedChange
           delegate:(id)theDelegate;
    {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.delegate = theDelegate;
        self.node = treeNode;
        UIView *content = self.contentView;

        
        //    ASZCommentCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];       
        CGFloat kCommentHeight = [self getCommentHeight:self];
        
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
        
        UILabel * authorLabel;
        UIImageView *authorPic;
        UILabel * dateLabel ;
        UITextView * commentContent;
        UILabel * posRatingLabel;
        UILabel * negRatingLabel;
        
        UIButton *replyButton;
        UIButton *upButton;
        UIButton *downButton;
        
        
        //get the height of teh cell
        CGFloat kCommentWidth =  [self getCommentWidth:self];
        
        // CONTROLS FOR BOTH COLLAPSED AND OPENED CELLS
        //Author label
        CGFloat kAuthorWidth = 40;
        CGFloat kAuthorHeight = 15;
        CGFloat kAuthorX = kCommentWidth-kAuthorWidth;
        CGFloat kAuthorY = 0;
        
        
        //for date
        CGFloat kDateX = 100;
        CGFloat kDateY  = 0;
        CGFloat kDateWidth = 100;
        CGFloat kDateHeight = 15;
        
        
        //for pos / neg rating labels
        CGFloat kRatingX = 10;
        CGFloat kRatingY = 0;
        CGFloat kRatingHeight = 15;
        CGFloat kRatingWidth = 15;
        
        
        
        
        authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(kAuthorX,kAuthorY,kAuthorWidth,kAuthorHeight)];
        authorLabel.tag = COMMENTAUTHOR_TAG;
        authorLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
        authorLabel.textAlignment = NSTextAlignmentCenter;
        authorLabel.textColor = [UIColor darkGrayColor];
        authorLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:authorLabel];
        
        UIColor* myDarkBlue = [UIColor colorWithRed: 0  green: .298 blue: .5963 alpha: 1];
        //UIColor* myDarkRed = [UIColor colorWithRed: .596 green: 0 blue: 0 alpha: 1];
        
        
        posRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(kRatingX,kRatingY,kRatingWidth,kRatingHeight)];
        posRatingLabel.tag = COMMENTPOSRATING_TAG;
        posRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
        posRatingLabel.textAlignment = NSTextAlignmentCenter;
        posRatingLabel.textColor =  myDarkBlue;
        posRatingLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:posRatingLabel];
        
        negRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(kRatingX+kRatingWidth,kRatingY,kRatingWidth,kRatingHeight)];
        negRatingLabel.tag = COMMENTNEGRATING_TAG;
        negRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
        negRatingLabel.textAlignment = NSTextAlignmentCenter;
        negRatingLabel.textColor = myDarkBlue;
        negRatingLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:negRatingLabel];
        
        
        dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDateX,kDateY,kDateWidth,kDateHeight)];
        dateLabel.tag = COMMENTDATE_TAG;
        dateLabel.font = [UIFont fontWithName:@"GillSans-Italic"  size:10];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.textColor = [UIColor darkGrayColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:dateLabel];
        
        dateLabel.text =  node.date;
        authorLabel.text = node.creator;
        posRatingLabel.text = [NSString stringWithFormat:@"+%d",node.posRatings];
        negRatingLabel.text = [NSString stringWithFormat:@"-%d",node.negRatings];
        
        
        //cell behavior if its shown / not shown
        if (!node.inclusive)
        {
            [self.contentView setBackgroundColor:[UIColor lightGrayColor]];
            return self;
        }
        else
        {
            if(node.replyTo)
            {
                
                CGFloat kReplyBoxHeight = REPLY_TO_HEIGHT;
                CGFloat kReplyBoxWidth = SCREEN_WIDTH;
                CGFloat kReplyBoxX = 0;
                CGFloat kReplyBoxY = kCommentHeight;
                
                CGFloat kSubmitX = 250;
                CGFloat kSubmitY = kCommentHeight + REPLY_TO_HEIGHT + TEXTBOX_MARGIN;
                CGFloat kSubmitWidth = 60   ;
                CGFloat kSubmitHeight = 25;
                
                CGFloat kProposeX = 20;
                CGFloat kProposeY = kSubmitY;
                CGFloat kProposeWidth = 120   ;
                CGFloat kProposeHeight = 25;
                
                
                
                UITextView * tv = [[UITextView alloc]initWithFrame:CGRectMake(kReplyBoxX,kReplyBoxY,kReplyBoxWidth,kReplyBoxHeight)];
                [tv setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
                tv.tag = REPLYBOX_TAG;
                tv.layer.borderWidth = 2.0f;
                tv.layer.borderColor = [[UIColor grayColor] CGColor];
                [tv setTextColor:[UIColor darkGrayColor]];
                [tv setUserInteractionEnabled:YES];
                [tv setEditable:YES];
                
                
                UIButton * submitReply = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                submitReply.frame = CGRectMake(kSubmitX, kSubmitY, kSubmitWidth,kSubmitHeight);
                [submitReply setTitle:@"Submit" forState:UIControlStateNormal];
                [submitReply.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
                [submitReply.titleLabel setTextAlignment:NSTextAlignmentRight];
                [submitReply addTarget:self.delegate action:@selector(submitCommentTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                
                
                
                //propose a change
                UIButton *proposeAChangeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                proposeAChangeButton.frame = CGRectMake(kProposeX, kProposeY, kProposeWidth,kProposeHeight);
                [proposeAChangeButton setTitle:@"Propose a Change" forState:UIControlStateNormal];
                [proposeAChangeButton.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
                [proposeAChangeButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
                [proposeAChangeButton addTarget:self.delegate action:@selector(proposeChange:) forControlEvents:UIControlEventTouchUpInside];
                
                
                if(node.proposeChange)
                {
                    
                    CGSize proposedConstraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
                    CGSize size = [proposedChange sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:10] constrainedToSize:proposedConstraint lineBreakMode:NSLineBreakByWordWrapping];
                    CGFloat newHeight = MAX(size.height, DEFAULT_BUSTOPIC_CONTENT_HEIGHT);
                    
                    
                    CGFloat kProposeBoxX = kReplyBoxX;
                    CGFloat kProposeBoxY = kReplyBoxY+kReplyBoxHeight+ kSubmitHeight + TEXTBOX_MARGIN;
                    CGFloat kProposeBoxWidth = kReplyBoxWidth   ;
                    CGFloat kProposeBoxHeight = newHeight;
                    
                    UITextView * propose = [[UITextView alloc]initWithFrame:CGRectMake(kProposeBoxX,kProposeBoxY,kProposeBoxWidth,kProposeBoxHeight)];
                    //        [propose setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
                    [propose setFont:[UIFont fontWithName:@"GillSans-Light" size:10]];
                    propose.tag = PROPOSECHANGE_TAG;
                    propose.layer.borderWidth = 2.0f;
                    propose.layer.borderColor = [[UIColor grayColor] CGColor];
                    [propose setTextColor:[UIColor darkGrayColor]];
                    [propose setText:proposedChange];
                    [propose setUserInteractionEnabled:YES];
                    [propose setEditable:YES];
                    [self addSubview:propose];
                    
                    
                }
                
                
                [self addSubview:tv];
                [self addSubview:proposeAChangeButton];
                [self addSubview:submitReply];
            }
            
            
            //for the replyButton
            CGFloat kReplyHeight = 15;
            CGFloat kReplyWidth = 40;
            CGFloat kReplyX = kCommentWidth- kReplyWidth;
            CGFloat kReplyY = kCommentHeight - kReplyHeight;
            
            //author pic
            CGFloat kAuthorPicHeight = 30;
            CGFloat kAuthorPicWidth = 30;
            CGFloat kAuthorPicY = COLLAPSED_HEIGHT;
            CGFloat kAuthorPicX = kCommentWidth - kAuthorPicWidth - 5;
            
            //for the up/downvote arrows
            CGFloat buffer = 15;
            CGFloat kArroyHeight = 20;
            CGFloat kArroyWidth  = 20;
            CGFloat kArrow0Y = buffer;
            CGFloat kArrow1Y = kArrow0Y + kArroyHeight +4;
            CGFloat kArrowX = 2;
            
            //for the comment content
            CGFloat kCommentContentWidth = kCommentWidth-kAuthorPicWidth-10;
            CGFloat kCommentContentY = START_POSITION;
            CGFloat kCommentContentX = kArrowX + kArroyWidth;
            
            
            
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            self.accessoryType = UITableViewCellAccessoryNone;
            
            
            authorPic = [[UIImageView  alloc] initWithImage:node.user.profilePicture];
            authorPic.frame = CGRectMake(kAuthorPicX, kAuthorPicY, kAuthorPicWidth, kAuthorPicHeight);
            [self.contentView addSubview:authorPic];
            
            
            commentContent = [[UITextView alloc] initWithFrame:CGRectMake(kCommentContentX,kCommentContentY,kCommentContentWidth, kCommentHeight)];
            commentContent.tag = COMMENTTEXT_TAG;
            commentContent.font = [UIFont fontWithName:@"GillSans-Light"  size:12];
            commentContent.textAlignment = NSTextAlignmentLeft;
            commentContent.userInteractionEnabled = NO;
            commentContent.scrollEnabled = NO;
            commentContent.editable = NO;
            commentContent.userInteractionEnabled = NO;
            
            
            if ( [node isProposingNewChange])
            {
                [commentContent setBackgroundColor:[UIColor clearColor]];
                commentContent.textColor = [UIColor blueColor];
                
            }
            else
            {
                commentContent.backgroundColor = [UIColor clearColor];
                commentContent.textColor = [UIColor darkGrayColor];
                
            }
            
            
            
            
            // commentContent.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.contentView addSubview:commentContent];
            
            
            upButton = [UIButton buttonWithType:UIButtonTypeCustom];
            upButton.userInteractionEnabled = YES;
            upButton.tag = COMMENTUPRAITNG_TAG;
            [upButton setBackgroundColor:[UIColor clearColor]];
            [upButton setImage:[UIImage imageNamed:@"24-circle-north.png"] forState:UIControlStateNormal];
            [upButton setFrame:CGRectMake(kArrowX, kArrow0Y, kArroyWidth,kArroyHeight)];
            [self.contentView addSubview:upButton];
            
            downButton = [UIButton buttonWithType:UIButtonTypeCustom];
            downButton.userInteractionEnabled = YES;
            downButton.tag = COMMENTDOWNRAITNG_TAG;
            [downButton setBackgroundColor:[UIColor clearColor]];
            [downButton setImage:[UIImage imageNamed:@"32-circle-south.png"] forState:UIControlStateNormal];
            
            [downButton setFrame:CGRectMake(kArrowX, kArrow1Y, kArroyWidth,kArroyHeight)];
            [self.contentView addSubview:downButton];
            
            
            
            replyButton = [[UIButton alloc] initWithFrame:CGRectMake(kReplyX,kReplyY,kReplyWidth,kReplyHeight)];
            [replyButton setTitle:@"Reply" forState:UIControlStateNormal];
            [replyButton.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
            [replyButton.titleLabel setTextAlignment:NSTextAlignmentRight];
            [replyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [replyButton setTag:REPLYLABEL_TAG];
            [self.contentView addSubview:replyButton];
            
            commentContent.text =  [node getNodeText];
            [replyButton addTarget:self.delegate action:@selector(replyToComment:) forControlEvents:UIControlEventTouchUpInside];
            [upButton addTarget:self.delegate action:@selector(commentPosRateTap:) forControlEvents:UIControlEventTouchUpInside];
            [downButton addTarget:self.delegate action:@selector(commentNegRateTap:) forControlEvents:UIControlEventTouchUpInside];

        }
        
        
    }
    return self;
}


#pragma mark - Get Cell Heights

-(CGFloat)getCommentWidth: (ASZCommentCell*)cell
{
    CGFloat ret =  SCREEN_WIDTH - (XOFFSET+ (node.levelDepth - 1) * LEVEL_INDENT);
    return ret;
}

-(CGFloat)getCommentHeight: (ASZCommentCell*)cell
{
    
    CGFloat kCommentHeight;
    if(node.inclusive)
    {
        CGSize constraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
        CGSize size = [[node getNodeText] sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat cHeight = MAX(size.height + START_POSITION, DEFAULT_HEIGHT);
        kCommentHeight = cHeight + (CELL_MARGIN * 2) ;
        
    }
    else
        kCommentHeight = COLLAPSED_HEIGHT;
    
    
    return kCommentHeight;
    
    
}

-(CGFloat)getCommentX: (ASZCommentCell*)cell
{
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;

    return XOFFSET + (boundsX + node.levelDepth- 1) * LEVEL_INDENT;
}

#pragma mark -
#pragma mark Other overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    
   
    if (!self.editing) {
        
        // get the X pixel spot
        CGRect frame;
        
        frame = CGRectMake([self getCommentX:self],
                           0,
                           [self getCommentWidth:self],
                           [self getCommentHeight:self]);
        self.contentView.frame = frame;
        
        
        
        //for lines corresponding to level of nesting
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
