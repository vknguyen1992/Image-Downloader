//
//  ImageDownloader.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
#import "AppDelegate.h"

@interface ImageDownloader()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) NSURL *tempDownloadedFileLocation;

@property (nonnull, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) void (^progressBlock)(CGFloat progress);
@property (nonatomic, strong) void (^completionBlock)(ImageDownloader *imageDownloader);
@end

@implementation ImageDownloader
- (instancetype)initWithUrl: (NSString *)url progressBlock: (void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(ImageDownloader *imageDownloader))completionBlock
{
    self = [super init];
    if (self) {
        _url = url;
        _progressBlock = progressBlock;
        _completionBlock = completionBlock;
    }
    return self;
}

- (void)startDownload
{
    NSURL *url = [NSURL URLWithString:[self url]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[self url]];
    [config setSessionSendsLaunchEvents:YES];
    [config setDiscretionary:YES];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

    [self setSemaphore:dispatch_semaphore_create(0)];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
    [task resume];
    dispatch_semaphore_wait([self semaphore], DISPATCH_TIME_FOREVER);
}

#pragma mark - delegates

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self setTempDownloadedFileLocation:location];
    dispatch_semaphore_signal([self semaphore]);
    self.completionBlock(self);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"Received data %lu bytes", (unsigned long)totalBytesWritten);
    self.progressBlock(((float)totalBytesWritten) / ((float)totalBytesExpectedToWrite));
}

@end
