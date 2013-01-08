//
//  ASBusinessList.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessList.h"
#import "ASRateView.h"
#import "ASBusiness.h"
#import "ASGlobal.h"

#import <MapKit/MapKit.h>


#define NUM_STATIC_CELLS 0



#define kAppIconHeight 72


@implementation ASIconDownloader

#pragma mark

- (void)dealloc
{
    
    [_imageConnection cancel];
    
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    
    
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:self.listing.imageURLString]] delegate:self];
    //NSLog(@"%@\n",self.listing.imageURLString);
    self.imageConnection = conn;
    
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    /*  if (image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
     {
     CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
     UIGraphicsBeginImageContext(itemSize);
     
     CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
     [image drawInRect:imageRect];
     
     self.listing.businessPhoto = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     }
     else*/
    {
        self.listing.image= image;
    }
    
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    [self.delegate imageDidLoad:self.indexPathInTableView];
}

@end


@interface ASBusinessList ()

@property (strong) NSArray *businesses;

@end


@implementation ASBusinessList

- (id)initWithJSONObjectYelp:(NSDictionary *)aJSONObject :(CLLocation*)currentLocation
{
    if (!(self = [super init]) )
        return nil;
    NSLog(@"%@\n",aJSONObject);
    _businesses = [aJSONObject objectForKey:@"businesses"];
    _entries = [[NSMutableArray alloc]init];

    for(NSDictionary * dict in _businesses)
    {
        //NSString *businessName = [dict objectForKey:@"businesName"];
        ASBusiness *listing = [[ASBusiness alloc] initWithJSONYelp:dict];
        CLLocation *locationA = [[CLLocation alloc] initWithLatitude:listing.lat longitude:listing.lng];
        
        CLLocationDistance distanceInMeters = [currentLocation distanceFromLocation:locationA];
        listing.distance = [NSNumber numberWithFloat:distanceInMeters/1000];
        [_entries addObject:listing];
    }

    return self;
    
}

- (id)initWithJSONObject:(NSDictionary *)aJSONObject
{
    if (!(self = [super init]) || ![[aJSONObject objectForKey:@"success"] boolValue])
        return nil;
    NSDictionary *serverBusList = [aJSONObject objectForKey:@"result"];
    _businesses = [serverBusList objectForKey:@"businesses"];
    _entries = [[NSMutableArray alloc]init];
    if ([[aJSONObject valueForKey:@"requestType"]isEqualToString:@"new_address"])
    {
        self.newAddress = YES;
    }
    else
    {
        self.newAddress = NO;
    }
    
    self.searchText = [serverBusList valueForKey:@"searchString"];
    for(NSDictionary * dict in _businesses)
    {
        //NSString *businessName = [dict objectForKey:@"businesName"];  
        id listingID = [dict valueForKey:@"businessID"] ;
        ASBusiness *listing = [[ASBusiness alloc] initWithID:listingID];

        
        listing.name = [dict valueForKey:@"businessName"];
        listing.avgPrice = [dict valueForKey:@"averagePrice"];
        listing.imageURLString = [dict valueForKey:@"photoMedURL"];
        listing.types = [dict valueForKey:@"types"];
        listing.distance = [dict valueForKey:@"distanceFromCurrentUser"];
        listing.recommendation = [[dict valueForKey:@"ratingRecommendation"] floatValue];
        //listing. = [[dict valueForKey:@"ratingForCurrentUser"] floatValue];
        listing.lat =  [[dict valueForKey:@"latitude"] floatValue];
        listing.lng =  [[dict valueForKey:@"longitude"] floatValue];
        
        if([dict objectForKey:@"starred"])
        {
            listing.starred = YES;
        }
        else
        {
            listing.starred = NO;
        }
            
        [_entries addObject:listing];
    }
    
    return self;
}

#pragma mark - Key-value coding

- (NSUInteger)countOfBusinesses
{
    return [self.businesses count];
}

- (id)objectInBusinessesAtIndex:(NSUInteger)index
{
    return [self.businesses objectAtIndex:index];
}

- (NSArray *)businessesAtIndexes:(NSIndexSet *)indexes
{
    return [self.businesses objectsAtIndexes:indexes];
}

- (void)getBusinesses:(id __unsafe_unretained *)buffer range:(NSRange)inRange
{
    [self.businesses getObjects:buffer range:inRange];
}


#pragma mark - Table data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count] + NUM_STATIC_CELLS;
}




@end
