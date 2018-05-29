//
//  ViewController.h
//  cardreader
//
//  Created by Noverio Joe on 04/05/18.
//  Copyright © 2018 ocbc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <TesseractOCR/TesseractOCR.h>
#import "Utility.h"

@interface ViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,G8TesseractDelegate>


@property Utility *util;
@property BOOL isReadingEktp;
@property (nonatomic,retain) AVCaptureSession *captureSession;
@property (nonatomic,retain) CALayer *customLayer;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,retain) AVCaptureDeviceInput *captureInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *captureOutput;
@property (nonatomic,retain) AVCapturePhotoSettings *capturePhotoSetting;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property dispatch_queue_t captureSessionQueue;
@property (weak, nonatomic) IBOutlet UITextView *textResult;
@property (weak, nonatomic) IBOutlet UIView *viewOverlay;

@property (weak, nonatomic) IBOutlet UISwitch *toogleButton;
@property (weak, nonatomic) IBOutlet UILabel *scanningMode;

- (void)initCapture;
@end
