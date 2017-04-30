//
//  ImageFolderOperation.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/29/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageFolderModel.h"
#import "ImageModel.h"

@interface ImageFolderOperation : NSBlockOperation
+ (ImageFolderOperation *)createImageOperationFromImageFolderModel: (ImageFolderModel *)imageFolderModel
                                            withImageProgressBlock:(void (^)(ImageModel *imageModel, CGFloat progress))imageProgessBlock
                                           andOverallProgressBlock:(void (^)(CGFloat progress))overallProgessBlock;
@end
