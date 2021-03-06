//
//  ImageFolderDetailViewModel.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageManager.h"
#import "ImageFolderModel.h"

@interface ImageFolderDetailViewModel : NSObject
@property (nonatomic, strong) ImageFolderModel *imageFolderModel;

- (NSNumber *)rowForImageModel: (ImageModel *)imageModel;
- (NSString *)stateStringFromFolderModel: (ImageDownloadState)imageModelstate progress: (float)progress;
@end
