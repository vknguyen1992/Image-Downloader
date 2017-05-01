//
//  ImageFolderDetailViewModel.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderDetailViewModel.h"

@implementation ImageFolderDetailViewModel
- (NSNumber *)rowForImageModel: (ImageModel *)imageModel
{
    RLMArray<ImageModel *><ImageModel> *imageModels = [[self imageFolderModel] imageModels];

    for (int i = 0; i < imageModels.count; i++) {
        ImageModel *currentImageModel = [imageModels objectAtIndex:i];
        if (currentImageModel != nil) {
            if ([currentImageModel.url isEqualToString:imageModel.url]) {
                return @(i);
            }
        }
    }
    return nil;
}

@end
