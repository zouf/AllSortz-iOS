//
//  ASZBusinessDetailsDataController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessDetailsDataController.h"
#import "ASZTopicDetailViewController.h"
#import "ASZBusinessDetailsBaseViewController.h"
#import "ASBusiness.h"
#import "ASZBusinessTopicViewController.h"
#import "ASZBusinessTopicDataController.h"
#import "ASZRateView.h"



@interface ASZBusinessDetailsDataController ()

@property NSOperationQueue *queue;  // Assume we only need one for now
@property (weak, nonatomic) IBOutlet UITableView *businessTableView;
@property (weak, nonatomic) IBOutlet ASZBusinessDetailsBaseViewController *viewController;

- (ASBusiness *)businessFromJSONResult:(NSDictionary *)result;

@end


@implementation ASZBusinessDetailsDataController

#pragma mark - Data download
@synthesize businessTableView = _businessTableView;
@synthesize viewController = _viewController;

#pragma mark - update the view 



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
    NSString *address = [NSString stringWithFormat:@"http://192.168.1.100/api/business/topic/rate/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&rating=%d", (unsigned long)btID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID,rating];
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

    NSString *address = [NSString stringWithFormat:@"http://192.168.1.100/api/business/%lu?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)ID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
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
        [type setValue:[t valueForKeyPath:@"type.typeID"] forKey:@"ID"];
        [type setValue:[t valueForKeyPath:@"type.typeName"] forKey:@"name"];
        [type setValue:[t valueForKeyPath:@"type.typeIcon"] forKey:@"icon"];
        [types addObject:[NSDictionary dictionaryWithDictionary:type]];
        
    }
    business.types = types;
    
    for (NSDictionary *category in result[@"categories"]) {
        NSMutableDictionary *topic = [NSMutableDictionary dictionary];

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

        
    // Fetch image asynchronously if the image has some content
    if (![result[@"photoLargeURL"] isEqualToString:@"https://s3.amazonaws.com/allsortz/icon.png"])
    {
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:result[@"photoLargeURL"]]];
        void (^imageHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
            business.image = [UIImage imageWithData:data];
        };
        
        if (!self.queue)
            self.queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:imageRequest queue:self.queue completionHandler:imageHandler];
    }
    return business;
}


#pragma mark - Table view data source

