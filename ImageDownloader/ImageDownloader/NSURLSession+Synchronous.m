//
//  NSURLSession+Synchronous.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/29/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "NSURLSession+Synchronous.h"

@implementation NSURLSession (Synchronous)
- (void)synchronouslyDownloadWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSessionDownloadTask *task = [self downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_semaphore_signal(semaphore);
        completionHandler(location, response, error);
    }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}
@end
