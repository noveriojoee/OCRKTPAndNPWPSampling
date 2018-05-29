//
//  Utility.h
//  cardreader
//
//  Created by Noverio Joe on 07/05/18.
//  Copyright © 2018 ocbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CMSampleBuffer.h>


@interface Utility : NSObject

- (UIImage *) resizeImage:(UIImage *)image;
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (UIImage *) cropImageToTheScanAreaOnly:(CGRect)scanAreaFrame originalView : (UIView *)view forImage:(UIImage *)image;
- (NSString *) extractWithRegex:(NSString *)regexString result:(NSString *)ScanResult;

@end
