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
#import <Realm/Realm.h>

RLM_ARRAY_TYPE(ImageModel)
@interface ImageFolderModel : RLMObject
@property NSString *name;
@property NSString *path;
@property float progress;
@property RLMArray<ImageModel *><ImageModel> *imageModels;

+ (ImageFolderModel *)createWithName: (NSString *)name andPath: (NSString *)path;
- (void)recomputeProgress;
- (ImageModel *)addImageToImageModelsFromUrl: (NSString *)url;

- (ImageFolderModel *)clone;
@end