- (void)singleTap:(UITapGestureRecognizer *)tap
{
    CGPoint currentTouchPosition = [tap locationInView:self.businessTableView];
    NSIndexPath *indexPath = [self.businessTableView indexPathForRowAtPoint: currentTouchPosition];

        id bus  = self.business;
        id topics = [bus valueForKey:@"topics"];
        
        NSArray *topicsArray = (NSArray*)topics;
        id topic = topicsArray[indexPath.row];
        NSInteger topicID = [[topic valueForKey:@"bustopicID"] integerValue];
        
        NSString *targetViewControllerIdentifier = nil;
        targetViewControllerIdentifier = @"BusinessTopicViewControllerID";

        ASZBusinessTopicViewController *vc = (ASZBusinessTopicViewController*)[self.viewController.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
        
        [vc setBusiness:self.business];
        [vc setBusinessTopicName:[topic valueForKey:@"name"]];
        self.viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.business.name style:UIBarButtonItemStylePlain target:nil action:nil] ;
        ASZBusinessTopicDataController *topicDetailsController = vc.dataController;
        ASZBusinessDetailsDataController *businessDetailsController = self;
        topicDetailsController.username = businessDetailsController.username;
        topicDetailsController.password = businessDetailsController.password;
        topicDetailsController.UUID = businessDetailsController.UUID;
        topicDetailsController.currentLatitude = businessDetailsController.currentLatitude;
        topicDetailsController.currentLongitude = businessDetailsController.currentLongitude;
        [vc setBusinessTopicID:topicID];
        [self.viewController.navigationController  pushViewController:vc animated:YES];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    switch (self.viewController.segmentedController.selectedSegmentIndex) {
        case INFO_TAB:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessDetailsHeaderCell"];
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BusinessDetailsHeaderCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            NSMutableString *typeArrayStr = [[NSMutableString alloc] initWithString:@""];
            
            for (NSDictionary *d in self.business.types)
            {
                [typeArrayStr appendString:[d valueForKey:@"name"]];
                [typeArrayStr appendString:@"\n"];
            }
            

            NSInteger row= indexPath.row;
            cell.imageView.image = nil;
            cell.textLabel.text = nil;
            
            
            //override detail detailtextlabel behavior
            [cell.detailTextLabel setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
            [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
            [cell.detailTextLabel setTextAlignment:UITextAlignmentCenter];

            switch(indexPath.section)
            {
                case 0:
                {
                    if (row == 0)
                    {
                        cell.detailTextLabel.text = self.business.phone;
                        [cell.detailTextLabel setTextAlignment:UITextAlignmentCenter];
                        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Gill Sans" size:18]];
                    }
                    else // row == 1
                    {
                        cell.detailTextLabel.text = self.business.website.path;
                        [cell.detailTextLabel setTextAlignment:UITextAlignmentCenter];
                        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Gill Sans" size:18]];


                    }
                }
                    break;
                case 1:
                {
                    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@\n%@, %@ %@\n",self.business.address,self.business.city,self.business.state,self.business.zipcode];
                }
                    break;
                case 2:
                {
                    
                    if(row == 0)
                    {
                        cell.detailTextLabel.text = typeArrayStr;
                    }
                    else //row ==1
                    {
                        cell.detailTextLabel.text = self.business.healthGrade;
                        cell.imageView.image = [self getImageForGrade:self.business.healthGrade];
                    }
                }
                    break;
                default:
                    cell.textLabel.text = @"Blank info";
                    break;
            }

            
            return cell;

        }
            return cell;
        case REDEEM_TAB:
            cell = [tableView dequeueReusableCellWithIdentifier:@"RedeemCell"];
        {
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RedeemCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.textLabel.text = @"Rewards and Deals";
            
        }
            return cell;
        case DISCUSSION_TAB:
            cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessDetailsTopicCell"];
        {
            UITextView * topicSummary;
            UILabel * topicName;
            UISegmentedControl *rateSelector;
            UILabel *avgRatingLabel;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BusinessDetailsTopicCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
                topicName = [[UILabel alloc]initWithFrame:CGRectMake(6,0,82.0,26.0)];
                topicName.tag = TOPICNAMELABEL_TAG;
                topicName.font = [UIFont fontWithName:@"Gill Sans"  size:14];
                topicName.textAlignment = UITextAlignmentRight;
                topicName.textColor = [UIColor darkGrayColor];
                topicName.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [cell.contentView addSubview:topicName];
                
                
                
              
                topicSummary = [[UITextView alloc] initWithFrame:CGRectMake(100, 0, 215, 68)];
                topicSummary.tag = TOPICTEXTVIEW_TAG;
                topicSummary.font = [UIFont fontWithName:@"GillSans-Light"  size:10];
                topicSummary.textAlignment = UITextAlignmentRight;
                topicSummary.textColor = [UIColor darkGrayColor];
                topicSummary.scrollEnabled = NO;
                //topicSummary.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [cell.contentView addSubview:topicSummary];
                                       
                UIFont *font = [UIFont fontWithName:@"Gill Sans" size:12];
                NSArray *itemArray = [NSArray arrayWithObjects: @"Down", @"Up", nil];
                rateSelector = [[UISegmentedControl alloc] initWithItems:itemArray];
                rateSelector.tag = TOPICRATINGSEGMENTED_TAG;
                rateSelector.frame = CGRectMake(11, 39, 72  , 25);
                rateSelector.segmentedControlStyle = UISegmentedControlStyleBar;
                rateSelector.selectedSegmentIndex = 1;

                NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                       forKey:UITextAttributeFont];
                [rateSelector setTitleTextAttributes:attributes
                                                forState:UIControlStateNormal];
          
                
                [cell.contentView addSubview:rateSelector];

                avgRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(6,14,82.0,26.0)];
                avgRatingLabel.tag = TOPICAVGRATINGSLABEL_TAG;
                avgRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
                avgRatingLabel.textAlignment = UITextAlignmentCenter;
                avgRatingLabel.textColor = [UIColor darkGrayColor];
                topicSummary.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [cell.contentView addSubview:avgRatingLabel];
                
            }
            else
            {
                topicName = (UILabel*)[cell.contentView viewWithTag:TOPICNAMELABEL_TAG];
                topicSummary = (UITextView*)[cell.contentView viewWithTag:TOPICTEXTVIEW_TAG];
                rateSelector = (UISegmentedControl*)[cell.contentView viewWithTag:TOPICRATINGSEGMENTED_TAG];
                avgRatingLabel = (UILabel*)[cell viewWithTag:TOPICAVGRATINGSLABEL_TAG];

            }
            id topic = self.business.topics[indexPath.row];
            topicName.text = [topic valueForKey:@"name"];
            topicSummary.text = [topic valueForKey:@"summary"];
            NSLog(@"Yo %@\n", topic);

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
            avgRatingLabel.text = [NSString stringWithFormat:@"%@",[topic valueForKey:@"ratingAdjective"]  ];
            
            topicSummary.backgroundColor = [UIColor clearColor];
            topicName.backgroundColor = [UIColor clearColor];
            avgRatingLabel.backgroundColor = [UIColor clearColor];

            
            [rateSelector addTarget:self.viewController action:@selector(busTopicRateTap:) forControlEvents:UIControlEventAllEvents];
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
    switch(self.viewController.segmentedController.selectedSegmentIndex)
    {
        case DISCUSSION_TAB:
            return 1;
            break;
        case REDEEM_TAB:
            return 1;
            break;
        case REVIEW_TAB:
            return 1;
            break;
        case INFO_TAB:
            return NUM_INFO_SECTIONS;
            break;
        default:
            return 1;
            break;
            
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.viewController.segmentedController.selectedSegmentIndex) {
        case INFO_TAB:
        {
            if (section == 0)
                return 2;
            if (section == 1)
                return 1;
            if (section == 2)
                return 2;
                
            break;
        }
        case REDEEM_TAB:  //redeem
            return 0;
            break;
        case DISCUSSION_TAB:
            return [self.business.topics count];
            break;
        case REVIEW_TAB:
            return 0;
            break;
        default:
            return 0;
            break;
    }
}

@end
