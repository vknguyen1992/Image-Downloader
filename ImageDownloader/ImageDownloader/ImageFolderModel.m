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

- (ImageFolderModel *)clone
{
    ImageFolderModel *cloneObj = [[ImageFolderModel alloc] init];
    [cloneObj setName:[self name]];
    [cloneObj setPath:[self path]];
    [cloneObj setProgress:[self progress]];
    
    RLMArray<ImageModel *><ImageModel> *imageModels = [self imageModels];
    RLMArray<ImageModel *><ImageModel> *clonedImageModels;
    for (ImageModel *imageModel in imageModels) {
        [clonedImageModels addObject:[imageModel clone]];
    }
    [cloneObj setImageModels:clonedImageModels];
    
    return cloneObj;
}

- (void)recomputeProgress
{
    CGFloat imageUrlsCount = [[self imageModels] count];
    
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
    [realm beginWriteTransaction];
    clonedObjc.progress = completeImageModelsCount / imageUrlsCount;
    [realm commitWriteTransaction];
}

- (ImageModel *)addImageToImageModelsFromUrl: (NSString *)url
{
    if (![self checkImageUrlExist:url]) {
        NSString *imageName = [self imageNameFromImageUrl:url];
        ImageModel *imageModel = [ImageModel createWithName:imageName andUrl:url];
        [[self imageModels] addObject:imageModel];
        
        ImageFolderModel *clonedImageFolderModel = [self clone];
        ImageModel *clonedImageModel = [imageModel clone];
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        [realm beginWriteTransaction];
        [[clonedImageFolderModel imageModels] addObject:clonedImageModel];
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
@end
