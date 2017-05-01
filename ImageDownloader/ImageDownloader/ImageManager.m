//
//  ImageDownloadManager.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageManager.h"
#import "SSZipArchive.h"
#import "ImageFolderModel.h"
#import "ImageModel.h"
#import "ImageOperationQueue.h"
#import "ImageFolderOperation.h"

static NSString * const kUserDefaultsDidDownloadJson = @"kUserDefaultsDidDownloadJson";

static NSString * const kDownloadFileFolder = @"Downloaded";
static NSString * const kImagesJsonZipFileName = @"imagesJsonFiles.zip";
static NSString * const kImagesJsonFolderName = @"JSON files updated";
static NSString * const kImagesJsonDownloadUrl = @"https://storage.googleapis.com/nabstudio/Developer/iOS/Interview/Image%20Downloader/JSON%20files%20updated.zip";

@interface ImageManager()
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;
@property (nonatomic, strong) ImageOperationQueue *imageFolderDownloadQueue;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSArray *imageFolderModels;
@end

@implementation ImageManager
    
+ (id)sharedManager {
    static ImageManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager setBackgroundQueue:dispatch_get_global_queue(0,0)];
        [sharedManager setImageFolderDownloadQueue:[[ImageOperationQueue alloc] init]];
        [sharedManager loadDataFromDb];
    });
    return sharedManager;
}

- (NSString *)downloadFileFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *dataPath = [path stringByAppendingPathComponent:kDownloadFileFolder];
    return dataPath;
}

- (NSString *)zipFilePath
{
    NSString *path = [self downloadFileFolderPath];
    
    NSString *dataPath = [path stringByAppendingPathComponent:kImagesJsonZipFileName];
    dataPath = [dataPath stringByStandardizingPath];
    return dataPath;
}

- (NSString *)jsonFolderPath
{
    NSString *path = [self downloadFileFolderPath];
    NSString *jsonFilePath = [path stringByAppendingPathComponent:kImagesJsonFolderName];
    return jsonFilePath;
}

- (BOOL)downloadImageListJsonZipFile
{
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[self downloadFileFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSLog(@"Beginning download");
    NSString *stringURL = kImagesJsonDownloadUrl;
    NSURL *url = [NSURL URLWithString:stringURL];
    
    NSData *urlData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    if (error != nil) {
        return NO;
    }
    
    //Save the data
    NSLog(@"Saving");
    NSString *dataPath = [self zipFilePath];

    [urlData writeToFile:dataPath options:NSDataWritingAtomic error:&error];
    if (error != nil) {
        return NO;
    }
    return YES;
}
    
- (void)decompressImageJsonZipFile
{
    [SSZipArchive unzipFileAtPath:[self zipFilePath] toDestination:[self downloadFileFolderPath]];
}

- (BOOL)getDidDownloadJson
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDidDownloadJson];
}

- (void)setDidDownloadJson: (BOOL)didDownloadJson
{
    [[NSUserDefaults standardUserDefaults] setBool:didDownloadJson forKey:kUserDefaultsDidDownloadJson];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)downloadImageJsonFolder
{
    BOOL isSuccessful = [self downloadImageListJsonZipFile];
    [self decompressImageJsonZipFile];
    [self setDidDownloadJson:isSuccessful];
}

// Get array of ImageFolderModel
- (NSArray *)getJsonFilesList
{
    NSString *sourcePath = [self jsonFolderPath];
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath
                                                                        error:NULL];
    NSMutableArray *jsonFiles = [[NSMutableArray alloc] init];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"json"]) {
            NSString *path = [sourcePath stringByAppendingPathComponent:filename];
            
            path = [[path componentsSeparatedByString:@"/Documents"] objectAtIndex:1];
            
            ImageFolderModel *imageFolderModel = [ImageFolderModel createWithName:filename andPath:path];
            [jsonFiles addObject:imageFolderModel];
        }
    }];
    
    [self setImageFolderModels:jsonFiles];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDoneDownloadAndUnzipImageFolder object:nil userInfo:nil];
    });
    
    return jsonFiles;
}

#pragma mark - check downloaded images
- (void)loadDataFromDb
{
    RLMResults<ImageFolderModel *> *imageFolderModels = [ImageFolderModel allObjects];
    NSMutableArray *tmpImageFolders = [[NSMutableArray alloc] init];
    for (ImageFolderModel *folder in imageFolderModels) {
        [tmpImageFolders addObject:[folder clone]];
    }
    
    [self setImageFolderModels:tmpImageFolders];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDoneDownloadAndUnzipImageFolder object:nil userInfo:nil];
    });
}

#pragma mark - concurrency downloading
- (void)updateConcurrencyCount: (NSInteger)concurrencyCount
{
    [self imageFolderDownloadQueue].maxConcurrentOperationCount = concurrencyCount;
}

- (void)downloadAllImageFolderWithConcurrencyNumber: (NSInteger)concurrencyCount onCompletion: (void (^)(void))completionBlock
{
    
    [self imageFolderDownloadQueue].maxConcurrentOperationCount = concurrencyCount;
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self setIsDownloading:YES];
        [[NSOperationQueue mainQueue] addOperationWithBlock:completionBlock];
    }];
    
    NSArray *folderModels = [self imageFolderModels];
    for (ImageFolderModel *folderModel in folderModels) {
        [folderModel setState:ImageFolderDownloadStateQueueing];
        if ([folderModel progress] >= 1) {
            [folderModel setState:ImageFolderDownloadStateFinished];
        }
    }
    for (ImageFolderModel *folderModel in folderModels) {
        
        if ([folderModel progress] == 1) { continue; }
        
        ImageFolderOperation *operation = [ImageFolderOperation createImageOperationFromImageFolderModel:folderModel withImageProgressBlock:^(ImageModel *imageModel, CGFloat progress) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:imageModel forKey:kNotificationFileProgressModelKey];
            [dict setObject:@(progress) forKey:kNotificationFileProgressProgressKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileProgress object:nil userInfo:dict];
            });
        } andOverallProgressBlock:^(CGFloat progress) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:folderModel forKey:kNotificationFolderProgressModelKey];
            [dict setObject:@(progress) forKey:kNotificationFolderProgressProgressKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFolderProgress object:nil userInfo:dict];
            });
        }];
        [completionOperation addDependency:operation];
    }
    
    if ([completionOperation.dependencies count] > 0) {
        [[self imageFolderDownloadQueue] addOperations:completionOperation.dependencies waitUntilFinished:NO];
    }
    [[self imageFolderDownloadQueue] addOperation:completionOperation];
}

- (void)reset
{
    [self setDidDownloadJson:NO];
    [self dropDb];
    [self removeDownloadFolder];
    [self stopDownloading];
    [self setImageFolderModels:nil];
    [self setImageFolderDownloadQueue:[[ImageOperationQueue alloc] init]];
}

- (void)dropDb
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

- (void)removeDownloadFolder
{
    [[NSFileManager defaultManager] removeItemAtPath:[self downloadFileFolderPath] error:nil];
}

- (void)stopDownloading
{
    [[self imageFolderDownloadQueue] cancelAllOperations];
}

@end
