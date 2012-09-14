//
//  ASZBusinessDetailsDataController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessDetailsDataController.h"
#import "ASZTopicDetailViewController.h"
#import "ASZBusinessDetailsViewController.h"
#import "ASBusiness.h"

#define BUSINESSIMAGEVIEW_TAG 1000
#define BUSINESSNAMELABEL_TAG 1001
#define BUSINESSHEALTH_TAG 1002
#define BUSINESSTYPES_TAG 1003
#define BUSINESSPHONE_TAG 1004
#define BUSINESSURL_TAG 1005
#define BUSINESSADDRESS_TAG 1006
#define BUSINESSSCORE_TAG 1007
#define BUSINESSDIST_TAG 1008




#define TOPICNAMELABEL_TAG 1010
#define TOPICTEXTVIEW_TAG 1012
#define TOPICRATINGVIEW_TAG 1013
#define TOPICRATINGSLIDER_TAG 1014
#define TOPICRATINGSEGMENTED_TAG 1015
#define TOPICAVGRATINGSLABEL_TAG 1016


@interface ASZBusinessDetailsDataController ()

@property NSOperationQueue *queue;  // Assume we only need one for now
@property (weak, nonatomic) IBOutlet UITableView *businessTableView;
@property (weak, nonatomic) IBOutlet ASZBusinessDetailsViewController *viewController;

- (ASBusiness *)businessFromJSONResult:(NSDictionary *)result;

@end


@implementation ASZBusinessDetailsDataController

#pragma mark - Data download
@synthesize businessTableView = _businessTableView;
@synthesize viewController = _viewController;


-(UIImage*) getImageForGrade:(NSString *)healthGrade
{
    NSString *imageName;
    if ([healthGrade isEqualToString:@"A"])
    {
        imageName = @"NYCRestaurant_A.gif";
    }
    else if([healthGrade isEqualToString:@"B"])
    {
        imageName = @"NYCRestaurant_B.gif";
    }
    else if ([healthGrade isEqualToString:@"C"])
    {
        imageName = @"NYCRestaurant_C.gif";
        
    }
    else if ([healthGrade isEqualToString:@"Z"])
    {
        imageName = @"NYCRestaurant_GP.gif";
    }
    else
    {
        imageName = @"NYCRestaurant_GP.gif";
    }
    return [UIImage imageNamed:imageName];
}

-(void)rateBusinessTopicAsynchronously:(NSUInteger)btID withRating:(NSInteger)rating
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/business/topic/rate/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&rating=%d", (unsigned long)btID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID,rating];
    NSLog(@"Get details with query %@",address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        //NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
       // self.business = [self businessFromJSONResult:JSONresponse[@"result"]];
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];

}

