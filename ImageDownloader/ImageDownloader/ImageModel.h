//
//  ImageModel.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL didCompleteDownload;

- (instancetype)initWithName: (NSString *)name andUrl: (NSString *)url;
@end
