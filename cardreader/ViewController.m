//
//  ViewController.m
//  cardreader
//
//  Created by Noverio Joe on 04/05/18.
//  Copyright © 2018 ocbc. All rights reserved.
//

#import "ViewController.h"
#import "ImagePreviewViewController.h"


@interface ViewController (){
    BOOL isReadingImage;
}
@property G8Tesseract *tessract;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong) UIImage *imageToProcess;

@end

@implementation ViewController

- (id)init {
    self = [super init];
    if (self) {
        self.imageToProcess = nil;
        self.previewLayer = nil;
        self.customLayer = nil;
        isReadingImage = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    self.util = [Utility new];
    if (self.isReadingEktp == true){
        self.scanningMode.text = @"Scan E-KTP Mode";
    }else{
        self.scanningMode.text = @"Scan NPWP Mode";
    }
    self.imageToProcess = nil;
    //noverio remark begin : to rotate object
    //    self.textResult.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.viewOverlay.layer.borderColor = [UIColor blackColor].CGColor;
    self.viewOverlay.layer.borderWidth = 1;
    
    [self initCapture];
}


- (void)initCapture {
    NSError *error = nil;
    
    // Create the session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [self.captureSession addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [self.captureSession addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    // Setup preview layer
    CGRect previewLayerRect        = self.cameraView.layer.bounds;
    self.previewLayer                = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity    = self.previewLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame            = previewLayerRect;
    self.previewLayer.position        = CGPointMake(CGRectGetMidX(previewLayerRect), CGRectGetMidY(previewLayerRect));
    
    [self.cameraView.layer addSublayer:self.previewLayer];
    
    [self.captureSession startRunning];
}

#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    
    if (isReadingImage == false){
        isReadingImage = true;
        UIImage *originalImage = [self.util imageFromSampleBuffer:sampleBuffer];
        UIImage *scaledImage = [self.util resizeImage:originalImage];
        UIImage *cropImageInScanArea = [self.util cropImageToTheScanAreaOnly:self.viewOverlay.frame originalView:self.view forImage:scaledImage];
        self.imageToProcess = [UIImage imageWithCGImage:[cropImageInScanArea CGImage]
                                                      scale:[cropImageInScanArea scale]
                                                orientation: UIImageOrientationLeft];
        
        [self performRecognitionWithImage:cropImageInScanArea];
    }
}


- (void)performRecognitionWithImage : (UIImage*)originalImage{
    
    NSString *recognitionMode = @"OCRA";
    if (self.isReadingEktp == true){
        recognitionMode = @"OCRA";
    }else{
        recognitionMode = @"NPWP";
    }
    
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:recognitionMode];
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
//    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeSparseText;
    operation.delegate = self;
//    operation.tesseract.charWhitelist = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:.-";
    operation.tesseract.charBlacklist = @"~!#$%^&*;'<>,/?`|{}><()";
    
    //OCBC2ASIT-169
    UIImage *imageToProcess =
    [UIImage imageWithCGImage:[originalImage CGImage]
                        scale:[originalImage scale]
                  orientation: UIImageOrientationLeft];
    
    operation.tesseract.image = imageToProcess;
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        NSString *recognizedText = tesseract.recognizedText;
        self.textResult.text = recognizedText;
        
        if (self.isReadingEktp == true){
            NSString *extractedImageKtpText = [self extractNIK:recognizedText];
            if (extractedImageKtpText.length > 0){
                dispatch_async(dispatch_get_main_queue(),^{
                    [self performSegueWithIdentifier:@"SegueToPreview" sender:extractedImageKtpText];
                });
            }else{
                isReadingImage = false;
            }
        }else{
            NSString *extractedNPWP = [self extractNPWP:recognizedText];
            if (extractedNPWP.length > 0){
                dispatch_async(dispatch_get_main_queue(),^{
                    [self performSegueWithIdentifier:@"SegueToPreview" sender:extractedNPWP];
                });
            }else{
                isReadingImage = false;
            }
        }
    };
    [self.operationQueue addOperation:operation];
    
    //    [self.queue addOperation:operation];
    //noverio first code begin
    //    [self.tessract setImage:originalImage.g8_blackAndWhite];
    //    [self.tessract recognize];
    //    NSLog(@"recognized text %@",[self.tessract recognizedText]);
    //noverio first code end
    
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        if ([segue.identifier isEqualToString:@"SegueToPreview"]){
            ImagePreviewViewController *nextVc = (ImagePreviewViewController*)segue.destinationViewController;
            [nextVc setImagePreview:self.imageToProcess];
            [nextVc setTextResult:(NSString*) sender];
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//noverio remark begin : finding NIK in KTP with regex
#pragma extraction NIK E-KTP Number
-(NSString*) extractNIK:(NSString *)scanResult{
    NSString *nikNumber = @"";
    NSString *regexEKtpNIK = @"[0-9]{16}";
    NSString *regexReturn = [self.util extractWithRegex:regexEKtpNIK result:scanResult];
    if (regexReturn.length == 16){
        nikNumber = regexReturn;
        [self stopShowingLivePreview];
    }
    return nikNumber;
}
#pragma extraction NPWP Number
-(NSString *)extractNPWP:(NSString *)ScanResult{
    NSString *NPWP = @"";

    NSString *REGEX_NPWP = @"[0-9]{2}[.][0-9]{3}[.][0-9]{3}[.][0-9][-][0-9]{3}[.][0-9]{3}";
    NSString *regexReturn = [self.util extractWithRegex:REGEX_NPWP result:ScanResult];
    if (regexReturn.length == 20) {
        NPWP = regexReturn;
        [self stopShowingLivePreview];
    }
    return NPWP;

}
//noverio remark end

- (IBAction)scanningModeChange:(id)sender {
    
    self.isReadingEktp = !self.isReadingEktp;
    if (self.isReadingEktp == true){
        self.scanningMode.text = @"Scan E-KTP Mode";
    }else{
        self.scanningMode.text = @"Scan NPWP Mode";
    }

}

-(void)stopShowingLivePreview
{
    [self.captureSession stopRunning];
    
    self.previewLayer = nil;
    self.customLayer = nil;
    isReadingImage = false;
    
    self.util = nil;
    self.operationQueue = nil;

    self.captureSession = nil;
}

@end
