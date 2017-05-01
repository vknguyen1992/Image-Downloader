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
#import "ImageFolderDetailViewController.h"

@interface ImageFolderListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ImageFolderListViewModel *viewModel;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UISlider *concurrencySlider;
@end

@implementation ImageFolderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewModel:[[ImageFolderListViewModel alloc] init]];
    
    [[self viewModel] loadFromDataIfNeeded];
    
    [self setupViews];
    [self setupLayouts];
    [self setupObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Reset"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(resetButtonPressed:)];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Add"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(addButtonPressed:)];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:resetButton, addButton, nil];
    
    if ([[self viewModel] didDownloadJson]) {
        [self showPauseResumeButton];
    } else {
        [self hidePauseResumeButton];
    }
}

- (void)showPauseResumeButton
{
    UIBarButtonItem *pauseResumeButton = [[UIBarButtonItem alloc]
                                          initWithTitle:@"Resume"
                                          style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(pauseResumeButtonPressed:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:pauseResumeButton, nil];
    [self setPauseResumeButtonTitle];
}

- (void)hidePauseResumeButton
{
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)setPauseResumeButtonTitle
{
    if (![[self viewModel] isDownloading]) {
        [self.navigationItem.rightBarButtonItems[0] setTitle:@"Resume"];
    } else {
        [self.navigationItem.rightBarButtonItems[0] setTitle:@"Pause"];
    }
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
    [[self mainTableView] setDelegate:self];
    [[self mainTableView] setDataSource:self];
    
    [self setConcurrencySlider:[[UISlider alloc] initWithFrame:CGRectZero]];
    [[self concurrencySlider] addTarget:self action:@selector(concurrentcySliderChange:) forControlEvents:UIControlEventValueChanged];
    
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
        make.top.equalTo([self view]);
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
    [cell updateProgress:[imageFolderModel progress]];
    
    [cell updateStatus:[[self viewModel] stateStringFromFolderModel:imageFolderModel]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageFolderModel *imageFolderModel = [[[self viewModel] imageFolders] objectAtIndex:[indexPath row]];
    ImageFolderDetailViewController *vc = [[ImageFolderDetailViewController alloc] init];
    [vc setImageFolderModel:imageFolderModel];
    [[self navigationController] pushViewController:vc animated:YES];
}

#pragma mark - notifications
- (void)folderProgressNotification: (NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo != nil) {
        ImageFolderModel *folderModel = [userInfo objectForKey:kNotificationFolderProgressModelKey];
        NSNumber *progress = [userInfo objectForKey:kNotificationFolderProgressProgressKey];
        
        NSNumber *row = [[self viewModel] rowForImageFolderModel:folderModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row.integerValue inSection:0];
        ImageFolderListTableViewCell *cell = [[self mainTableView] cellForRowAtIndexPath:indexPath];
        
        [cell updateProgress:progress.floatValue];
        [cell updateStatus:[[self viewModel] stateStringFromFolderModel:folderModel]];
        
    }
}

- (void)fileProgressNotification: (NSNotification *)notification
{
    
}

- (void)doneDownloadAndUnzipImageFolderNotification: (NSNotification *)notification
{
    [[self concurrencySlider] setMinimumValue:1];
    [[self concurrencySlider] setMaximumValue:[[[self viewModel] imageFolders] count]];
    [[self concurrencySlider] setValue:1];
    [[self mainTableView] reloadData];
    
    if ([[self viewModel] didDownloadJson]) {
        [self showPauseResumeButton];
    } else {
        [self hidePauseResumeButton];
    }
}

#pragma mark - events
- (void)concurrentcySliderChange: (UISlider *)slider
{
    NSInteger newStep = (NSInteger)[slider value];
//    [slider setValue:newStep];
    [[self viewModel] updateConcurrencyCount:newStep];
}

- (void)resetButtonPressed:(id)sender
{
    [[self viewModel] reset];
    [[self mainTableView] reloadData];
    [self hidePauseResumeButton];
}

- (void)addButtonPressed:(id)sender
{
    [[self viewModel] startDownloadImagesWithConcurrencyCount:[[self concurrencySlider] value]];
    
    [[self viewModel] setIsDownloading:YES];
    [self setPauseResumeButtonTitle];
}

- (void)pauseResumeButtonPressed:(id)sender
{
    if ([[self viewModel] isDownloading]) {
        [[self viewModel] setIsDownloading:NO];
        [[self viewModel] pause];
        [self setPauseResumeButtonTitle];
    } else {
        [[self viewModel] setIsDownloading:YES];
        [[self viewModel] startDownloadImagesWithConcurrencyCount:[[self concurrencySlider] value]];
        [self setPauseResumeButtonTitle];
    }
}

@end
