//
//  ImageFolderModel.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageFolderModel.h"

@implementation ImageFolderModel
- (instancetype)initWithName: (NSString *)name andPath: (NSString *)path
{
    self = [super init];
    if (self) {
        _name = name;
        _path = path;
        _imageModels = [[NSMutableArray alloc] init];
        _imageUrls = [[NSArray alloc] init];
    }
    return self;
}

- (void)recomputeProgress
{
    NSInteger imageUrlsCount = [[self imageUrls] count];
    
    NSInteger completeImageModelsCount = 0;
    NSArray *imageModels = [self imageModels];
    for (ImageModel *imageModel in imageModels) {
        if ([imageModel didCompleteDownload] == YES) {
            completeImageModelsCount ++;
        }
    }
    
    [self setProgress:(completeImageModelsCount / imageUrlsCount)];
}

- (ImageModel *)addImageToImageModelsFromUrl: (NSString *)url
{
    if (![self checkImageUrlExist:url]) {
        NSString *imageName = [self imageNameFromImageUrl:url];
        ImageModel *imageModel = [[ImageModel alloc] initWithName:imageName andUrl:url];
        [[self imageModels] addObject:imageModel];
        return imageModel;
    }
    return nil;
}

- (BOOL)checkImageUrlExist: (NSString *)url
{
    NSArray *imageModels = [self imageModels];
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
