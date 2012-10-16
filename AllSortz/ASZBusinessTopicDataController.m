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

#import "ASZCommentCell.h"

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


-(void)rateCommentAsynchronously:(NSUInteger)cID withRating:(NSInteger)rating
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/comment/rate/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&rating=%d", (unsigned long)cID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID,rating];
    NSLog(@"Rate a comment from within the bustopic details page with query %@",address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {

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
            CGSize constraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat height = MAX(size.height + START_POSITION, DEFAULT_HEIGHT);
            CGFloat kCommentHeight = height + (CELL_MARGIN * 2) ;

            
            
            cell = [[ASZCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:CellIdentifier
                                                   level:[node levelDepth] - 1
                                                expanded:node.inclusive height:kCommentHeight];
            
            //get the height of teh cell
            CGFloat kCommentWidth =  [cell getCommentWidth:cell];

            //for pos / neg rating labels
            CGFloat kRatingY = 40;
            
            //for the replyButton
            CGFloat kReplyHeight = 15;
            CGFloat kReplyWidth = 40;
            CGFloat kReplyX = kCommentWidth- kReplyWidth;
            CGFloat kReplyY = kCommentHeight - kReplyHeight;
            
            //author pic
            CGFloat kAuthorPicHeight = 30;
            CGFloat kAuthorPicWidth = 30;
            CGFloat kAuthorPicY = 5;
            CGFloat kAuthorPicX = kCommentWidth - kAuthorPicWidth - 5;
            
            //Author label
            CGFloat kAuthorWidth = 40;
            CGFloat kAuthorHeight = 25;
            CGFloat kAuthorX = kCommentWidth - kAuthorWidth;
            CGFloat kAuthorY = 30;
            
            //for the up/downvote arrows
            CGFloat buffer = 15;
            CGFloat kArroyHeight = 12;
            CGFloat kArroyWidth  = kArroyHeight;
            CGFloat kArrow0Y = buffer;
            CGFloat kArrow1Y = kArrow0Y + kArroyHeight +4;
            CGFloat kArrowX = 2;
                        
            //for date
            CGFloat kDateX = 20;
            CGFloat kDateY  = 0;
            CGFloat kDateWidth = 70;
            CGFloat kDateHeight = 25;
            

            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(kAuthorX,kAuthorY,kAuthorWidth,kAuthorHeight)];
            authorLabel.tag = COMMENTAUTHOR_TAG;
            authorLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
            authorLabel.textAlignment = NSTextAlignmentCenter;
            authorLabel.textColor = [UIColor darkGrayColor];
            authorLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:authorLabel];
            
            authorPic = [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"zouf.png"]];
            authorPic.frame = CGRectMake(kAuthorPicX, kAuthorPicY, kAuthorPicWidth, kAuthorPicHeight);
            [cell.contentView addSubview:authorPic];
            
            dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDateX,kDateY,kDateWidth,kDateHeight)];
            dateLabel.tag = COMMENTDATE_TAG;
            dateLabel.font = [UIFont fontWithName:@"GillSans-Italic"  size:10];
            dateLabel.textAlignment = NSTextAlignmentLeft;
            dateLabel.textColor = [UIColor darkGrayColor];
            dateLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:dateLabel];
            
            
            commentContent = [[UITextView alloc] initWithFrame:CGRectMake(kArrowX + kArroyWidth, START_POSITION, COMMENT_WIDTH, kCommentHeight)];
            commentContent.tag = COMMENTTEXT_TAG;
            commentContent.font = [UIFont fontWithName:@"GillSans-Light"  size:14];
            commentContent.textAlignment = NSTextAlignmentLeft;
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
            [upButton setImage:[UIImage imageNamed:@"upvote-export.png"] forState:UIControlStateNormal];
            [upButton setFrame:CGRectMake(kArrowX, kArrow0Y, kArroyWidth,kArroyHeight)];
            [cell.contentView addSubview:upButton];
            
            downButton = [UIButton buttonWithType:UIButtonTypeCustom];
            downButton.userInteractionEnabled = YES;
            downButton.tag = COMMENTDOWNRAITNG_TAG;
            [downButton setBackgroundColor:[UIColor clearColor]];
            [downButton setImage:[UIImage imageNamed:@"downvote-export.png"] forState:UIControlStateNormal];
            [downButton setFrame:CGRectMake(kArrowX, kArrow1Y, kArroyWidth,kArroyHeight)];
            [cell.contentView addSubview:downButton];
            
            
            posRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,kRatingY,10,26.0)];
            posRatingLabel.tag = COMMENTPOSRATING_TAG;
            posRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
            posRatingLabel.textAlignment = NSTextAlignmentCenter;
            posRatingLabel.textColor = [UIColor greenColor];
            posRatingLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:posRatingLabel];
            
            negRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,kRatingY,10,26.0)];
            negRatingLabel.tag = COMMENTNEGRATING_TAG;
            negRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
            negRatingLabel.textAlignment = NSTextAlignmentCenter;
            negRatingLabel.textColor = [UIColor redColor];
            negRatingLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:negRatingLabel];
            
            replyButton = [[UIButton alloc] initWithFrame:CGRectMake(kReplyX,kReplyY,kReplyWidth,kReplyHeight)];
            [replyButton setTitle:@"Reply" forState:UIControlStateNormal];
            [replyButton.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
            [replyButton.titleLabel setTextAlignment:NSTextAlignmentRight];
            [replyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [replyButton setTag:REPLYLABEL_TAG];
            [cell.contentView addSubview:replyButton];
            
            /*        authorLabel = (UILabel*)[cell.contentView viewWithTag:COMMENTAUTHOR_TAG];
                commentContent = (UITextView*)[cell.contentView viewWithTag:COMMENTTEXT_TAG];
               // rateSelector = (UISegmentedControl*)[cell.contentView viewWithTag:COMMENTRATE_TAG];
                dateLabel = (UILabel*)[cell.contentView viewWithTag:COMMENTDATE_TAG];
                posRatingLabel = (UILabel*)[cell.contentView viewWithTag:COMMENTPOSRATING_TAG];
                negRatingLabel = (UILabel*)[cell.contentView viewWithTag:COMMENTNEGRATING_TAG];
                replyButton = (UIButton*)[cell.contentView viewWithTag:REPLYLABEL_TAG];
          */      

            dateLabel.text =  node.date; // [NSString stringWithFormat:@"%@", [review valueForKeyPath:@"date"]];
            authorLabel.text = node.creator; //[NSString stringWithFormat:@"%@",[review valueForKeyPath:@"creator.userName"]];
            commentContent.text =  node.content; //[NSString stringWithFormat:@"%@",[review valueForKeyPath:@"content"]];
            posRatingLabel.text = [NSString stringWithFormat:@"%d",node.posRatings];
            negRatingLabel.text = [NSString stringWithFormat:@"%d",node.negRatings];
            
            
            [replyButton addTarget:self.viewController action:@selector(replyToComment:) forControlEvents:UIControlEventTouchUpInside];
            
            [upButton addTarget:self.viewController action:@selector(commentPosRateTap:) forControlEvents:UIControlEventTouchUpInside];
            [downButton addTarget:self.viewController action:@selector(commentNegRateTap:) forControlEvents:UIControlEventTouchUpInside];

            return cell;

        }
        default:
            return nil;

    }
}

@end