- (void)refreshBusinessAsynchronouslyWithID:(NSUInteger)ID
{
    if (!(ID && self.username && self.currentLatitude && self.currentLongitude && self.UUID)) {
        self.business = nil;
        return;
    }

    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/business/%lu?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)ID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSLog(@"Rate businesstopic with address %@",address);
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
    business.zipcode = result[@"zipcode"];
    
    business.distance = result[@"distanceFromCurrentUser"];
    business.hours = [result[@"businessHours"] componentsSeparatedByString:@", "];
    business.name = result[@"businessName"];
    business.phone = result[@"businessPhone"];
    business.website = [NSURL URLWithString:result[@"businessURL"]];

    business.recommendation = [result[@"ratingRecommendation"] floatValue];
        

    NSMutableArray *topics = [NSMutableArray arrayWithCapacity:[result[@"categories"] count]];
    
    NSDictionary *hinfo = result[@"health_info"];
    business.healthGrade = [hinfo valueForKey:@"health_grade"];
    business.healthViolationText = [hinfo valueForKey:@"health_violation_text"];
    
    
    
    NSMutableArray *types = [NSMutableArray arrayWithCapacity:[result[@"types"] count]];
    for (NSDictionary *t in result[@"types"])
    {
        NSMutableDictionary *type = [NSMutableDictionary dictionary];
        
        NSLog(@"%@\n",t);
        NSLog(@"%@\n", [t valueForKeyPath:@"type.typeID"]);
        NSLog(@"%@\n", [t valueForKeyPath:@"type.typeName"]);
        NSLog(@"%@\n", [t valueForKeyPath:@"type.typeIcon"]);
        [type setValue:[t valueForKeyPath:@"type.typeID"] forKey:@"ID"];
        [type setValue:[t valueForKeyPath:@"type.typeName"] forKey:@"name"];
        [type setValue:[t valueForKeyPath:@"type.typeIcon"] forKey:@"icon"];
        [types addObject:[NSDictionary dictionaryWithDictionary:type]];
        
    }
    business.types = types;
    
    for (NSDictionary *category in result[@"categories"]) {
        NSMutableDictionary *topic = [NSMutableDictionary dictionary];
        NSLog(@"%@\n",topic);

        [topic setValuesForKeysWithDictionary:@{@"ID": [category valueForKeyPath:@"topic.parentID"],
                                                @"name": [category valueForKeyPath:@"topic.parentName"],
                                                @"rating": [category valueForKey:@"bustopicRating"],
                                                @"summary": [category valueForKey:@"bustopicContent"],
         @"avgRating" : [category valueForKey:@"bustopicAvgRating"],
         @"ratingAdjective" : [ category valueForKey:@"bustopicRatingAdjective"],
         @"bustopicID": [category valueForKey:@"bustopicID"]}];
        
        
        
        if ([[topic valueForKey:@"name"] isEqualToString:@"Main"])
        {
            [topic setValue:@"Synopsis" forKeyPath:@"name"];
        }
        // Don't want a mutable dictionary in there
        [topics addObject:[NSDictionary dictionaryWithDictionary:topic]];
    }

    
    // Sort topics into order they should be displayed
    business.topics = [topics sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2) {
        NSString *name1 = [obj1 valueForKey:@"name"];
        NSString *name2 = [obj2 valueForKey:@"name"];
        if ([name1 isEqualToString:name2]) return NSOrderedSame;
        if ([name1 isEqualToString:@"Synopsis"]) return NSOrderedAscending;
        if ([name2 isEqualToString:@"Synopsis"]) return NSOrderedDescending;
        return [name1 localizedCompare:name2];
    }];

    // Fetch image asynchronously
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:result[@"photoLargeURL"]]];
    void (^imageHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        business.image = [UIImage imageWithData:data];
    };
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:imageRequest queue:self.queue completionHandler:imageHandler];

    return business;
}


#pragma mark - Table view data source

