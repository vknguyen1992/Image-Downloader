//
//  ImageModel.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

typedef NS_ENUM(NSInteger, ImageDownloadState) {
    ImageDownloadStateQueueing,
    ImageDownloadStateDownloading,
    ImageDownloadStateFinished,
    ImageDownloadStateError
};

@interface ImageModel : RLMObject
@property NSString *name;
@property NSString *url;
@property float progress;
@property ImageDownloadState state;
@property BOOL didCompleteDownload; // TODO recheck didCompletedCondition

+ (ImageModel *)createWithName: (NSString *)name andUrl: (NSString *)url;
- (void)updateProgress: (float)progress;
- (void)updateDidCompleteDownload: (float)didCompleteDownload;

- (ImageModel *)clone;
@end
