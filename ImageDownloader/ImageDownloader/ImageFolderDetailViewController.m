//
//  ImageFolderDetailViewController.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderDetailViewController.h"
#import "ImageFolderDetailCollectionViewCell.h"
#import "Masonry.h"

@interface ImageFolderDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) ImageFolderDetailViewModel *viewModel;
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@end

@implementation ImageFolderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setViewModel:[[ImageFolderDetailViewModel alloc] init]];

    [self setupViews];
    [self setupLayouts];
    [self setupObservers];
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
    
    ImageModel *imageModel = [[[self imageFolderModel] imageModels] objectAtIndex:indexPath.row];
    if (imageModel != nil) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        NSString *folderName = [[[[self imageFolderModel] path] componentsSeparatedByString:@"."] firstObject];
        folderName = [documentPath stringByAppendingPathComponent:folderName];
        NSString *imagePath = [folderName stringByAppendingPathComponent:[imageModel name]];
        
        [cell updateImage:[UIImage imageWithContentsOfFile:imagePath]];
    } else {
        [cell updateImage:nil];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self imageFolderModel] imagesCount];
}

#pragma mark - notifications
- (void)fileProgressNotification: (NSNotification *)notification
{
    
}


@end