- (void)singleTap:(UITapGestureRecognizer *)tap
{
    CGPoint currentTouchPosition = [tap locationInView:self.businessTableView];
    NSIndexPath *indexPath = [self.businessTableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath.section == 2)
    {
        id bus  = self.business;
        id topics = [bus valueForKey:@"topics"];
        
        NSArray *topicsArray = (NSArray*)topics;
        id topic = topicsArray[indexPath.row];
        NSInteger topicID = [[topic valueForKey:@"ID"] integerValue];
        
        
        NSString *targetViewControllerIdentifier = nil;
        targetViewControllerIdentifier = @"TopicDetailViewControllerID";

        ASZTopicDetailViewController *vc = (ASZTopicDetailViewController*)[self.viewController.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
        
        
        
        ASZTopicDetailDataController *topicDetailsController = vc.dataController;
        ASZBusinessDetailsDataController *businessDetailsController = self;
        topicDetailsController.username = businessDetailsController.username;
        topicDetailsController.password = businessDetailsController.password;
        topicDetailsController.UUID = businessDetailsController.UUID;
        topicDetailsController.currentLatitude = businessDetailsController.currentLatitude;
        topicDetailsController.currentLongitude = businessDetailsController.currentLongitude;
        
        topicDetailsController.topic = [[ASZTopic alloc] initWithID:topicID];
        topicDetailsController.topic.name = [topic valueForKey:@"name"];

        topicDetailsController.topic.summary = [topic valueForKey:@"summary"];
        topicDetailsController.topic.rating = [[topic valueForKey:@"rating"] floatValue];
        
        
        [self.viewController.navigationController  pushViewController:vc animated:YES];
        
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    switch (indexPath.section) {
        case ASZBusinessDetailsHeaderSection:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessDetailsHeaderCell"];
        {
            if (!self.business)
                [cell setHidden:YES];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            UILabel *name = (UILabel *)[cell.contentView viewWithTag:BUSINESSNAMELABEL_TAG];
            name.text = self.business.name;
            
            UITextView *types = (UITextView*)[cell.contentView viewWithTag:BUSINESSTYPES_TAG];
            NSMutableString *typeArrayStr = [[NSMutableString alloc] initWithString:@""];
            
            for (NSDictionary *d in self.business.types)
            {
                [typeArrayStr appendString:[d valueForKey:@"name"]];
                [typeArrayStr appendString:@"\n"];
            }
            types.text = [NSString stringWithString:typeArrayStr];
            
            
            UIButton *url = (UIButton *)[cell.contentView viewWithTag:BUSINESSURL_TAG];
            [url setTitle:self.business.website.path forState:UIControlStateNormal];
            if (!self.business.website.path || [self.business.website.path isEqualToString:@""] )
            {
                [url setTitle:@"Tell us" forState:UIControlStateNormal];
                [url addTarget:self.viewController
                            action:@selector(editTapped:)
                  forControlEvents:(UIControlEvents)UIControlEventTouchDown];                           
            }
            else
            {
                [url setTitle:self.business.website.path forState:UIControlStateNormal];
   
            }
            
            UIButton *phone = (UIButton *)[cell.contentView viewWithTag:BUSINESSPHONE_TAG];
            if (!self.business.phone || [self.business.phone isEqualToString:@""])
            {
                [phone setTitle:@"Tell us" forState:UIControlStateNormal];
                [phone addTarget:self.viewController
                        action:@selector(editTapped:)
              forControlEvents:(UIControlEvents)UIControlEventTouchDown];
            }
            else
            {
                [phone setTitle:self.business.phone forState:UIControlStateNormal];
            }
            
            UIButton *healthGradeButton = (UIButton*)[cell.contentView viewWithTag:BUSINESSHEALTH_TAG];

            [healthGradeButton setImage:[self getImageForGrade:self.business.healthGrade] forState:UIControlStateNormal];
            [healthGradeButton setBackgroundColor:[UIColor lightGrayColor]];
            
            
            UIProgressView* score = (UIProgressView*)[cell.contentView viewWithTag:BUSINESSSCORE_TAG];
            score.progress = self.business.recommendation;
            
            UILabel *distance = (UILabel*)[cell.contentView viewWithTag:BUSINESSDIST_TAG];
            distance.text = [NSString stringWithFormat:@"%0.2fmi.",[self.business.distance floatValue]];
            
            UIButton *address = (UIButton*)[cell.contentView viewWithTag:BUSINESSADDRESS_TAG];
            address.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
            address.titleLabel.textAlignment = UITextAlignmentCenter;
            [address setTitle:[NSString stringWithFormat:@"%@\n%@, %@ %@\n",self.business.address,self.business.city,self.business.state,self.business.zipcode] forState:UIControlStateNormal];

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
            
           /* UIProgressView *ratingView = (UIProgressView*)[cell.contentView viewWithTag:TOPICRATINGVIEW_TAG];
            ratingView.progress = [[topic valueForKey:@"rating"] floatValue];
            
            UISlider *sliderView = (UISlider*)[cell.contentView viewWithTag:TOPICRATINGSLIDER_TAG];
            sliderView.value = [[topic valueForKey:@"rating"] floatValue];*/
            
            UISegmentedControl *rateSelector = (UISegmentedControl*)[cell.contentView viewWithTag:TOPICRATINGSEGMENTED_TAG];
            UIFont *font = [UIFont fontWithName:@"Gill Sans" size:12];
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                   forKey:UITextAttributeFont];
            [rateSelector setTitleTextAttributes:attributes
                                            forState:UIControlStateNormal];
            CGRect r = rateSelector.frame;
            r.size.height = 25.0;
            [rateSelector setFrame:r];
            
            if ([[topic valueForKey:@"rating"] intValue] == 0)
            {
                [rateSelector setSelectedSegmentIndex:0];
            }
            else if  ([[topic valueForKey:@"rating"] intValue] == 1)
            {
                [rateSelector setSelectedSegmentIndex:1];
            }
            else
            {
                 [rateSelector setSelectedSegmentIndex:0];
            }
            
            
            UILabel *avgRatingLabel = (UILabel*)[cell viewWithTag:TOPICAVGRATINGSLABEL_TAG];
            
            NSLog(@"%@\n",[topic valueForKey:@"avgRating"]);
            avgRatingLabel.text = [NSString stringWithFormat:@"%@",[topic valueForKey:@"ratingAdjective"]  ];
            
            
            UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            singleTap.cancelsTouchesInView = NO;
            [topicSummary addGestureRecognizer:singleTap];

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
