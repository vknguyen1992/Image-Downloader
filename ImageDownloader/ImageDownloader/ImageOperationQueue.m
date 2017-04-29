//
//  ImageOperationQueue.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/29/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageOperationQueue.h"
#import "ImageFolderOperation.h"

@implementation ImageOperationQueue
- (void)cancelAllOperations
{
    NSArray *allOperations = [self operations];
    for (NSBlockOperation *operation in allOperations) {
        if ([operation isKindOfClass:[ImageFolderOperation class]]) {
            [operation cancel];
        }
    }
}
@end
