///
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
#import "ASZCommentList.h"

#import <UIKit/UIKit.h>
#import "ASMapPoint.h"


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

-(void)rateBusinessTopicAsynchronously:(NSUInteger)btID withRating:(CGFloat)rating
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/business/topic/rate/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&rating=%.2f", (unsigned long)btID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID,rating];
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

-(void)rateCommentAsynchronously:(NSUInteger)cID withRating:(NSInteger)rating
{
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/comment/rate/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@&rating=%d", (unsigned long)cID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID,rating];
    NSLog(@"Rate a comment from within the review tab with query %@",address);
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

- (ASZCommentList *)commentListFromJSONResult:(NSDictionary *)result
{
    ASZCommentList *reviewList = [[ASZCommentList alloc] initWithID:self.business.ID];
    if (!reviewList)
        return nil;
    
    
    reviewList.comments = [NSArray arrayWithArray:result[@"reviews"]];
    
    return reviewList;
    
}

- (void)getAllReviews:(NSUInteger)busID
{
    //get a base review for the business with ID
    // need a list of topics (and maybe what topics are already assoc. with busines)
    // might include text you've already written
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/business/reviews/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)busID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSLog(@"Get all the reviews for this business with query %@",address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        self.reviewList = [self commentListFromJSONResult:JSONresponse[@"result"]];
        
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
    
    return;
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

    
    business.lat = [result[@"latitude"] floatValue];
    business.lng = [result[@"longitude"] floatValue];

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
         @"rating":[NSNumber numberWithFloat:[[category valueForKey:@"bustopicRating"] floatValue]],
                                                @"summary": [category valueForKey:@"bustopicContent"],
         @"avgRating":[NSNumber numberWithFloat:[[category valueForKey:@"bustopicAvgRating"] floatValue]],
         @"ratingAdjective" : [ category valueForKey:@"bustopicRatingAdjective"],
         @"bustopicID": [category valueForKey:@"bustopicID"]}];
        
        
        //TODO should be on server, not client
        if ([[topic valueForKey:@"name"] isEqualToString:@"Main"])
        {
            [topic setValue:@"Overall" forKeyPath:@"name"];
        }
        // Don't want a mutable dictionary in there
        [topics addObject:topic];
    }

    
    // Sort topics into order they should be displayed
    business.topics = topics;


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
    
    CGPoint currentTouchPosition = [tap locationInView:self.viewController.tableView ];
    NSIndexPath *indexPath = [self.viewController.tableView indexPathForRowAtPoint: currentTouchPosition];

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
        {
            NSMutableString *typeArrayStr = [[NSMutableString alloc] initWithString:@""];
            for (NSDictionary *d in self.business.types)
            {
                [typeArrayStr appendString:[d valueForKey:@"name"]];
                [typeArrayStr appendString:@"\n"];
            }
            NSInteger row= indexPath.row;
            switch(indexPath.section)
            {
                case PHONE_WEBSITE_SECTION:
                {
                    if (row == PHONE_ROW)
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneCell"];
                        if (cell == nil) {
                            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhoneCell"];
                            cell.selectionStyle = UITableViewCellSelectionStyleGray;
                        }
                        
                        cell.imageView.image =nil;
                        cell.detailTextLabel.text = nil;
                        cell.textLabel.text = nil;
                        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,PHONE_WEBSITE_HEIGHT)];
                        [phoneLabel setTextAlignment:NSTextAlignmentCenter];
                        [phoneLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:14]];
                        [phoneLabel setText:self.business.phone];
                        [phoneLabel setBackgroundColor:[UIColor clearColor]];
                        
                        /*
                        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.viewController action:@selector(callBusinessTap:)];
                        singleTap.numberOfTapsRequired = 1;
                        singleTap.numberOfTouchesRequired = 1;
                        singleTap.cancelsTouchesInView = NO;
                        [cell.contentView  addGestureRecognizer:singleTap];*/
   
                        [cell.contentView addSubview:phoneLabel];
                    }
                    else // row == 1
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"WebsiteCell"];
                        if (cell == nil) {
                            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WebsiteCell"];
                            cell.selectionStyle = UITableViewCellSelectionStyleGray;
                        }
                        
                        cell.imageView.image =nil;
                        cell.detailTextLabel.text = nil;
                        cell.textLabel.text = nil;
                        UILabel *websiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width-20,PHONE_WEBSITE_HEIGHT)];
                        [websiteLabel setTextAlignment:NSTextAlignmentCenter];
                        [websiteLabel setFont:[UIFont fontWithName:@"GillSans-Light" size:14]];
                        [websiteLabel setText:self.business.website.path];
                        [websiteLabel setBackgroundColor:[UIColor clearColor]];
                        [cell.contentView addSubview:websiteLabel];
                        
                        /*
                        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.viewController action:@selector(goToWebsiteTap:)];
                        singleTap.numberOfTapsRequired = 1;
                        singleTap.numberOfTouchesRequired = 1;
                        singleTap.cancelsTouchesInView = NO;
                        [cell.contentView  addGestureRecognizer:singleTap];
                        */
                        
                    }
                    
                }
                    break;
                case ADDRESS_MAP_SECTION:
                {
                    
                    if (row == ADDRESS_ROW)
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
                        if (cell == nil) {
                            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
                            cell.selectionStyle = UITableViewCellSelectionStyleGray;

                            //override detail detailtextlabel behavior
                            [cell.detailTextLabel setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
                            
                            [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
                            [cell.detailTextLabel setTextAlignment:NSTextAlignmentCenter];
                            
                            cell.imageView.image = nil;
                            cell.textLabel.text = nil;
                            
                            
                            
                            UILabel *smallAddressComponent = [[UILabel alloc]initWithFrame:CGRectMake(25,25,250,20)];
                            [smallAddressComponent setFont:[UIFont fontWithName:@"Gill Sans" size:10]];
                            [smallAddressComponent setTextColor:[UIColor darkTextColor]];
                            [smallAddressComponent setTextAlignment:NSTextAlignmentCenter];
                            [smallAddressComponent setBackgroundColor:[UIColor clearColor]];
                            
                            UILabel *largeAddressComponent = [[UILabel alloc]initWithFrame:CGRectMake(25,5,250,25)];
                            [largeAddressComponent setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
                            [largeAddressComponent setTextColor:[UIColor darkTextColor]];
                            [largeAddressComponent setTextAlignment:NSTextAlignmentCenter];
                            [largeAddressComponent setBackgroundColor:[UIColor clearColor]];
                            
                            [smallAddressComponent setText:[NSString stringWithFormat:@"%@, %@ %@\n", self.business.city, self.business.state, self.business.zipcode]];
                            
                            [largeAddressComponent setText:[NSString stringWithFormat:@"%@\n", self.business.address]];
                            [cell addSubview:largeAddressComponent];
                            [cell addSubview:smallAddressComponent];
                            
                            /*
                            UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.viewController action:@selector(getDirectionsToTap:)];
                            singleTap.numberOfTapsRequired = 1;
                            singleTap.numberOfTouchesRequired = 1;
                            singleTap.cancelsTouchesInView = NO;
                            [cell.contentView  addGestureRecognizer:singleTap];*/
                        }
                        
                    }
                    else if(row==MAP_ROW)
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"MapCell"];
                        if (cell == nil) {
                            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MapCell"];
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                            //override detail detailtextlabel behavior
                            [cell.detailTextLabel setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
                            [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
                            [cell.detailTextLabel setTextAlignment:NSTextAlignmentCenter];
                     
                            cell.imageView.image = nil;
                            cell.textLabel.text = nil;
                    
                            self.viewController.mapView.center = CGPointMake(self.business.lat,self.business.lng);
                            MKCoordinateRegion region2 = self.viewController.mapView.region;
                            region2.center = CLLocationCoordinate2DMake(self.business.lat, self.business.lng);
                            region2.span.longitudeDelta=0.01;
                            region2.span.latitudeDelta=0.01;
                            self.viewController.mapView.region = region2;
                            
                            [self.viewController.mapView setScrollEnabled:NO];
                            
                            
                            
                            [self.viewController.mapView setFrame:CGRectMake(10, 5, cell.frame.size.width-20 ,MAP_HEIGHT-15)];
                            
                            CLLocationCoordinate2D annotationCoord;
                            annotationCoord.latitude =self.business.lat;
                            annotationCoord.longitude = self.business.lng;                        
                            MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
                            annotationPoint.coordinate = annotationCoord;
                            annotationPoint.title = self.business.name;
                            [self.viewController.mapView addAnnotation:annotationPoint];
                            [cell addSubview:self.viewController.mapView];
                        }
                    }
                    else
                    {
                        assert(@"Incorrect number of rows");
                    }
                }
                    break;
                case TYPE_SECTION:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessTypeInfo"];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BusinessTypeInfo"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        //override detail detailtextlabel behavior
                        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
                        [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
                        [cell.detailTextLabel setTextAlignment:NSTextAlignmentCenter];
                    
                        cell.imageView.image = nil;
                        cell.textLabel.text = nil;
                        if(row == 0)
                        {
                            cell.detailTextLabel.text = typeArrayStr;
                        }
                    }
                }
                    break;
                    
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DefaultCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        //override detail detailtextlabel behavior
                        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
                        [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
                        [cell.detailTextLabel setTextAlignment:NSTextAlignmentCenter];
                    }
                    cell.imageView.image = nil;
                    cell.textLabel.text = nil;
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
            //UISegmentedControl *rateSelector;
            UILabel *avgRatingLabel;

            UIButton *upButton;
            UIButton *downButton;
            ASZRateView *rv1;
            ASZRateView *rv2;

            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BusinessDetailsTopicCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
                CGFloat textSummaryBeginX = 85;
        
                CGFloat buffer = 5;
                
                CGFloat offset_right = 35;
                CGFloat kLabelWidth = 64; //EFFECTS THE LAYOUT. HARD TO GET RIGHT.
                CGFloat kLabelY = 26; //EFFECTS THE LAYOUT. HARD TO GET RIGHT.
                CGFloat kLabelHeight = 16; //EFFECTS THE LAYOUT. HARD TO GET RIGHT.
                CGFloat kLabel0X = -24 + offset_right; //EFFECTS THE LAYOUT. HARD TO GET RIGHT.
                CGFloat kLabel1X =-10 + offset_right; //EFFECTS THE LAYOUT. HARD TO GET RIGHT.

                
                CGFloat kArroyHeight = 12;
                CGFloat kArroyWidth  = 12;
                CGFloat kArrow0Y = buffer;
                CGFloat kArrow1Y = kArrow0Y + kArroyHeight +buffer;
                CGFloat kArrowX = 2;
                
                CGFloat kRatingHeight = 10;
                CGFloat kRatingWidth  = 30;
                CGFloat kRatingY = 18;
                CGFloat kRating0X = -buffer;
                CGFloat kRating1X = kRating0X+8;
                
                upButton = [UIButton buttonWithType:UIButtonTypeCustom];
                upButton.userInteractionEnabled = YES;
                upButton.tag = TOPICUPBUTTON_TAG;
                [upButton setImage:[UIImage imageNamed:@"upvote-export.png"] forState:UIControlStateNormal];
                [upButton setFrame:CGRectMake(kArrowX, kArrow0Y, kArroyWidth,kArroyHeight)];
                [cell.contentView addSubview:upButton];
                
                downButton = [UIButton buttonWithType:UIButtonTypeCustom];
                downButton.userInteractionEnabled = YES;
                downButton.tag = TOPICDOWNBUTTON_TAG;
                [downButton setImage:[UIImage imageNamed:@"downvote-export.png"] forState:UIControlStateNormal];
                [downButton setFrame:CGRectMake(kArrowX, kArrow1Y, kArroyWidth,kArroyHeight)];
                [cell.contentView addSubview:downButton];
                
                
                // 
                avgRatingLabel = [[UILabel alloc]initWithFrame:CGRectMake(kLabel0X,kLabelY,kLabelWidth,kLabelHeight)];
                avgRatingLabel.tag = TOPICAVGRATINGSLABEL_TAG;
                avgRatingLabel.font = [UIFont fontWithName:@"Gill Sans"  size:10];
                avgRatingLabel.textAlignment = NSTextAlignmentRight;
                avgRatingLabel.textColor = [UIColor darkGrayColor];
                avgRatingLabel.transform = CGAffineTransformMakeRotation(270 * M_PI / 180.0);

                [cell.contentView addSubview:avgRatingLabel];
                
                topicName = [[UILabel alloc]initWithFrame:CGRectMake(kLabel1X,kLabelY,kLabelWidth,kLabelHeight)];
                topicName.tag = TOPICNAMELABEL_TAG;
                topicName.font = [UIFont fontWithName:@"Gill Sans"  size:10];
                topicName.textAlignment = NSTextAlignmentRight;
                topicName.textColor = [UIColor lightGrayColor];
                topicName.transform = CGAffineTransformMakeRotation(270 * M_PI / 180.0);
                [cell.contentView addSubview:topicName];
                
                UIView *lineView0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textSummaryBeginX-15, 1)];
                [lineView0 setBackgroundColor:[UIColor lightGrayColor]];
                [cell.contentView addSubview:lineView0];
                
                
                
                /*UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, kLabelWidth, kLabelHeight*2+offset_right, 1)];
                [lineView1 setBackgroundColor:[UIColor lightGrayColor]];
                [cell.contentView addSubview:lineView1];
                */
                rv1 =  [[ASZRateView alloc]initWithFrame:CGRectMake(kRating0X,kRatingY,kRatingWidth,kRatingHeight)];
                rv1.notSelectedImage = [UIImage imageNamed:@"empty-circle.png"];                
                rv1.halfSelectedImage = [UIImage imageNamed:@"half-circle.png"];
                rv1.fullSelectedImage = [UIImage imageNamed:@"full-circle.png"];
                rv1.editable = NO;
                rv1.maxRating = 4;
                rv1.transform = CGAffineTransformMakeRotation(270 * M_PI / 180.0);
                rv1.tag = TOPICAVG_RATING;
                
                
                rv2 =  [[ASZRateView alloc]initWithFrame:CGRectMake(kRating1X,kRatingY,kRatingWidth,kRatingHeight)];
                rv2.notSelectedImage = [UIImage imageNamed:@"empty-circle.png"];
                rv2.halfSelectedImage = [UIImage imageNamed:@"half-circle.png"];
                rv2.fullSelectedImage = [UIImage imageNamed:@"full-circle.png"];
                rv2.editable = NO;
                rv2.maxRating = 4;
                rv2.transform = CGAffineTransformMakeRotation(270 * M_PI / 180.0);
                rv2.tag = TOPICUSER_RATING;
                
                [cell.contentView addSubview:rv1];
                [cell.contentView addSubview:rv2];

                topicSummary = [[UITextView alloc] initWithFrame:CGRectMake(textSummaryBeginX, 0, CELL_WIDTH, 68)];
                topicSummary.tag = TOPICTEXTVIEW_TAG;
                topicSummary.font = [UIFont fontWithName:@"GillSans-Light"  size:10];
                topicSummary.textAlignment = NSTextAlignmentLeft;
            
                topicSummary.textColor = [UIColor darkGrayColor];
                topicSummary.scrollEnabled = NO;
                topicSummary.editable = NO;
                topicSummary.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
                topicSummary.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0);

             //   topicSummary.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [cell.contentView addSubview:topicSummary];
                                                      
                [cell.contentView addSubview:upButton];
                [cell.contentView addSubview:downButton];


                
            }
            else
            {
                topicName = (UILabel*)[cell.contentView viewWithTag:TOPICNAMELABEL_TAG];
                topicSummary = (UITextView*)[cell.contentView viewWithTag:TOPICTEXTVIEW_TAG];
                upButton = (UIButton*)[cell.contentView viewWithTag:TOPICUPBUTTON_TAG];
                downButton = (UIButton*)[cell.contentView viewWithTag:TOPICDOWNBUTTON_TAG];
                rv1 = (ASZRateView*)[cell.contentView viewWithTag:TOPICAVG_RATING];
                rv2 = (ASZRateView*)[cell.contentView viewWithTag:TOPICUSER_RATING];

                
                avgRatingLabel = (UILabel*)[cell viewWithTag:TOPICAVGRATINGSLABEL_TAG];

            }
            id topic = self.business.topics[indexPath.row];
            topicName.text = [topic valueForKey:@"name"];
            topicSummary.text = [topic valueForKey:@"summary"];
            
            NSLog(@"TOPIC %@\n",topic);
            NSLog(@"RATING %f\n", [[topic valueForKey:@"avgRating"] floatValue]*4);
            [rv1 setRating:[[topic valueForKey:@"avgRating"] floatValue]*MAX_RATING];
            [rv2 setRating:[[topic valueForKey:@"rating"] floatValue]*MAX_RATING];
            /*
            NSLog(@"Rating is %@\n", [topic valueForKey:@"rating"]);
            if ([[topic valueForKey:@"rating"] intValue] == 0)
            {
                [upButton setSelectedSegmentIndex:0];
            }
            else if  ([[topic valueForKey:@"rating"] intValue] == 1)
            {
                [rateSelector setSelectedSegmentIndex:1];
            }
            else
            {
                rateSelector.selectedSegmentIndex = -1;
            }*/
            avgRatingLabel.text = [NSString stringWithFormat:@"%@",[topic valueForKey:@"ratingAdjective"]  ];
            
            topicSummary.backgroundColor = [UIColor clearColor];
            topicName.backgroundColor = [UIColor clearColor];
            [avgRatingLabel setBackgroundColor:[UIColor clearColor]];

            
            [upButton addTarget:self.viewController action:@selector(busTopicPosRateTap:) forControlEvents:UIControlEventTouchUpInside];
            [downButton addTarget:self.viewController action:@selector(busTopicNegRateTap:) forControlEvents:UIControlEventTouchUpInside];

            UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            singleTap.cancelsTouchesInView = NO;
            
            [topicSummary addGestureRecognizer:singleTap];
            return cell;
        }
            break;
        case REVIEW_TAB:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];

        {

            UILabel * authorLabel;
            UILabel * dateLabel ;
            UITextView * commentContent;
            UISegmentedControl * rateSelector;
            UILabel * posRatingLabel;
            UILabel * negRatingLabel;

            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ReviewCell"];
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
            id review = [self.reviewList.comments objectAtIndex:indexPath.row];
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

            return cell;
        }
            break;
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
            if (section == 1) //map and addr info
                return 2;
            if (section == 2) //type info
                return 1;
                
        }
            break;
        case REDEEM_TAB:  //redeem
        {
            return 0;
        }
            break;
        case DISCUSSION_TAB:
        {
            return [self.business.topics count];
        }
            break;
        case REVIEW_TAB:
        {
            return [self.reviewList.comments count];
        }
            break;
        default:
            return 0;
            break;
    }
    return 0;
}

@end
