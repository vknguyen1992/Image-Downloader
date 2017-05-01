//
//  ImageFolderOperation.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/29/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderOperation.h"
#import "ImageDownloader.h"

@implementation ImageFolderOperation
+ (ImageFolderOperation *)createImageOperationFromImageFolderModel: (ImageFolderModel *)imageFolderModel
                                            withImageProgressBlock:(void (^)(ImageModel *imageModel, CGFloat progress))imageProgessBlock
                                           andOverallProgressBlock:(void (^)(CGFloat progress))overallProgessBlock
{
    ImageFolderOperation *imageFolderOperation = [[ImageFolderOperation alloc] init];
    __weak ImageFolderOperation *weakImageOperation = imageFolderOperation;
    [imageFolderOperation addExecutionBlock:^{
        [imageFolderModel setState:ImageFolderDownloadStateDownloading];
        [weakImageOperation downloadImagesFromImageFolderModel:imageFolderModel withImageProgressBlock:imageProgessBlock andOverallProgressBlock:overallProgessBlock];
    }];
    
    return imageFolderOperation;
}

- (void)downloadImagesFromImageFolderModel: (ImageFolderModel *)imageFolderModel withImageProgressBlock:(void (^)(ImageModel *imageModel, CGFloat progress))imageProgessBlock andOverallProgressBlock:(void (^)(CGFloat progress))overallProgessBlock
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:[imageFolderModel path]];
    
    NSArray *imageUrls = [self readImageUrlListFromFilePath:path];
    [imageFolderModel updateImageCount:(int)[imageUrls count]];
    for (NSString *url in imageUrls) {
        
        if ([self isCancelled]) {
            return;
        }
        
        ImageModel *imageModel = [imageFolderModel addImageToImageModelsFromUrl:url];
        if (imageModel == nil || [imageModel didCompleteDownload]) { continue; }

        [self downloadImageFromUrl:url withProgressBlock:^(CGFloat progress) {
            [imageModel updateProgress:progress];
            imageProgessBlock(imageModel, progress);
        } amdCompletion:^(ImageDownloader *imageDownloader) {
            NSError *error;
            
            NSString *folderName = [[[imageFolderModel path] componentsSeparatedByString:@"."] firstObject];
            folderName = [documentPath stringByAppendingPathComponent:folderName];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:folderName withIntermediateDirectories:YES attributes:nil error:&error];

            NSString *imagePath = [folderName stringByAppendingPathComponent:[imageModel name]];

            BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[[imageDownloader tempDownloadedFileLocation] relativePath] toPath:imagePath error:&error];
            
            [imageModel updateDidCompleteDownload:success];
            [imageFolderModel recomputeProgress];
            overallProgessBlock([imageFolderModel progress]);
        }];
    }
    
    [imageFolderModel setState:ImageFolderDownloadStateFinished];
}

- (NSArray *)readImageUrlListFromFilePath: (NSString *)filePath
{
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    NSArray *filesList =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return filesList;
}

- (void)downloadImageFromUrl: (NSString *)url withProgressBlock:(void (^)(CGFloat progress))progessBlock amdCompletion:(void (^)(ImageDownloader *imageDownloader))completion
{
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithUrl:url progressBlock:progessBlock completionBlock:completion];
    [imageDownloader startDownload];
}
@end
