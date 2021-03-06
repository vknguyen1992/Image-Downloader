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
+ (NSArray *)ignoredProperties {
    return @[@"state"];
}

+ (ImageModel *)createWithName: (NSString *)name andUrl: (NSString *)url
{
    ImageModel *imageModel = [[ImageModel alloc] init];
    imageModel.name = name;
    imageModel.url = url;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:imageModel];
    [realm commitWriteTransaction];
    
    return [imageModel clone];
}

+ (NSString *)primaryKey {
    return @"url";
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

    [clonedObj setProgress:progress];
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:clonedObj];
    [realm commitWriteTransaction];
}

- (void)updateDidCompleteDownload: (float)didCompleteDownload
{
    [self setDidCompleteDownload:didCompleteDownload];
    
    ImageModel *clonedObj = [self clone];
    
    RLMRealm *realm = [RLMRealm defaultRealm];

    [clonedObj setDidCompleteDownload:didCompleteDownload];
    
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:clonedObj];
    [realm commitWriteTransaction];
}

@end
