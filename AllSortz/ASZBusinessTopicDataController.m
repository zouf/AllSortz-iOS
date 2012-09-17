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

#define BUSTOPICCONTENT_TAG 200
#define COMMENTAUTHOR_TAG 201
#define COMMENTTEXT_TAG 202
#define COMMENTDATE_TAG 203
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


- (void)submitModifiedBusTopicContent:(NSUInteger)btID
{
    //get a base review for the business with ID
    // need a list of topics (and maybe what topics are already assoc. with busines)
    // might include text you've already written
    
    NSString *address = [NSString stringWithFormat:@"http://127.0.0.1:8000/api/review/edit/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)btID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
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
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BusTopicContentCell"];
        {
           UITextView * tv = (UITextView*)[cell viewWithTag:BUSTOPICCONTENT_TAG];
            tv.text = self.commentList.busTopicInfo;
        }
            return cell;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        {
            id comment = [self.commentList.comments objectAtIndex:indexPath.row];
          //  NSLog(@"comment text is %@ author is %@  date is %@ \n", [comment valueForKeyPath:@"content"], [comment valueForKeyPath:@"creator.userName"], [comment valueForKeyPath:@"date"] );
            UILabel * authorLabel = (UILabel*)[cell viewWithTag:COMMENTAUTHOR_TAG];
            UILabel * dateLabel = (UILabel*)[cell viewWithTag:COMMENTDATE_TAG];
            UILabel * commentContent = (UILabel*)[cell viewWithTag:COMMENTTEXT_TAG];
            dateLabel.text =  [NSString stringWithFormat:@"%@", [comment valueForKeyPath:@"date"]];
            authorLabel.text = [NSString stringWithFormat:@"%@",[comment valueForKeyPath:@"creator.userName"]];
            commentContent.text = [NSString stringWithFormat:@"%@",[comment valueForKeyPath:@"content"]];
            [commentContent sizeToFit];
        }
            return cell;
        default:
            return cell;

    }
}

@end
