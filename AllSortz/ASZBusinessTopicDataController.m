//
//  ASZBusinessTopicDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/16/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessTopicDataController.h"

#import "ASZBusinessTopicViewController.h"

#import "ASZCommentList.h"

#import "ASURLEncoding.h"

#import  <QuartzCore/QuartzCore.h>


@interface ASZBusinessTopicDataController ()

@property NSOperationQueue *queue;  // Assume we only need one for now
@property (weak, nonatomic) IBOutlet UITableView *businessTopicTableView;
@property (weak, nonatomic) IBOutlet ASZBusinessTopicViewController *viewController;

- (ASZCommentList *)commentListFromJSONResult:(NSDictionary *)result;

@end

@implementation ASZBusinessTopicDataController

- (void)getCommentList:(NSUInteger)btID
{
    //get a base review for the business with ID
    // need a list of topics (and maybe what topics are already assoc. with busines)
    // might include text you've already written
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/comments/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)btID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSLog(@"Get review base with query %@",address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        self.commentList = [self commentListFromJSONResult:JSONresponse[@"result"]];
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
    
    return;
}


- (void)submitComment:(ASZCommentNode*)comment :(NSString*)content
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/comment/add/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)self.viewController.businessTopicID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSString *str = [[comment serializeToDictionary:content] urlEncodedString];
    NSLog(@"%@\n",str);
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    NSLog(@"Submit a comment with query %@\n\nPost Data %@",address,str);
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];

        ASZCommentNode *newComment =  [self commentFromJSONResult:JSONresponse[@"result"]];
        [comment addChild:newComment];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            comment.replyTo = NO;
            [self.viewController.tableView reloadData];
            
            
        });

        
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
    
}



- (NSURLRequest *)postRequestWithAddress: (NSString *)address        // IN
                                    data: (NSData *)data      // IN
{
    NSURL *url = [NSURL URLWithString:address];
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    NSString *postLength = [NSString stringWithFormat:@"%d", [data length]];
    [urlRequest setURL:[NSURL URLWithString:address]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:data];
    
    return urlRequest;
}




-(void)rateCommentAsynchronously:(ASZCommentNode*)node withRating:(NSInteger)rating withIndex:(NSIndexPath*)indPath
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/comment/rate/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&rating=%d", (unsigned long)node.commentID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID,rating];
    NSLog(@"Rate a comment from within the bustopic details page with query %@",address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
     
        ASZCommentNode *comment =  [self commentFromJSONResult:JSONresponse[@"result"]];
        

       
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentList.treeRoot  updateTree:self.commentList.treeRoot newComment:comment];
            [self.viewController.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        });

    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
    
}
- (void)submitModifiedBusTopicContent:(NSUInteger)btID
{
    //get a base review for the business with ID
    // need a list of topics (and maybe what topics are already assoc. with busines)
    // might include text you've already written
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/review/edit/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)btID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSLog(@"Get review base with query %@",address);
    NSString *str = [[self.commentList serializeBusTopicInfo] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    NSLog(@"Get details with query %@\n\nPost Data %@",address,str);

    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
       /* NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        self.commentList = [self commentListFromJSONResult:JSONresponse[@"result"]];*/
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
    
    return;
}

-(ASZCommentNode*)createTree:(id)review
{
    ASZCommentNode * n = [[ASZCommentNode alloc]initWithContent:[NSString stringWithFormat:@"%@",[review valueForKeyPath:@"content"]]];
    n.date =   [NSString stringWithFormat:@"%@", [review valueForKeyPath:@"date"]];
    n.posRatings = [[review valueForKeyPath:@"posRatings"]intValue];
    n.negRatings = [[review valueForKeyPath:@"negRatings"]intValue];
    n.creator = [NSString stringWithFormat:@"%@",[review valueForKeyPath:@"creator.userName"]];
    n.commentID = [[review valueForKeyPath:@"commentID"]intValue];
    for(NSDictionary* d in [review valueForKeyPath:@"children"])
    {
        id child = d;
        ASZCommentNode * c = [self createTree:child];
        [n addChild:c];
    }
    return n;
}

- (ASZCommentNode *)commentFromJSONResult:(NSDictionary *)result
{
    NSDictionary *review = result;
    ASZCommentNode* n = [self createTree:review];
    return n;
    
}



