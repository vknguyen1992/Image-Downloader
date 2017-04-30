//
//  ImageDownloader.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"

@interface ImageDownloader()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGFloat totalBytes;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) NSMutableData *data;

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
    [self setData:[[NSMutableData alloc] initWithLength:0]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

    [self setSemaphore:dispatch_semaphore_create(0)];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url];
    [task resume];
    dispatch_semaphore_wait([self semaphore], DISPATCH_TIME_FOREVER);
    self.completionBlock(self);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [[self data] setLength:0];
    self.totalBytes = response.expectedContentLength;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [[self data] appendData:data];
    if ([[self data] length] == [self totalBytes]) {
        dispatch_semaphore_signal([self semaphore]);
    }
    CGFloat progress = [[self data] length] / [self totalBytes];
    self.progressBlock(progress);
}


@end
