//
//  ASZReviewDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/15/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZReviewDataController.h"
#import "ASZReviewViewController.h"
#import "ASURLEncoding.h"

#define TOPICLABEL_TAG 200
#define TEXTVIEW_TAG 201

@interface ASZReviewDataController ()

@property NSOperationQueue *queue;  // Assume we only need one for now
@property (weak, nonatomic) IBOutlet UITableView *reviewTableView;
@property (weak, nonatomic) IBOutlet ASZReviewViewController *viewController;

- (ASZReview *)reviewFromJSONResult:(NSDictionary *)result;

@end



@implementation ASZReviewDataController



- (void)getReviewInfo:(NSUInteger)ID
{
    //get a base review for the business with ID
    // need a list of topics (and maybe what topics are already assoc. with busines)
    // might include text you've already written
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/review/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)ID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSLog(@"Get review base with query %@",address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        self.review = [self reviewFromJSONResult:JSONresponse[@"result"]];
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



- (void)submitReviewWithTopics:(NSArray*)topics;
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/comment/add/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)self.viewController.businessID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSString *str = [[self.review serializeToDictionaryWithTopics:topics] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    NSLog(@"Get details with query %@\n\nPost Data %@",address,str);
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        //    NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data  options:0 error:NULL];
        //    self.business = [self businessFromJSONResult:JSONresponse[@"result"]];
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];

}

- (ASZReview *)reviewFromJSONResult:(NSDictionary *)result
{
    ASZReview *review = [[ASZReview alloc] initWithID:[result[@"businessID"] unsignedIntegerValue]];
    if (!review)
        return nil;
        
       
    NSMutableArray *allTopics = [NSMutableArray arrayWithCapacity:[result[@"allTopics"] count]];
    for (NSDictionary *t in result[@"allTopics"])
    {
        NSMutableDictionary *topic = [NSMutableDictionary dictionary];
    
        [topic setValue:[t valueForKeyPath:@"parentID"] forKey:@"ID"];
        [topic setValue:[t valueForKeyPath:@"parentName"] forKey:@"name"];
        [topic setValue:[t valueForKeyPath:@"parentIcon"] forKey:@"icon"];
        [allTopics addObject:[NSMutableDictionary dictionaryWithDictionary:topic]];
        
    
        
    }
        // Sort topics into order they should be displayed
    
    
    review.allTopics = (NSMutableArray*)[allTopics sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2) {
        NSString *name1 = [obj1 valueForKey:@"name"];
        NSString *name2 = [obj2 valueForKey:@"name"];
        if ([name1 isEqualToString:name2]) return NSOrderedSame;
        if ([name1 isEqualToString:@"Synopsis"]) return NSOrderedAscending;
        if ([name2 isEqualToString:@"Synopsis"]) return NSOrderedDescending;
        return [name1 localizedCompare:name2];
    }];
    

    return review;

}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewText"];
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            //UITextView * reviewText = (UITextView*)[cell viewWithTag:TEXTVIEW_TAG];
            //reviewText.text = [NSString stringWithFormat:@"What did you think of %@?\n",self.viewController.businessName];
        }
            return cell;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TopicCell"];
        {
            UILabel *topicName = (UILabel*)[cell viewWithTag:TOPICLABEL_TAG];
            id topic = self.review.allTopics[indexPath.row];
            topicName.text = [topic valueForKey:@"name"];
            
        }
            return cell;
        default:
            return cell;
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            // TODO: Show info
            return self.review.allTopics.count;
            break;
        default:
            return 0;
            break;
    }
}

@end