- (ASZCommentList *)commentListFromJSONResult:(NSDictionary *)result
{
    ASZCommentList *commentList = [[ASZCommentList alloc] initWithID:[[result valueForKeyPath:@"busTopicInfo.bustopicID"] unsignedIntegerValue]];
    if (!commentList)
        return nil;
    
    commentList.treeRoot = [[ASZCommentNode alloc]initWithContent:@"Root Node!"];
    for( NSDictionary *review in result[@"comments"])
    {
        ASZCommentNode *root = [self createTree:review];
        [commentList.treeRoot addChild:root];
    }
   // commentList.comments = [NSArray arrayWithArray:result[@"comments"]];
    
    commentList.busTopicInfo = [result valueForKeyPath:@"busTopicInfo.bustopicContent"];
    return commentList;
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // one for bustopic content the other for reviews / comments
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch(section)
    {
        case 0:
            return 1;   //the actual bustopiccontent
            break;
        case 1:
            return [self.commentList.treeRoot descendantCount];
            break;
        default:
            return 0;//self.businessTopicTableView.rowHeight;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell2 = nil;
    
    switch (indexPath.section) {
        case BUSTOPICCONTENT_SECTION:
            cell2 = [tableView dequeueReusableCellWithIdentifier:@"BusTopicContentCell"];
        {
           UITextView * tv = (UITextView*)[cell2 viewWithTag:BUSTOPICCONTENT_TAG];
            tv.text = self.commentList.busTopicInfo;
           // [tv.layer setBorderWidth:1];
           // [tv.layer setCornerRadius:8];
           // [tv.layer setBorderColor:[[UIColor grayColor] CGColor]];
            [cell2 setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
            return cell2;
        case COMMENTLIST_SECTION:
            
        {
            NSString *CellIdentifier = @"CommentCell";
            UILabel * authorLabel;
            UIImageView *authorPic;
            UILabel * dateLabel ;
            UITextView * commentContent;
            UILabel * posRatingLabel;
            UILabel * negRatingLabel;
            
            UIButton *replyButton;
            UIButton *upButton;
            UIButton *downButton;
            
            ASZCommentCell * cell = nil;
            //[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
            ASZCommentNode *node = [[self.commentList.treeRoot flattenElements] objectAtIndex:indexPath.row + 1];
            NSString * text = node.content;
            
            CGFloat kCommentHeight;
            if(node.inclusive)
            {
                CGSize constraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
                CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                CGFloat height = MAX(size.height + START_POSITION, DEFAULT_HEIGHT);
                kCommentHeight = height + (CELL_MARGIN * 2) ;

            }
            else
                kCommentHeight = COLLAPSED_HEIGHT;
            
            cell = [[ASZCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:CellIdentifier
                                                   level:[node levelDepth] - 1
                                                expanded:node.inclusive height:kCommentHeight];
            
            //get the height of teh cell
            CGFloat kCommentWidth =  [cell getCommentWidth:cell];
            
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
            [cell.contentView addSubview:authorLabel];
            
            UIColor* myDarkBlue = [UIColor colorWithRed: 0  green: .298 blue: .5963 alpha: 1];
            //UIColor* myDarkRed = [UIColor colorWithRed: .596 green: 0 blue: 0 alpha: 1];

            
            posRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(kRatingX,kRatingY,kRatingWidth,kRatingHeight)];
            posRatingLabel.tag = COMMENTPOSRATING_TAG;
            posRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
            posRatingLabel.textAlignment = NSTextAlignmentCenter;
            posRatingLabel.textColor =  myDarkBlue;
            posRatingLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:posRatingLabel];
            
            negRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(kRatingX+kRatingWidth,kRatingY,kRatingWidth,kRatingHeight)];
            negRatingLabel.tag = COMMENTNEGRATING_TAG;
            negRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
            negRatingLabel.textAlignment = NSTextAlignmentCenter;
            negRatingLabel.textColor = myDarkBlue;
            negRatingLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:negRatingLabel];
            
            
            dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDateX,kDateY,kDateWidth,kDateHeight)];
            dateLabel.tag = COMMENTDATE_TAG;
            dateLabel.font = [UIFont fontWithName:@"GillSans-Italic"  size:10];
            dateLabel.textAlignment = NSTextAlignmentLeft;
            dateLabel.textColor = [UIColor darkGrayColor];
            dateLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:dateLabel];
            
            dateLabel.text =  node.date;
            authorLabel.text = node.creator;
            posRatingLabel.text = [NSString stringWithFormat:@"+%d",node.posRatings];
            negRatingLabel.text = [NSString stringWithFormat:@"-%d",node.negRatings];
            
            if (!node.inclusive)
            {
                [cell.contentView setBackgroundColor:[UIColor lightGrayColor]];
                return cell;
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
                    CGFloat kSubmitY = kCommentHeight + REPLY_TO_HEIGHT;
                    CGFloat kSubmitWidth = 60   ;
                    CGFloat kSubmitHeight = 25;
                    
                    UITextView * tv = [[UITextView alloc]initWithFrame:CGRectMake(kReplyBoxX,kReplyBoxY,kReplyBoxWidth,kReplyBoxHeight)];
                    [tv setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
                    
                    tv.tag = REPLYBOX_TAG;
                    
                    tv.layer.borderWidth = 5.0f;
                    tv.layer.borderColor = [[UIColor grayColor] CGColor];
                    [tv setTextColor:[UIColor darkGrayColor]];
                    [tv setUserInteractionEnabled:YES];
                    [tv setEditable:YES];
                    
                    
                    UIButton * submitReply = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    submitReply.frame = CGRectMake(kSubmitX, kSubmitY, kSubmitWidth,kSubmitHeight);
                    [submitReply setTitle:@"Submit" forState:UIControlStateNormal];
                    [submitReply.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
                    [submitReply.titleLabel setTextAlignment:NSTextAlignmentRight];
                    [submitReply addTarget:self.viewController action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [cell addSubview:tv];
                    [cell addSubview:submitReply];
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
                CGFloat kArroyHeight = 16;
                CGFloat kArroyWidth  = 10;
                CGFloat kArrow0Y = buffer;
                CGFloat kArrow1Y = kArrow0Y + kArroyHeight +4;
                CGFloat kArrowX = 5;
                
                //for the comment content
                CGFloat kCommentContentWidth = COMMENT_WIDTH;
                CGFloat kCommentContentY = START_POSITION;
                CGFloat kCommentContentX = kArrowX + kArroyWidth;


                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
             
                authorPic = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"zouf.png"]];
                authorPic.frame = CGRectMake(kAuthorPicX, kAuthorPicY, kAuthorPicWidth, kAuthorPicHeight);
                [cell.contentView addSubview:authorPic];

                
                commentContent = [[UITextView alloc] initWithFrame:CGRectMake(kCommentContentX,kCommentContentY,kCommentContentWidth, kCommentHeight)];
                commentContent.tag = COMMENTTEXT_TAG;
                commentContent.font = [UIFont fontWithName:@"GillSans-Light"  size:12];
                commentContent.textAlignment = NSTextAlignmentLeft;
                commentContent.userInteractionEnabled = NO;
                commentContent.textColor = [UIColor darkGrayColor];
                commentContent.scrollEnabled = NO;
                commentContent.editable = NO;
                commentContent.userInteractionEnabled = NO;
                commentContent.backgroundColor = [UIColor clearColor];
                
               // commentContent.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [cell.contentView addSubview:commentContent];
                

                upButton = [UIButton buttonWithType:UIButtonTypeCustom];
                upButton.userInteractionEnabled = YES;
                upButton.tag = COMMENTUPRAITNG_TAG;
                [upButton setBackgroundColor:[UIColor clearColor]];
                [upButton setImage:[UIImage imageNamed:@"up-arrow.png"] forState:UIControlStateNormal];
                [upButton setFrame:CGRectMake(kArrowX, kArrow0Y, kArroyWidth,kArroyHeight)];
                [cell.contentView addSubview:upButton];
                
                downButton = [UIButton buttonWithType:UIButtonTypeCustom];
                downButton.userInteractionEnabled = YES;
                downButton.tag = COMMENTDOWNRAITNG_TAG;
                [downButton setBackgroundColor:[UIColor clearColor]];
                [downButton setImage:[UIImage imageNamed:@"down-arrow.png"] forState:UIControlStateNormal];

                [downButton setFrame:CGRectMake(kArrowX, kArrow1Y, kArroyWidth,kArroyHeight)];
                [cell.contentView addSubview:downButton];
                
                

                replyButton = [[UIButton alloc] initWithFrame:CGRectMake(kReplyX,kReplyY,kReplyWidth,kReplyHeight)];
                [replyButton setTitle:@"Reply" forState:UIControlStateNormal];
                [replyButton.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
                [replyButton.titleLabel setTextAlignment:NSTextAlignmentRight];
                [replyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [replyButton setTag:REPLYLABEL_TAG];
                [cell.contentView addSubview:replyButton];


                commentContent.text =  node.content;            
                [replyButton addTarget:self.viewController action:@selector(replyToComment:) forControlEvents:UIControlEventTouchUpInside];
                
                [upButton addTarget:self.viewController action:@selector(commentPosRateTap:) forControlEvents:UIControlEventTouchUpInside];
                [downButton addTarget:self.viewController action:@selector(commentNegRateTap:) forControlEvents:UIControlEventTouchUpInside];

                return cell;
            }
     

        }
        default:
            return nil;

    }
}

@end
