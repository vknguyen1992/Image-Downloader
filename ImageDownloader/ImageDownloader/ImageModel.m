//
//  ImageModel.m
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/28/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import "ImageModel.h"

@implementation ImageModel
- (instancetype)initWithName: (NSString *)name andUrl: (NSString *)url
{
    self = [super init];
    if (self) {
        _name = name;
        _url = url;
    }
    return self;
}
@end
