//
//  ASPhotoGalleryGridViewCell.m
//  AllSortz
//
//  Created by Connie Wan on 8/1/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASPhotoGalleryGridViewCell.h"


@interface ASPhotoGalleryGridViewCell ()

@property (strong) UIImageView *imageView;

@end


@implementation ASPhotoGalleryGridViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_imageView];
    }
    
    return self;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize imageSize = self.imageView.image.size;
    CGRect frame = self.imageView.frame;
    CGRect bounds = self.contentView.bounds;

    if ((imageSize.width <= bounds.size.width) && (imageSize.height <= bounds.size.height))
    {
        return;
    }

    // scale it down to fit
    CGFloat hRatio = bounds.size.width / imageSize.width;
    CGFloat vRatio = bounds.size.height / imageSize.height;
    CGFloat ratio = MIN(hRatio, vRatio);

    frame.size.width = floorf(imageSize.width * ratio);
    frame.size.height = floorf(imageSize.height * ratio);
    frame.origin.x = floorf((bounds.size.width - frame.size.width) * 0.5);
    frame.origin.y = floorf((bounds.size.height - frame.size.height) * 0.5);
    self.imageView.frame = frame;
}

@end
