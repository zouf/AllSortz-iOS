//
//  ASZEditBusinessDetailsDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/5/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZEditBusinessDetailsDataController.h"
#import "ASZBusinessDetailsDataController.h"
#import "ASZEditBusinessDetailsViewController.h"
#import "ASBusiness.h"
#import "ASURLEncoding.h"

#define BUSINESS_NAME 200
#define BUSINESS_STREET 201
#define BUSINESS_CITY 202
#define BUSINESS_STATE 203
#define BUSINESS_URL 204
#define BUSINESS_PHONE 205
#define BUSINESS_HOURS 206

#define TYPE_LABEL_VIEW 601
#define TYPE_IMAGE_VIEW 600
@interface ASZEditBusinessDetailsDataController ()

@property NSOperationQueue *queue;  // Assume we only need one for now
@property (weak, nonatomic) IBOutlet UITableView *businessTableView;
@property (weak, nonatomic) IBOutlet ASZEditBusinessDetailsViewController *viewController;

- (ASBusiness *)businessFromJSONResult:(NSDictionary *)result;

@end

@implementation ASZEditBusinessDetailsDataController

#pragma mark - Data download
@synthesize businessTableView = _businessTableView;
@synthesize viewController = _viewController;

- (void)refreshBusinessAsynchronouslyWithID:(NSUInteger)ID
{
    if (!(ID && self.username && self.currentLatitude && self.currentLongitude && self.UUID)) {
        self.business = nil;
        return;
    }
       
    NSString * typeAddress = [NSString stringWithFormat:@"http://allsortz.com/api/types/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@",  self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];

    NSURLRequest *typeRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:typeAddress]];
    void (^typeHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        self.allTypes = [JSONresponse objectForKey:@"result"];

    };
    NSLog(@"Get types with query %@",typeAddress);

    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:typeRequest queue:self.queue completionHandler:typeHandler];

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

- (void)editBusinessAsynchronouslyWithID:(NSUInteger)ID
{
    if (!(ID && self.username && self.currentLatitude && self.currentLongitude && self.UUID)) {
        self.business = nil;
        return;
    }
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/business/edit/%lu/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", (unsigned long)ID, self.username, self.password, self.currentLatitude, self.currentLongitude, self.UUID];
    NSString *str = [[self.business serializeToDictionaryWithTypes:self.allTypes] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    NSLog(@"Get details with query %@\n\nPost Data %@",address,data);
   
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
    //    NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data  options:0 error:NULL];
    //    self.business = [self businessFromJSONResult:JSONresponse[@"result"]];
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
    
    for (NSDictionary *category in result[@"categories"]) {
        NSMutableDictionary *topic = [NSMutableDictionary dictionary];
        [topic setValuesForKeysWithDictionary:@{@"ID": [category valueForKeyPath:@"topic.parentID"],
         @"name": [category valueForKeyPath:@"topic.parentName"],
         @"rating": [category valueForKey:@"bustopicRating"],
         @"summary": [category valueForKey:@"bustopicContent"]}];
        
        
        // Don't want a mutable dictionary in there
        [topics addObject:[NSDictionary dictionaryWithDictionary:topic]];
    }
    
    // Sort topics into order they should be displayed
/*    business.topics = [topics sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2) {
        NSString *name1 = [obj1 valueForKey:@"name"];
        NSString *name2 = [obj2 valueForKey:@"name"];
        if ([name1 isEqualToString:name2]) return NSOrderedSame;
        if ([name1 isEqualToString:@"Main"]) return NSOrderedAscending;
        if ([name2 isEqualToString:@"Main"]) return NSOrderedDescending;
        return [name1 localizedCompare:name2];
    }];*/
    
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
    
    
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessData"];
        ;

        if (!self.business)
            return cell;
        ASBusiness *business = self.business;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *nameField = (UITextField*)[cell viewWithTag:BUSINESS_NAME];
        UITextField *streetField = (UITextField*)[cell viewWithTag:BUSINESS_STREET];
        UITextField *cityField = (UITextField*)[cell viewWithTag:BUSINESS_CITY];
        UITextField *urlField = (UITextField*)[cell viewWithTag:BUSINESS_URL];
        UITextField *phoneField = (UITextField*)[cell viewWithTag:BUSINESS_PHONE];
        UITextField *stateField =(UITextField*)[cell viewWithTag:BUSINESS_STATE];
        UITextView *hoursField = (UITextView*)[cell viewWithTag:BUSINESS_HOURS];

        
        nameField.text = business.name;// = nameField.text;
        streetField.text = business.address;
        cityField.text = business.city;
        stateField.text = business.state;
        urlField.text = business.website.path; // = urlField.text;
        phoneField.text = business.phone;//.businessPhone = phoneField.text;
        NSMutableString *hourArray = [NSMutableString stringWithFormat:@""];
        
        for (NSString *str in self.business.hours)
        {
            [hourArray appendString:str];
            [hourArray appendString:@"\n"];
        }
        hoursField.text = hourArray;

        
        return cell;
        
    }
    else if (indexPath.section == 1)
    {        
        NSString *CellIdentifier = @"TypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!self.allTypes)
            return cell;
        UILabel *label =(UILabel *)[cell viewWithTag:TYPE_LABEL_VIEW];
        NSDictionary *dict = [self.allTypes objectAtIndex:indexPath.row];
        
        label.text = [dict objectForKey:@"typeName"];
        
        
        UIImageView *imageView =(UIImageView*)[cell viewWithTag:TYPE_IMAGE_VIEW];
        imageView.image = [UIImage imageNamed: [[self.allTypes objectAtIndex:indexPath.row] objectForKey:@"typeIcon"]];
        imageView.backgroundColor = [UIColor lightGrayColor];
        
        return cell;
 

    }
    return nil;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            // TODO: Show info
            return [self.allTypes count];
            break;
        default:
            return 0;
            break;
    }
}

@end
