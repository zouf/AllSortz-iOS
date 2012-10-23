//
//  ASSocialDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASUserProfileDataController.h"
#import "ASURLEncoding.h"
@interface ASUserProfileDataController ()

@property (strong, readwrite) ASUser *userProfile;
@property NSOperationQueue *queue;  // Assume we only need one for now

@property (strong) NSMutableData *receivedData;
@property(strong, atomic) CLLocation * currentLocation;
@property (strong, nonatomic) ASDeviceInterface *deviceInterface;

@end

@implementation ASUserProfileDataController


NSLock *lock;
BOOL updated;
- (id)init {
    self = [super init];
    if (self) {
        lock = [[NSLock alloc]init];
        updated = NO;
        
        self.deviceInterface = [[ASDeviceInterface alloc] init];
        [self.deviceInterface.locationManager startUpdatingLocation];
        self.deviceInterface.delegate = self;
        
        
    }
    return self;
}

- (BOOL)updateData
{

    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/user/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@",  [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],
        self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.deviceInterface getDeviceUIUD]];
    

    NSLog(@"Get user profile data with %@\n",address);
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    self.receivedData = [NSMutableData data];
    
    return YES;
    
    
}

-(BOOL)uploadProfilePic:(UIImage *)imageToPost
{
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/user/update/picture/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@",  [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],
                         self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.deviceInterface getDeviceUIUD]];

    
    
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file ";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:address];
    
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(imageToPost, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        //NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        // self.business = [self businessFromJSONResult:JSONresponse[@"
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userProfile.profilePicture = [UIImage imageWithData:data];
        });
    };
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];

    
    return YES;
}

- (BOOL)updateUserData
{


    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/user/update/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@",  [self.deviceInterface getStoredUname], [self.deviceInterface getStoredPassword],
        self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,[self.deviceInterface getDeviceUIUD]];
    
    
    NSLog(@"Updating the user with %@\n",address);
    [self.deviceInterface storeUname:self.userProfile.userName password:self.userProfile.userPassword];

    NSString *str = [[self.userProfile serializeToDictionary] urlEncodedString];
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [self postRequestWithAddress:address data:data];
    
    
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (!connection) {
        // TODO: Some proper failure handling maybe
        return NO;
    }
    NSLog(@"Running update data in user profile\n");
    self.receivedData = [NSMutableData data];
    
    return YES;
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


#pragma mark - Connection data delegate

// TODO: Handle server problems and non-200 responses

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Reset data store on new requests
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // TODO: Actual error handling
    self.receivedData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:self.receivedData
                                                                        options:0
                                         
                                                                          error:NULL];
    NSLog(@"%@\n",JSONresponse);
    self.userProfile = [[ASUser alloc] initWithJSONObject:[JSONresponse objectForKey:@"result"]];
    self.receivedData = nil;


    
}

#pragma mark - Receive Location info
- (void)locationUpdate:(CLLocation *)location
{
    self.currentLocation = [location copy];
}

- (void)locationError:(NSError *)error
{
    
}






@end
