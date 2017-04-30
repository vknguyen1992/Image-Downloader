//
//  ImageFolderListViewModel.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderListViewModel.h"

@implementation ImageFolderListViewModel
- (NSArray *)imageFolders
{
    return [[ImageManager sharedManager] imageFolderModels];
}

- (void)startDownloadImagesWithConcurrencyCount: (NSInteger)concurrencyCount;
{
    dispatch_async([[ImageManager sharedManager] backgroundQueue], ^{
        [self setConcurrencyCount:concurrencyCount];
        
        [[ImageManager sharedManager] downloadImageJsonFolder];
        [[ImageManager sharedManager] getJsonFilesList];
        [[ImageManager sharedManager] downloadAllImageFolderWithConcurrencyNumber:[self concurrencyCount] onCompletion:^{
            //
        }];
    });
}

- (NSNumber *)rowForImageFolderModel: (ImageFolderModel *)imageFolderModel
{
    NSArray *imageFolders = [[self imageFolders] copy];
    for (int i = 0; i < imageFolders.count; i++) {
        ImageFolderModel *imageFolder = [imageFolders objectAtIndex:i];
        if (imageFolder != nil) {
            if ([imageFolderModel.path isEqualToString:imageFolder.path]) {
                return @(i);
            }
        }
    }
    return nil;
}

- (void)updateConcurrencyCount: (NSInteger)concurrencyCount;
{
    [[ImageManager sharedManager] updateConcurrencyCount:concurrencyCount];
}

@end
