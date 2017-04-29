//
//  ImageDownloadManager.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageManager : NSObject
- (void)downloadImageJsonFolder;
- (void)downloadAllImageFolderWithConcurrencyNumber: (NSInteger)concurrencyCount onCompletion: (void (^)(void))completionBlock;
@end
