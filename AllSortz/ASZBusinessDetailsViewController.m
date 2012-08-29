//
//  ASZBusinessDetailsViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusiness.h"
#import "ASZBusinessDetailsViewController.h"


@interface ASZBusinessDetailsViewController ()
@property NSOperationQueue *queue;   // Assuming we only need one
@end


@implementation ASZBusinessDetailsViewController

#pragma mark - View controller

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Download business info

    static NSString *endpoint = @"http://allsortz.com/api/business/";
    NSString *address = [endpoint stringByAppendingFormat:@"%lu", (unsigned long)self.businessID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (!JSONresponse || ![JSONresponse[@"success"] boolValue]) {
            self.business = nil;
            return;
        }
        self.business = [self businessFromJSONResult:JSONresponse[@"result"]];
        // TODO: Refresh table here
    };

    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
}

- (ASBusiness *)businessFromJSONResult:(NSDictionary *)result
{
    ASBusiness *business = [[ASBusiness alloc] initWithID:[result[@"businessID"] unsignedIntegerValue]];

    business.address = result[@"streetAddr"];
    business.city = result[@"businessCity"];
    business.state = result[@"businessState"];

    business.hours = [result[@"businessHours"] componentsSeparatedByString:@", "];
    business.name = result[@"businessName"];
    business.phone = result[@"businessPhone"];
    business.website = [NSURL URLWithString:result[@"businessURL"]];

    // Fetch image asynchronously
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:result[@"photoURL"]]];
    void (^imageHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        business.image = data ? [UIImage imageWithData:data] : nil;
    };
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:imageRequest queue:self.queue completionHandler:imageHandler];

    return business;
}

@end
