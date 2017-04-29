//
//  ImageFolderModel.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageModel.h"

@interface ImageFolderModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) NSMutableArray *imageModels;
@property (nonatomic, strong) NSArray *imageUrls;

- (instancetype)initWithName: (NSString *)name andPath: (NSString *)path;
- (void)recomputeProgress;
- (ImageModel *)addImageToImageModelsFromUrl: (NSString *)url;
@end
