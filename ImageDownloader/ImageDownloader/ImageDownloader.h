//
//  ImageDownloader.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDownloader : NSObject<NSURLSessionDownloadDelegate>//<NSURLSessionDataDelegate>
@property (readonly, nonatomic, strong) NSURL *tempDownloadedFileLocation;

- (instancetype)initWithUrl: (NSString *)url progressBlock: (void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(ImageDownloader *imageDownloader))completionBlock;
- (void)startDownload;
@end
