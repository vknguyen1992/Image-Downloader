//
//  ImageFolderListTableViewCell.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kImageFolderListTableViewCellIdentifier = @"kImageFolderListTableViewCellIdentifier";

@interface ImageFolderListTableViewCell : UITableViewCell
- (void)configureCellWithTitle: (NSString *)titleString;
- (void)updateStatus: (NSString *)statusString;
- (void)updateProgress: (CGFloat)progress;
@end
