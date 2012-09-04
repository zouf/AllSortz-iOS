//
//  ASZBusinessDetailsDataController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessDetailsDataController.h"

#import "ASBusiness.h"

#define BUSINESSIMAGEVIEW_TAG 1000
#define BUSINESSNAMELABEL_TAG 1001
#define BUSINESSHEALTH_TAG 1002
#define BUSINESSHOURS_TAG 1003
#define BUSINESSPHONE_TAG 1004
#define BUSINESSURL_TAG 1005
#define BUSINESSADDRESS_TAG 1006
#define BUSINESSSCORE_TAG 1007






#define TOPICNAMELABEL_TAG 1010
#define TOPICTEXTVIEW_TAG 1012
#define TOPICRATINGVIEW_TAG 1013




@interface ASZBusinessDetailsDataController ()

@property NSOperationQueue *queue;  // Assume we only need one for now
@property (weak, nonatomic) IBOutlet UITableView *businessTableView;

- (ASBusiness *)businessFromJSONResult:(NSDictionary *)result;

@end


@implementation ASZBusinessDetailsDataController

#pragma mark - Data download
@synthesize businessTableView = _businessTableView;

- (void)refreshBusinessAsynchronouslyWithID:(NSUInteger)ID
{
    if (!(ID && self.username && self.currentLatitude && self.currentLongitude && self.UUID)) {
        self.business = nil;
        return;
    }

    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/business/%lu?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)ID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSLog(@"Get details with query %@",address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        self.business = [self businessFromJSONResult:JSONresponse[@"result"]];
    };

    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
}

- (ASBusiness *)businessFromJSONResult:(NSDictionary *)result
{
    ASBusiness *business = [[ASBusiness alloc] initWithID:[result[@"businessID"] unsignedIntegerValue]];
    if (!business)
        return nil;

    business.address = result[@"streetAddr"];
    business.city = result[@"businessCity"];
    business.state = result[@"businessState"];

    business.hours = [result[@"businessHours"] componentsSeparatedByString:@", "];
    business.name = result[@"businessName"];
    business.phone = result[@"businessPhone"];
    business.website = [NSURL URLWithString:result[@"businessURL"]];

    business.recommendation = [result[@"ratingRecommendation"] floatValue];
        
    NSMutableArray *topics = [NSMutableArray arrayWithCapacity:[result[@"categories"] count]];
    
    NSDictionary *hinfo = result[@"health_info"];
    business.healthGrade = [hinfo valueForKey:@"health_grade"];
    
    for (NSDictionary *category in result[@"categories"]) {
        NSMutableDictionary *topic = [NSMutableDictionary dictionary];
        [topic setValuesForKeysWithDictionary:@{@"ID": [category valueForKeyPath:@"topic.parentID"],
                                                @"name": [category valueForKeyPath:@"topic.parentName"],
                                                @"rating": [category valueForKey:@"bustopicRating"],
                                                @"summary": [category valueForKey:@"bustopicContent"]}];
        
        NSLog(@"%@\n",category);

        // Don't want a mutable dictionary in there
        [topics addObject:[NSDictionary dictionaryWithDictionary:topic]];
    }

    // Sort topics into order they should be displayed
    business.topics = [topics sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2) {
        NSString *name1 = [obj1 valueForKey:@"name"];
        NSString *name2 = [obj2 valueForKey:@"name"];
        if ([name1 isEqualToString:name2]) return NSOrderedSame;
        if ([name1 isEqualToString:@"Main"]) return NSOrderedAscending;
        if ([name2 isEqualToString:@"Main"]) return NSOrderedDescending;
        return [name1 localizedCompare:name2];
    }];

    // Fetch image asynchronously
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:result[@"photoURL"]]];
    void (^imageHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        business.image = [UIImage imageWithData:data];
    };
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:imageRequest queue:self.queue completionHandler:imageHandler];

    return business;
}


#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    switch (indexPath.section) {
        case ASZBusinessDetailsHeaderSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessDetailsHeaderCell"];
        {
            UILabel *name = (UILabel *)[cell.contentView viewWithTag:BUSINESSNAMELABEL_TAG];
            name.text = self.business.name;
            
            UILabel *hours = (UILabel*)[cell.contentView viewWithTag:BUSINESSHOURS_TAG];
            hours.text = self.business.hours[0];
            
            UIButton *url = (UIButton *)[cell.contentView viewWithTag:BUSINESSURL_TAG];
            [url setTitle:self.business.website.path forState:UIControlStateNormal];
            
            UIButton *phone = (UIButton *)[cell.contentView viewWithTag:BUSINESSPHONE_TAG];
            [phone setTitle:self.business.phone forState:UIControlStateNormal];
            
            UIImageView *healthGrade = (UIImageView*)[cell.contentView viewWithTag:BUSINESSHEALTH_TAG];
            
            UIProgressView* score = (UIProgressView*)[cell.contentView viewWithTag:BUSINESSSCORE_TAG];
            


        }
            return cell;
        case ASZBusinessDetailsTopicSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessDetailsTopicCell"];
        {
            id topic = self.business.topics[indexPath.row];

            UILabel *topicName = (UILabel *)[cell.contentView viewWithTag:TOPICNAMELABEL_TAG];
            topicName.text = [topic valueForKey:@"name"];

            UITextView *topicSummary = (UITextView *)[cell.contentView viewWithTag:TOPICTEXTVIEW_TAG];
            topicSummary.text = [topic valueForKey:@"summary"];
            
            UIProgressView *ratingView = (UIProgressView*)[cell.contentView viewWithTag:TOPICRATINGVIEW_TAG];
            ratingView.progress = [[topic valueForKey:@"rating"] floatValue];
            
            
            
            
            

        }
            return cell;
        default:
            return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case ASZBusinessDetailsHeaderSection:
            return 1;
            break;
        case ASZBusinessDetailsInfoSection:
            // TODO: Show info
            return 0;
            break;
        case ASZBusinessDetailsTopicSection:
            return [self.business.topics count];
            break;
        default:
            return 0;
            break;
    }
}

@end
