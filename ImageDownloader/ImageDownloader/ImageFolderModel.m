//
//  ImageFolderModel.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderModel.h"

@implementation ImageFolderModel
+ (ImageFolderModel *)createWithName: (NSString *)name andPath: (NSString *)path
{
    ImageFolderModel *imageFolderModel = [[ImageFolderModel alloc] init];
    imageFolderModel.name = name;
    imageFolderModel.path = path;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:imageFolderModel];
    [realm commitWriteTransaction];

    return [imageFolderModel clone];
}

+ (NSString *)primaryKey {
    return @"path";
}

- (ImageFolderModel *)clone
{
    ImageFolderModel *cloneObj = [[ImageFolderModel alloc] init];
    [cloneObj setName:[self name]];
    [cloneObj setPath:[self path]];
    [cloneObj setProgress:[self progress]];
    
    RLMArray<ImageModel *><ImageModel> *imageModels = [self imageModels];
    [[cloneObj imageModels] removeAllObjects];
    for (ImageModel *imageModel in imageModels) {
        [[cloneObj imageModels] addObject:[imageModel clone]];
    }
    
    return cloneObj;
}

- (void)recomputeProgress
{
    CGFloat imageUrlsCount = [self imagesCount];
    
    CGFloat completeImageModelsCount = 0;
    RLMArray<ImageModel *><ImageModel> *imageModels = [self imageModels];
    for (ImageModel *imageModel in imageModels) {
        if ([imageModel didCompleteDownload] == YES) {
            completeImageModelsCount ++;
        }
    }
    
    self.progress = completeImageModelsCount / imageUrlsCount;
    
    ImageFolderModel *clonedObjc = [self clone];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    clonedObjc.progress = completeImageModelsCount / imageUrlsCount;
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:clonedObjc];
    [realm commitWriteTransaction];
}

- (ImageModel *)addImageToImageModelsFromUrl: (NSString *)url
{
    if (![self checkImageUrlExist:url]) {
        
        NSString *imageName = [self imageNameFromImageUrl:url];
        ImageModel *imageModel = [ImageModel createWithName:imageName andUrl:url];
        
        ImageFolderModel *clonedImageFolderModel = [self clone];
        ImageModel *clonedImageModel = [imageModel clone];
        
        [[self imageModels] addObject:imageModel];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        [[clonedImageFolderModel imageModels] addObject:clonedImageModel];
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:clonedImageModel];
        [realm addOrUpdateObject:clonedImageFolderModel];
        [realm commitWriteTransaction];
        
        return imageModel;
    }
    return nil;
}

- (BOOL)checkImageUrlExist: (NSString *)url
{
    RLMArray<ImageModel *><ImageModel> *imageModels = [self imageModels];
    for (ImageModel *imageModel in imageModels) {
        if ([imageModel.url isEqualToString:url]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)imageNameFromImageUrl: (NSString *)imageUrl
{
    NSArray *comps = [imageUrl componentsSeparatedByString:@"/"];
    NSString *lastComp = [comps lastObject];
    if (lastComp != nil) {
        NSArray *comps = [lastComp componentsSeparatedByString:@"?"];
        NSString *firstComp = [comps firstObject];
        if (firstComp != nil) {
            return firstComp;
        }
    }
    return @"";
}

- (void)updateImageCount: (int)imageCount
{
    [self setImagesCount:imageCount];
    
    ImageFolderModel *clonedObjc = [self clone];
    
    RLMRealm *realm = [RLMRealm defaultRealm];

    clonedObjc.imagesCount = imageCount;
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:clonedObjc];
    [realm commitWriteTransaction];
}

@end
