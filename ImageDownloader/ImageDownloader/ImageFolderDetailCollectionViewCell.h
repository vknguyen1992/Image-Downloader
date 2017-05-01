//
//  ImageFolderDetailCollectionViewCell.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 5/1/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kImageFolderDetailCollectionViewCellIdentifier = @"kImageFolderDetailCollectionViewCellIdentifier";

@interface ImageFolderDetailCollectionViewCell : UICollectionViewCell
- (void)updateImage: (UIImage *)image;
- (void)updateStatus: (NSString *)statusString;
@end
