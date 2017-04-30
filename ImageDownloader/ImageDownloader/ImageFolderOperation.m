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
        [weakImageOperation downloadImagesFromImageFolderModel:imageFolderModel withImageProgressBlock:imageProgessBlock andOverallProgressBlock:overallProgessBlock];
    }];
    
    return imageFolderOperation;
}

// should push notification or use delegate here to update UI
- (void)downloadImagesFromImageFolderModel: (ImageFolderModel *)imageFolderModel withImageProgressBlock:(void (^)(ImageModel *imageModel, CGFloat progress))imageProgessBlock andOverallProgressBlock:(void (^)(CGFloat progress))overallProgessBlock
{
    NSArray *imageUrls = [self readImageUrlListFromFilePath:[imageFolderModel path]];
    [imageFolderModel setImageUrls:imageUrls];
    for (NSString *url in imageUrls) {
        
        if ([self isCancelled]) {
            return;
        }
        
        ImageModel *imageModel = [imageFolderModel addImageToImageModelsFromUrl:url];
        if ([imageModel didCompleteDownload]) { continue; }
            
        [self downloadImageFromUrl:url withProgressBlock:^(CGFloat progress) {
            [imageModel setProgress:progress];
            imageProgessBlock(imageModel, progress);
        } amdCompletion:^{
            [imageModel setDidCompleteDownload:YES];
            [imageFolderModel recomputeProgress];
            overallProgessBlock([imageFolderModel progress]);
        }];
    }
}


- (NSArray *)readImageUrlListFromFilePath: (NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *filesList =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return filesList;
}

- (void)downloadImageFromUrl: (NSString *)url withProgressBlock:(void (^)(CGFloat progress))progessBlock amdCompletion:(void (^)())completion
{
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithUrl:url progressBlock:progessBlock completionBlock:completion];
    [imageDownloader startDownload];
}
@end
