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

- (ASZCommentList *)commentListFromJSONResult:(NSDictionary *)result
{
    ASZCommentList *commentList = [[ASZCommentList alloc] initWithID:[[result valueForKeyPath:@"busTopicInfo.bustopicID"] unsignedIntegerValue]];
    if (!commentList)
        return nil;
    
   
    commentList.comments = [NSArray arrayWithArray:result[@"comments"]];
    
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
            return self.commentList.comments.count;
            break;
        default:
            return 0;//self.businessTopicTableView.rowHeight;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case BUSTOPICCONTENT_SECTION:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BusTopicContentCell"];
        {
           UITextView * tv = (UITextView*)[cell viewWithTag:BUSTOPICCONTENT_TAG];
            tv.text = self.commentList.busTopicInfo;
            [tv.layer setBorderWidth:1];
            [tv.layer setCornerRadius:8];
            [tv.layer setBorderColor:[[UIColor grayColor] CGColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
            return cell;
        case COMMENTLIST_SECTION:
            
        {
            NSString *CellIdentifier = @"CommentCell";
            UILabel * authorLabel;
            UILabel * dateLabel ;
            UITextView * commentContent;
            UISegmentedControl * rateSelector;
            UILabel * posRatingLabel;
            UILabel * negRatingLabel;
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                authorLabel = [[UILabel alloc]initWithFrame:CGRectMake(16,0,82.0,26)];
                authorLabel.tag = COMMENTAUTHOR_TAG;
                authorLabel.font = [UIFont fontWithName:@"GillSans-Bold"  size:10];
                authorLabel.textAlignment = NSTextAlignmentLeft;
                authorLabel.textColor = [UIColor darkGrayColor];
                authorLabel.backgroundColor = [UIColor clearColor];
                
                authorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [cell.contentView addSubview:authorLabel];
                
                
                dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(225,0,82.0,26)];
                dateLabel.tag = COMMENTDATE_TAG;
                dateLabel.font = [UIFont fontWithName:@"GillSans-Italic"  size:10];
                dateLabel.textAlignment = NSTextAlignmentRight;
                dateLabel.textColor = [UIColor darkGrayColor];
                dateLabel.backgroundColor = [UIColor clearColor];
                
                dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [cell.contentView addSubview:dateLabel];
                
                
                commentContent = [[UITextView alloc] initWithFrame:CGRectMake(100, 10, COMMENT_WIDTH, 75)];
                commentContent.tag = COMMENTTEXT_TAG;
                commentContent.font = [UIFont fontWithName:@"GillSans-Light"  size:14];
                commentContent.textAlignment = NSTextAlignmentLeft;
                commentContent.textColor = [UIColor darkGrayColor];
                commentContent.scrollEnabled = NO;
                commentContent.editable = NO;
                commentContent.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                commentContent.backgroundColor = [UIColor clearColor];
                
                commentContent.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [cell.contentView addSubview:commentContent];
                
                UIFont *font = [UIFont fontWithName:@"Gill Sans" size:12];
                NSArray *itemArray = [NSArray arrayWithObjects: @"Down", @"Up", nil];
                rateSelector = [[UISegmentedControl alloc] initWithItems:itemArray];
                rateSelector.tag = COMMENTRATE_TAG;
                rateSelector.frame = CGRectMake(11, 50, 72  , 25);
                rateSelector.segmentedControlStyle = UISegmentedControlStyleBar;
                rateSelector.backgroundColor = [UIColor clearColor];
                
                rateSelector.selectedSegmentIndex = 1;
                
                NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                       forKey:UITextAttributeFont];
                [rateSelector setTitleTextAttributes:attributes
                                            forState:UIControlStateNormal];
                
                
                [cell.contentView addSubview:rateSelector];
                
                posRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(30,15,10,26.0)];
                posRatingLabel.tag = COMMENTPOSRATING_TAG;
                posRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
                posRatingLabel.textAlignment = NSTextAlignmentCenter;
                posRatingLabel.textColor = [UIColor greenColor];
                posRatingLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:posRatingLabel];
                
                negRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,15,10,26.0)];
                negRatingLabel.tag = COMMENTNEGRATING_TAG;
                negRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
                negRatingLabel.textAlignment = NSTextAlignmentCenter;
                negRatingLabel.textColor = [UIColor redColor];
                negRatingLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:negRatingLabel];
                
            }
            else
            {
                authorLabel = (UILabel*)[cell.contentView viewWithTag:COMMENTAUTHOR_TAG];
                commentContent = (UITextView*)[cell.contentView viewWithTag:COMMENTTEXT_TAG];
                rateSelector = (UISegmentedControl*)[cell.contentView viewWithTag:COMMENTRATE_TAG];
                dateLabel = (UILabel*)[cell viewWithTag:COMMENTDATE_TAG];
                posRatingLabel = (UILabel*)[cell viewWithTag:COMMENTPOSRATING_TAG];
                negRatingLabel = (UILabel*)[cell viewWithTag:COMMENTNEGRATING_TAG];
                
                
            }
            id review = [self.commentList.comments objectAtIndex:indexPath.row];
            dateLabel.text =  [NSString stringWithFormat:@"%@", [review valueForKeyPath:@"date"]];
            authorLabel.text = [NSString stringWithFormat:@"%@",[review valueForKeyPath:@"creator.userName"]];
            commentContent.text = [NSString stringWithFormat:@"%@",[review valueForKeyPath:@"content"]];
            posRatingLabel.text = [NSString stringWithFormat:@"%@",[review valueForKeyPath:@"posRatings"]];
            negRatingLabel.text = [NSString stringWithFormat:@"%@",[review valueForKeyPath:@"negRatings"]];
            
            if ([review objectForKey:@"thisUsers"])
            {
                if ([[review valueForKey:@"thisUsers"] intValue] == 0)
                {
                    [rateSelector setSelectedSegmentIndex:0];
                }
                else
                {
                    [rateSelector setSelectedSegmentIndex:1];
                }
                
            }
            else
            {
                //TODO change to none
                [rateSelector setSelected:NO];
                
            }
            [rateSelector addTarget:self.viewController action:@selector(commentRateTap:) forControlEvents:UIControlEventAllEvents];
    }
            return cell;
        default:
            return cell;

    }
}

@end
