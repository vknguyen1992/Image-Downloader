//
//  ImageDetailViewController.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "Masonry.h"

@interface ImageDetailViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@end

@implementation ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self setupLayouts];
}

- (void)setupViews
{
    [self setImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [[self imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self imageView] setBackgroundColor:[UIColor grayColor]];
    [[self imageView] setImage:[self image]];
    
    [[self view] addSubview:[self imageView]];
}

- (void)setupLayouts
{
    [[self imageView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([self view]);
    }];
}

- (void)updateImage: (UIImage *)image
{
    [self setImage:image];
    [[self imageView] setImage:image];
}

@end
