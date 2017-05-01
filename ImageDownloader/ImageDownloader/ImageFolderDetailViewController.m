//
//  ImageFolderDetailViewController.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderDetailViewController.h"
#import "ImageFolderDetailCollectionViewCell.h"
#import "ImageDetailViewController.h"
#import "Masonry.h"

@interface ImageFolderDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) ImageFolderDetailViewModel *viewModel;
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@end

@implementation ImageFolderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setViewModel:[[ImageFolderDetailViewModel alloc] init]];
    [[self viewModel] setImageFolderModel:[self imageFolderModel]];

    [self setupViews];
    [self setupLayouts];
    [self setupObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationItem] setTitle:[[self imageFolderModel] name]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileProgressNotification:) name:kNotificationFileProgress object:nil];
}

- (void)setupViews
{
    [[self view] setBackgroundColor:[UIColor grayColor]];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellWidth = screenWidth / 3 - 2*4;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
    
    [self setMainCollectionView:[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout]];
    [[self mainCollectionView] registerClass:[ImageFolderDetailCollectionViewCell class] forCellWithReuseIdentifier:kImageFolderDetailCollectionViewCellIdentifier];
    [[self mainCollectionView] setDelegate:self];
    [[self mainCollectionView] setDataSource:self];
    
    [[self view] addSubview:[self mainCollectionView]];
}

- (void)setupLayouts
{
    [[self mainCollectionView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo([self view]);
        make.trailing.equalTo([self view]);
        make.top.equalTo([self view]);
        make.bottom.equalTo([self view]);
    }];
}

#pragma mark collection view delegates
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageFolderDetailCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageFolderDetailCollectionViewCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row < [[[self imageFolderModel] imageModels] count]) {
        ImageModel *imageModel = [[[self imageFolderModel] imageModels] objectAtIndex:indexPath.row];
        if (imageModel != nil) {
            UIImage *image = [[ImageManager sharedManager] imageFromImageModel:imageModel andImageFolderModel:[self imageFolderModel]];
            [cell updateImage:image];
        } else {
            [cell updateImage:nil];
        }
        
        NSString *statusString = [[self viewModel] stateStringFromFolderModel:[imageModel state] progress:[imageModel progress]];
        [cell updateStatus:statusString];
    } else {
        [cell updateImage:nil];

        NSString *statusString = [[self viewModel] stateStringFromFolderModel:ImageDownloadStateQueueing progress:0];
        [cell updateStatus:statusString];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] init];
    
    if (indexPath.row < [[[self imageFolderModel] imageModels] count]) {
        [vc setImageFolderModel:[self imageFolderModel]];
        [vc setImageModels:[[self imageFolderModel] getImageModelsArray]];
        [vc setImgIndex:indexPath.row];
    }
    
    [[self navigationController] pushViewController:vc animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger imagesCount = [[self imageFolderModel] imagesCount];
    if (imagesCount == 0) {
        imagesCount = [[[self imageFolderModel] imageModels] count];
    }
    return imagesCount;
}

#pragma mark - notifications
- (void)fileProgressNotification: (NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo != nil) {
        ImageModel *imageModel = [userInfo objectForKey:kNotificationFileProgressModelKey];
        NSNumber *progress = [userInfo objectForKey:kNotificationFileProgressProgressKey];
        
        NSNumber *row = [[self viewModel] rowForImageModel:imageModel];
        if (row == nil) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row.integerValue inSection:0];
        ImageFolderDetailCollectionViewCell *cell = (ImageFolderDetailCollectionViewCell *)[[self mainCollectionView] cellForItemAtIndexPath:indexPath];
        
//        [[self mainCollectionView] reloadItemsAtIndexPaths:@[indexPath]];
        
        NSString *statusString = [[self viewModel] stateStringFromFolderModel:[imageModel state] progress:[imageModel progress]];
        [cell updateStatus:statusString];
        
        if (progress.floatValue >= 1) {
            UIImage *image = [[ImageManager sharedManager] imageFromImageModel:imageModel andImageFolderModel:[self imageFolderModel]];
            [cell updateImage:image];
            
            NSString *statusString = [[self viewModel] stateStringFromFolderModel:ImageDownloadStateFinished progress:0];
            [cell updateStatus:statusString];
        }
    }
}


@end
