//
//  ASUser.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadUserPicturesDelegate;


@interface ASUser : NSObject

@property(atomic, retain) NSString *userName;
@property (nonatomic,strong) UIImage *profilePicture;
@property (nonatomic,strong) NSString *profilePicURL;
@property(nonatomic,strong) id <DownloadUserPicturesDelegate> delegate;

@property(nonatomic, retain) NSString *userEmail;
@property (nonatomic,retain) NSString *userPassword;
@property (assign) BOOL registered;

- (id)initWithJSONObject:(NSDictionary *)aJSONObject;
- (NSDictionary *)serializeToDictionary;


@end

@protocol DownloadUserPicturesDelegate

- (void)imageDidLoad:(ASUser *)user;

@end