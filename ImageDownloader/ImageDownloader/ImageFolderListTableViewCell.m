//
//  ImageFolderListTableViewCell.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderListTableViewCell.h"
#import "Masonry.h"

@interface ImageFolderListTableViewCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation ImageFolderListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setupLayouts];
    }
    return self;
}

- (void)setupViews
{
    [self setTitleLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    [self setStatusLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    [self setProgressView:[[UIProgressView alloc] initWithFrame:CGRectZero]];
    
    [self addSubview:[self titleLabel]];
    [self addSubview:[self statusLabel]];
    [self addSubview:[self progressView]];
}

- (void)setupLayouts
{
    [[self titleLabel] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.top.equalTo(self);
    }];
    
    [[self statusLabel] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.top.equalTo([[self titleLabel] mas_bottom]);
    }];
    
    [[self progressView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.top.equalTo([[self statusLabel] mas_bottom]);
        make.height.equalTo(@5);
        make.bottom.equalTo(self);
    }];
}

- (void)configureCellWithTitle: (NSString *)titleString
{
    [[self titleLabel] setText:titleString];
}

- (void)updateStatus: (NSString *)statusString
{
    [[self statusLabel] setText:statusString];
}

- (void)updateProgress: (CGFloat)progress
{
    [[self progressView] setProgress:progress];
}

@end
