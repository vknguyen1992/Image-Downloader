//
//  NSURLSession+Synchronous.h
//  ImageDownloader
//
//  Created by Nguyen Vu on 4/29/17.
//  Copyright © 2017 Nguyen Vu Khoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (Synchronous)
- (void)synchronouslyDownloadWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
@end
