//
//  ASZMenuItem.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/9/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZMenuItem.h"

@implementation ASZMenuItem
@synthesize certLevel, certImage, certDate;

- (id)initWithJSON:(NSDictionary*)aJSONobject
{
    if (!(self = [super init]))
        return nil;
    
    self.name = [aJSONobject objectForKey:@"name"];
    self.description = [aJSONobject objectForKey:@"description"];
    self.price = [aJSONobject objectForKey:@"price"];
    self.certLevel = rand() % 3;
    
    if(self.certLevel == 0)
    {
        self.certImage = nil;
    }
    else if(self.certLevel == 1)
    {
        self.certImage = [UIImage imageNamed:@"silver-medal.png"];
        self.certDate  = [NSString stringWithFormat:@"November %d 2012", rand() % 30];

    }
    else if(self.certLevel == 2)
    {
        self.certImage = [UIImage imageNamed:@"spe-cert.jpg"];
        self.certDate  = [NSString stringWithFormat:@"December %d 2012", rand() % 30];
    }
    return self;
}

@end
