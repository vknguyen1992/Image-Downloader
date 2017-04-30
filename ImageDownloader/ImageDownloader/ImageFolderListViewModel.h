//
//  ImageFolderListViewModel.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageManager.h"
#import "ImageFolderModel.h"

@interface ImageFolderListViewModel : NSObject
@property (nonatomic, assign) NSInteger concurrencyCount;

- (NSArray *)imageFolders;
- (void)startDownloadImagesWithConcurrencyCount: (NSInteger)concurrencyCount;
- (NSNumber *)rowForImageFolderModel: (ImageFolderModel *)imageFolderModel;
- (void)updateConcurrencyCount: (NSInteger)concurrencyCount;
@end
