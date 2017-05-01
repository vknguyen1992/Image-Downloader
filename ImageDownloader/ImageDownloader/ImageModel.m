//
//  ImageModel.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageModel.h"

@interface ImageModel()
@end

@implementation ImageModel
+ (ImageModel *)createWithName: (NSString *)name andUrl: (NSString *)url
{
    ImageModel *imageModel = [[ImageModel alloc] init];
    imageModel.name = name;
    imageModel.url = url;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:imageModel];
    [realm commitWriteTransaction];
    
    return [imageModel clone];
}

- (ImageModel *)clone
{
    ImageModel *cloneObj = [[ImageModel alloc] init];
    [cloneObj setName:[self name]];
    [cloneObj setUrl:[self url]];
    [cloneObj setProgress:[self progress]];
    [cloneObj setDidCompleteDownload:[self didCompleteDownload]];
    
    return cloneObj;
}

- (void)updateProgress: (float)progress
{
    [self setProgress:progress];
    
    ImageModel *clonedObj = [self clone];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [clonedObj setProgress:progress];
    [realm commitWriteTransaction];
}

- (void)updateDidCompleteDownload: (float)didCompleteDownload
{
    [self setDidCompleteDownload:didCompleteDownload];
    
    ImageModel *clonedObj = [self clone];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [clonedObj setDidCompleteDownload:didCompleteDownload];
    [realm commitWriteTransaction];
}

@end
