//
//  ASZBusinessHealthDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/4/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessHealthDataController.h"
#import "ASZBusinessHealthViewController.h"
#import "ASBusiness.h"
#import "ASZRateView.h"
#import "ASZNewRateView.h"
#import "OAuthConsumer.h"
#import <UIKit/UIKit.h>
#import "ASMapPoint.h"
#import "ASGlobal.h"


@interface ASZBusinessHealthDataController ()

@property NSOperationQueue *queue;  // Assume we only need one for now
@property (weak, nonatomic) IBOutlet UITableView *businessTableView;
@property (weak, nonatomic) IBOutlet ASZBusinessHealthViewController *viewController;

- (ASBusiness *)businessFromJSONResultYelp:(NSDictionary *)result;

@end


@implementation ASZBusinessHealthDataController




#pragma mark - Data download
@synthesize business = _business;
@synthesize businessTableView = _businessTableView;
@synthesize viewController = _viewController;

#pragma mark - update the view





- (void)getAdditionalBusinessData
{

    
    NSString *address = [NSString stringWithFormat:@"http://api.yelp.com/v2/business/%@",self.business.ID ];
    NSLog(@"Get additional business info with address %@",address);
    
    
    NSURL *URL = [NSURL URLWithString:address];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY secret:CONSUMER_SECRET] ;
    OAToken *token = [[OAToken alloc] initWithKey:TOKEN secret:TOKEN_SECRET] ;
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;
    
    OAMutableURLRequest *oauthrequest = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                        consumer:consumer
                                                                           token:token
                                                                           realm:realm
                                                               signatureProvider:provider];
    [oauthrequest prepare];
    NSLog(@"%@\n",address);
    
    NSLog(@"%@\n",[oauthrequest URL]);
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSLog(@"%@\n",JSONresponse);
        self.business = [self businessFromJSONResultYelp:JSONresponse];
    };
    
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:oauthrequest queue:self.queue completionHandler:handler];
}



/* Get ADDITIONAL data from Yelp.
   Most of the data (e.g. the name, phone number, etc. is already set)
 */
- (ASBusiness *)businessFromJSONResultYelp:(NSDictionary *)result
{
    if (!self.business)
        return nil;
    
    self.business.reviews = [result objectForKey:@"reviews"];
    return self.business;
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSLog(@"%@\n",self.business.types);

    NSInteger row= indexPath.row;
    switch(indexPath.section)
    {
        case 0:
        {
            
            if (row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];
                
                if(cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DescriptionCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;

                    UITextView *tv = [[UITextView alloc]init];
                    tv.frame = CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height);
                    tv.backgroundColor = [UIColor clearColor];
                    tv.textColor = [UIColor darkGrayColor];
                    tv.userInteractionEnabled = NO;
                    NSMutableString *typeArrayStr = [[NSMutableString alloc] initWithString:@""];
                    for (NSString * d in self.business.types)
                    {
                        [typeArrayStr appendString:d];
                        [typeArrayStr appendString:@", "];
                    }
                    tv.text = typeArrayStr;
                    [cell.contentView addSubview:tv];
                }
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CertificationCell"];
                if(cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CertificationCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.imageView.frame = CGRectMake(5,5,45,45);
                    if(self.business.certLevel == 2)
                    {
                        cell.imageView.image  = [UIImage imageNamed:@"spe-cert.jpg"];
                        cell.textLabel.text = @"SPE Certified";
                        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                    }
                    else if(self.business.certLevel == 1)
                    {
                        cell.imageView.image  = [UIImage imageNamed:@"silver-medal.png"];
                        cell.textLabel.text = @"Self Reported";
                        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                    }
                    else
                    {
                        cell.textLabel.text = @"Health, Nutrition, Allergen Info Not Reported";
                        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

                    }
                    cell.textLabel.adjustsFontSizeToFitWidth = YES;
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                }
            }
            
            break;
            
        }
        case 1:
        {
            if (row == 0)  // the address
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
                }
         
                
            }
            else if (row == 1)   // the map
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
                    
                    MKMapView *mv = [[MKMapView alloc]init];
                    mv.center = CGPointMake(self.business.lat,self.business.lng);
                    MKCoordinateRegion region2 = mv.region;
                    region2.center = CLLocationCoordinate2DMake(self.business.lat, self.business.lng);
                    region2.span.longitudeDelta=0.01;
                    region2.span.latitudeDelta=0.01;
                    mv.region = region2;
                    
                    [mv setScrollEnabled:NO];
                    
                    
                    CGRect frame = CGRectMake(5,5,cell.frame.size.width-30,MAP_HEIGHT-10);
                    [mv setFrame:frame];
                    
                    CLLocationCoordinate2D annotationCoord;
                    annotationCoord.latitude =self.business.lat;
                    annotationCoord.longitude = self.business.lng;
                    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
                    annotationPoint.coordinate = annotationCoord;
                    annotationPoint.title = self.business.name;
                    [mv addAnnotation:annotationPoint];
                    [cell.contentView addSubview:mv];
                }

            }
            else if (row == 2)  //the phone
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneCell"];
                if(!cell)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhoneCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.imageView.image =nil;
                    cell.detailTextLabel.text = nil;
                    cell.textLabel.text = self.business.phone;


                }
                
            }
            else if (row ==3)  // web
            {                
                cell = [tableView dequeueReusableCellWithIdentifier:@"WebCell"];
                if (!cell)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WebCell"];
                    //webButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    
                    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
                    cell.imageView.image =nil;
                    cell.detailTextLabel.text = nil;
                    cell.textLabel.adjustsFontSizeToFitWidth = YES;
                    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.business.website];                
                }
            }
            break;

            
        }
        case 2:
        {
            switch(row)
            {
                case 0:
                {                
                    cell = [tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
                    if(!cell)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ReportCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;
                        cell.imageView.image =nil;
                        cell.detailTextLabel.text = nil;
                        cell.textLabel.text = @"Report a Problem";                    
                    }
                    return cell;
                    break;
                }
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"ModifyCell"];
                    if(!cell)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ModifyCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;
                        cell.imageView.image =nil;
                        cell.detailTextLabel.text = nil;
                        cell.textLabel.text = @"Modify Info";
                    }
                    break;
                }
            }
            break;
        }
        default:
        {
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
    }
    return cell;
    
     
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_INFO_SECTIONS;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.business == nil)
    {
        return 0;
    }

    if (section == 0)
        return 2;
    if (section == 1) //map and addr info
        return 4;
    if (section == 2) //type info
        return 2;

    return 0;
}

@end