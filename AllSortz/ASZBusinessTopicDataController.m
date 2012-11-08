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

#import "ASGlobal.h"

#import  <QuartzCore/QuartzCore.h>

#import "ASUser.h"

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

- (void)submitRootCommentWithContent:(NSString*)content  proposedChange:(NSString*)proposedChange
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/comment/add/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)self.viewController.businessTopicID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSString *str = [[self.commentList.treeRoot serializeToDictionary:content  proposedChange:proposedChange] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    NSLog(@"Submit a ROOT comment with query %@\n\nPost Data %@",address,str);
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.commentList.treeRoot.replyTo = NO;


                    [self.viewController.tableView beginUpdates];
                    [self.viewController.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.viewController.tableView endUpdates];
                    
                    ASZCommentNode *newComment =  [self commentFromJSONResult:JSONresponse[@"result"]];
                    [self.commentList.treeRoot addChild:newComment];
                    NSRange range = NSMakeRange(1, 1);
                    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.viewController.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.viewController.tableView endUpdates];
                    
         
            
            
        });
        
        
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
    
}


- (void)submitComment:(ASZCommentNode*)comment :(NSString*)content  proposedChange:(NSString*)proposedChange
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/comment/add/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)self.viewController.businessTopicID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSString *str = [[comment serializeToDictionary:content  proposedChange:proposedChange] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    NSLog(@"Submit a comment with query %@\n\nPost Data %@",address,str);
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];


        
        dispatch_async(dispatch_get_main_queue(), ^{
            comment.replyTo = NO;
            for(int i = 0; i < [[self.commentList.treeRoot flattenedTreeCache] count]; i++)
            {
                ASZCommentNode*n = [[self.commentList.treeRoot flattenedTreeCache] objectAtIndex:i];
                if ( [n isEqual:comment] )
                {
                    
                    [self.viewController.tableView beginUpdates];
                    [self.viewController.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:i-1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.viewController.tableView endUpdates];
                    
                    ASZCommentNode *newComment =  [self commentFromJSONResult:JSONresponse[@"result"]];
                    [comment addChild:newComment];

                    [self.viewController.tableView beginUpdates];
                    [self.viewController.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.viewController.tableView endUpdates];

                }
            }
            
            
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

#pragma mark - User Download icon delegate

-(void)imageDidLoad:(ASUser *)user
{
    [self.viewController.tableView reloadData];
}

-(ASZCommentNode*)createTree:(id)review
{
    ASZCommentNode * n = [[ASZCommentNode alloc]initWithContent:[NSString stringWithFormat:@"%@",[review valueForKeyPath:@"content"]] proposedChange:[review valueForKeyPath:@"proposedChange"]];
    n.date =   [NSString stringWithFormat:@"%@", [review valueForKeyPath:@"date"]];
    n.posRatings = [[review valueForKeyPath:@"posRatings"]intValue];
    n.negRatings = [[review valueForKeyPath:@"negRatings"]intValue];
    n.creator = [NSString stringWithFormat:@"%@",[review valueForKeyPath:@"creator.userName"]];
    n.commentID = [[review valueForKeyPath:@"commentID"]intValue];
    n.user = [[ASUser alloc]initWithJSONObject:[review valueForKey:@"creator"]];
    n.user.delegate = self;

    
    
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
    
    commentList.treeRoot = [[ASZCommentNode alloc]initWithContent:@"Root Node!" proposedChange:@""] ;
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
        
        default:
            return 0;//self.businessTopicTableView.rowHeight;
            break;
    }
}


/* TODO
 
 Right now I don't really use the dequeueReusableCell method since I do a lot of work
 trying to collapse and expand the cells on each table. We can probably get some performance
 if we reuse cells. But, that'll take some design work with the ability to collapse cells and expand
 the reply box functionality */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell2 = nil;
    
    switch (indexPath.section) {
        case BUSTOPICCONTENT_SECTION:

        {
            //TODO resuse old cells
            NSString * CellIdentifier = @"BusTopicContentCell";
            cell2 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            NSString * text = self.commentList.busTopicInfo;
            
            CGSize constraint = CGSizeMake(320 - (CELL_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
            CGFloat kHeight = MAX(size.height, DEFAULT_BUSTOPIC_CONTENT_HEIGHT) ;
            
            UITextView * tv = (UITextView*)[cell2 viewWithTag:BUSTOPICCONTENT_TAG];
            if(!tv)
            {
                tv = [[UITextView alloc]initWithFrame:CGRectMake(0,0,constraint.width,kHeight)];
                tv.tag = BUSTOPICCONTENT_TAG;
                [cell2 addSubview:tv];
                [tv setFont:[UIFont fontWithName:@"GillSans-Light"  size:14]];
                
            }
            
            
            tv.text = self.commentList.busTopicInfo;
            [cell2 setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            if(self.commentList.treeRoot.replyTo)
            {
                    
                    CGFloat kReplyBoxHeight = REPLY_TO_HEIGHT;
                    CGFloat kReplyBoxWidth = SCREEN_WIDTH;
                    CGFloat kReplyBoxX = 0;
                    CGFloat kReplyBoxY = kHeight;
                    
                    CGFloat kSubmitX = 250;
                    CGFloat kSubmitY = kHeight + kReplyBoxHeight + TEXTBOX_MARGIN;
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
                    [submitReply addTarget:self.viewController action:@selector(submitCommentTapped:) forControlEvents:UIControlEventTouchUpInside];
                    
                    
                    
                    
                    //propose a change
                    UIButton *proposeAChangeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    proposeAChangeButton.frame = CGRectMake(kProposeX, kProposeY, kProposeWidth,kProposeHeight);
                    [proposeAChangeButton setTitle:@"Propose a Change" forState:UIControlStateNormal];
                    [proposeAChangeButton.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:12]];
                    [proposeAChangeButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
                    [proposeAChangeButton addTarget:self.viewController action:@selector(proposeChange:) forControlEvents:UIControlEventTouchUpInside];
                    
                    
                    if(self.commentList.treeRoot.proposeChange)
                    {
                        
                        
                        NSString * proposedText = self.commentList.busTopicInfo;
                        CGSize proposedConstraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
                        CGSize size = [proposedText sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:10] constrainedToSize:proposedConstraint lineBreakMode:NSLineBreakByWordWrapping];
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
                        [propose setText:self.commentList.busTopicInfo];
                        [propose setUserInteractionEnabled:YES];
                        [propose setEditable:YES];
                        [cell2 addSubview:propose];
                        
                        
                    }
                
                    [cell2 addSubview:tv];
                    [cell2 addSubview:proposeAChangeButton];
                    [cell2 addSubview:submitReply];
                }
        }
            return cell2;
        case COMMENTLIST_SECTION:
            
        {
            NSString *CellIdentifier = @"CommentCell";
            ASZCommentNode *node = [[self.commentList.treeRoot flattenElements] objectAtIndex:indexPath.row + 1];
            ASZCommentCell * cell  = [[ASZCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier treeNode:node busTopicInfo:self.commentList.busTopicInfo delegate:self.viewController];
            
            return cell;
        
     

        }
        default:
            return nil;

    }
}

@end
