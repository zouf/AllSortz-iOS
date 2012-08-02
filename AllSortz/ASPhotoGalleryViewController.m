//
//  ASPhotoGalleryViewController.m
//  AllSortz
//
//  Created by Connie Wan on 8/1/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASPhotoGalleryViewController.h"
#import "ASPhotoGalleryGridViewCell.h"


@interface ASPhotoGalleryViewController ()

@property (strong) NSArray *imageNames;

@end


@implementation ASPhotoGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *allImageNames = [NSBundle pathsForResourcesOfType:@"png" inDirectory:[[NSBundle mainBundle] bundlePath]];
    self.imageNames = [NSMutableArray arrayWithCapacity:[allImageNames count]];
    [allImageNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(NSString *)obj lastPathComponent] hasPrefix:@"photo"])
            [(NSMutableArray *)self.imageNames addObject:obj];
    }];

    [self.gridView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.gridView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView
{
    return [self.imageNames count];
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    ASPhotoGalleryGridViewCell *cell = (ASPhotoGalleryGridViewCell *)[gridView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil)
    {
        cell = [[ASPhotoGalleryGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 200.0, 150.0) reuseIdentifier:@"reuseIdentifier"];
    }

//    cell.image = [UIImage imageNamed: [self.imageNames objectAtIndex: index]];
    cell.image = [UIImage imageWithContentsOfFile:[self.imageNames objectAtIndex:index]];

    return cell;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView
{
    return CGSizeMake(128.0, 128.0);
}

@end
