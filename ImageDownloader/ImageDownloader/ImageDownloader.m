//
//  ImageDownloader.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
#import "NSURLSession+Synchronous.h"

@interface ImageDownloader()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGFloat totalBytes;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) NSMutableData *data;

@property (nonatomic, strong) void (^progressBlock)(CGFloat progress);
@property (nonatomic, strong) void (^completionBlock)();
@end

@implementation ImageDownloader
- (instancetype)initWithUrl: (NSString *)url progressBlock: (void (^)(CGFloat progress))progressBlock completionBlock:(void (^)())completionBlock
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

    [session synchronouslyDownloadWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.completionBlock();
    }];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [[self data] setLength:0];
    self.totalBytes = response.expectedContentLength;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [[self data] appendData:data];
    CGFloat progress = [[self data] length] / [self totalBytes];
    self.progressBlock(progress);
}


@end
