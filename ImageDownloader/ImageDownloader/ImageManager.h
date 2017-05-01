//
//  ImageDownloadManager.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageFolderModel.h"
#import "ImageModel.h"

static NSString * const kNotificationFolderProgress = @"kNotificationFolderProgress";
static NSString * const kNotificationFolderProgressModelKey = @"kNotificationFolderProgressModelKey";
static NSString * const kNotificationFolderProgressProgressKey = @"kNotificationFolderProgressProgressKey";

static NSString * const kNotificationFileProgress = @"kNotificationFileProgress";
static NSString * const kNotificationFileProgressModelKey = @"kNotificationFileProgressModelKey";
static NSString * const kNotificationFileProgressProgressKey = @"kNotificationFileProgressProgressKey";

static NSString * const kNotificationDoneDownloadAndUnzipImageFolder = @"kNotificationDoneDownloadAndUnzipImageFolder";

@interface ImageManager : NSObject
+ (id)sharedManager;

@property (readonly, nonatomic, strong) NSArray *imageFolderModels;

@property (readonly, nonatomic, strong) dispatch_queue_t backgroundQueue;

- (UIImage *)imageFromImageModel: (ImageModel *)imageModel andImageFolderModel: (ImageFolderModel *)imageFolderModel;

- (void)downloadImageJsonFolder;
- (NSArray *)getJsonFilesList;
- (void)downloadAllImageFolderWithConcurrencyNumber: (NSInteger)concurrencyCount onCompletion: (void (^)(void))completionBlock;
- (void)stopDownloading;
- (void)updateConcurrencyCount: (NSInteger)concurrencyCount;

- (void)loadDataFromDb;

- (BOOL)getDidDownloadJson;
- (void)setDidDownloadJson: (BOOL)didDownloadJson;

- (void)reset;
@end
