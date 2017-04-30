//
//  ImageFolderListViewController.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderListViewController.h"
#import "Masonry.h"
#import "ImageFolderListViewModel.h"
#import "ImageFolderModel.h"
#import "ImageFolderListTableViewCell.h"

@interface ImageFolderListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ImageFolderListViewModel *viewModel;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UISlider *concurrencySlider;
@end

@implementation ImageFolderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewModel:[[ImageFolderListViewModel alloc] init]];
    
    [self setupViews];
    [self setupLayouts];
    [self setupObservers];
    
    [[self viewModel] startDownloadImagesWithConcurrencyCount:1];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(folderProgressNotification:) name:kNotificationFolderProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileProgressNotification:) name:kNotificationFileProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneDownloadAndUnzipImageFolderNotification:) name:kNotificationDoneDownloadAndUnzipImageFolder object:nil];
}

- (void)setupViews
{
    [self setMainTableView:[[UITableView alloc] initWithFrame:CGRectZero]];
    [[self mainTableView] registerClass:[ImageFolderListTableViewCell class] forCellReuseIdentifier:kImageFolderListTableViewCellIdentifier];
    
    [self setConcurrencySlider:[[UISlider alloc] initWithFrame:CGRectZero]];
    
    [[self view] addSubview:[self mainTableView]];
    [[self view] addSubview:[self concurrencySlider]];
}

- (void)setupLayouts
{
    [[self concurrencySlider] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo([self view]);
        make.trailing.equalTo([self view]);
        make.bottom.equalTo([self view]);
        make.height.equalTo(@44);
    }];
    
    [[self mainTableView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo([self view]);
        make.trailing.equalTo([self view]);
        make.bottom.equalTo([self view]);
        make.bottom.equalTo([[self concurrencySlider] mas_top]);
    }];
}

#pragma mark - tableview delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self viewModel] imageFolders] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageFolderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kImageFolderListTableViewCellIdentifier forIndexPath:indexPath];
    
    ImageFolderModel *imageFolderModel = [[[self viewModel] imageFolders] objectAtIndex:[indexPath row]];
    [cell configureCellWithTitle:[imageFolderModel name]];
    return cell;
}

#pragma mark - notifications
- (void)folderProgressNotification: (NSNotification *)notification
{
//    ImageFolderListTableViewCell *cell = [self mainTableView] cellForRowAtIndexPath:<#(nonnull NSIndexPath *)#>
}

- (void)fileProgressNotification: (NSNotification *)notification
{
    
}

- (void)doneDownloadAndUnzipImageFolderNotification: (NSNotification *)notification
{
    // update concurrentySlide max value after download and unzip json folder
    [[self concurrencySlider] setMinimumValueImage:0];
    [[self concurrencySlider] setMaximumValue:[[[self viewModel] imageFolders] count]];
}

@end
