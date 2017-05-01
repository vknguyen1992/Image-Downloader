//
//  ImageDetailViewController.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "Masonry.h"
#import "ImageManager.h"

@interface ImageDetailViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *pageLabel;
@end

@implementation ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self setupLayouts];
}

- (void)setupViews
{
    // swipe left - next image
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    // swipe right - previous image
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    [self setImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [[self imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self imageView] setBackgroundColor:[UIColor grayColor]];
    
    [self setPageLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    [[self pageLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self pageLabel] setTextColor:[UIColor redColor]];
    
    [self reloadImage];
    
    [[self view] addSubview:[self imageView]];
    [[self view] addSubview:[self pageLabel]];
}

- (void)reloadImage
{
    ImageModel *imageModel = [[self imageModels] objectAtIndex:[self imgIndex]];
    UIImage *image = [[ImageManager sharedManager] imageFromImageModel:imageModel andImageFolderModel:[self imageFolderModel]];
    [[self imageView] setImage:image];
    
    NSString *pageString = [NSString stringWithFormat:@"%ld/%lu", (long)[self imgIndex], (unsigned long)[[self imageModels] count]];
    [[self pageLabel] setText:pageString];
}

- (void)setupLayouts
{
    [[self imageView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([self view]);
    }];
    
    [[self pageLabel] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo([self view]);
        make.trailing.equalTo([self view]);
        make.bottom.equalTo([self view]);
    }];
}

- (void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if ([self imgIndex] < ([[self imageModels] count] - 1)) {
        [self setImgIndex:[self imgIndex] + 1];
        [self reloadImage];
    }
}

- (void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if ([self imgIndex] >= 1) {
        [self setImgIndex:[self imgIndex] - 1];
        [self reloadImage];
    }
}

@end
