//
//  ImageFolderDetailCollectionViewCell.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 5/1/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderDetailCollectionViewCell.h"
#import "Masonry.h"

@interface ImageFolderDetailCollectionViewCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation ImageFolderDetailCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupLayouts];
    }
    return self;
}

- (void)setupViews
{
    [self setBackgroundColor:[UIColor grayColor]];
    
    [self setImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self setStatusLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    
    [self addSubview:[self imageView]];
    [self addSubview:[self statusLabel]];
}

- (void)setupLayouts
{
    [[self imageView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [[self statusLabel] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

- (void)updateImage: (UIImage *)image
{
    [[self imageView] setImage:image];
}

- (void)updateStatus: (NSString *)statusString
{
    [[self statusLabel] setText:statusString];
}

@end
