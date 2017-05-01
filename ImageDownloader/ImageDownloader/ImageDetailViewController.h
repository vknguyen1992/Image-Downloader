//
//  ImageDetailViewController.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/30/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "ImageModel.h"
#import "ImageFolderModel.h"

@interface ImageDetailViewController : UIViewController
@property (nonatomic, strong) ImageFolderModel *imageFolderModel;
@property (nonatomic, strong) NSArray *imageModels;
@property (nonatomic, assign) NSInteger imgIndex;
@end
