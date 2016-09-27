//
//  ViewController.m
//  CameraTest
//
//  Created by TuLigen on 16/9/21.
//  Copyright © 2016年 TuLigen. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton            *button;
@property (weak, nonatomic) IBOutlet UIButton *btnget;
@property (weak, nonatomic) IBOutlet UIButton *btn2d;
@property (weak, nonatomic) IBOutlet UIButton *btnbuild2d;
@property (weak, nonatomic) IBOutlet UIImageView         *imgview;
@property (strong,nonatomic) MPMoviePlayerController     *moviePlayerController;
@property (strong,nonatomic) UIImage                     *image;
@property (strong,nonatomic) NSURL                       *movieURL;
@property (copy  ,nonatomic) NSString                    *lastChosenMediaType;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;
@end


@interface ViewController (CODE)

@end

@implementation ViewController (CODE)


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if(metadataObjects != nil && [metadataObjects count] > 0){
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if( [[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
            result = metadataObj.stringValue;
        }
        else
        {
            NSLog(@"不是二维码");
        }
      
        if( nil != result)
        {
            [self performSelectorOnMainThread:@selector(reportScanResult:) withObject: result waitUntilDone:YES];
        }
    }
}

-(void)reportScanResult:(NSString*) result
{
    [self stopRending];
    if(!self.lastResult)
    {
        return;
    }
    self.lastResult = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"二维码扫描" message:result delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alert show];
    self.lastResult = YES;
}



static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
-(BOOL)startRending
{
    self.lastResult = YES;
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if(!input)
    {
        NSLog(@"%@",[error localizedDescription]);
        return NO;
    }
    //创建会话
    self.captureSession =  [[AVCaptureSession alloc] init];
    //提高图片质量，提高识别效果
    self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    [self.captureSession addInput:input];
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //设置扫描范围
//    captureMetadataOutput.rectOfInterest = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes: [NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    if(nil == self.videoPreviewLayer)
    {
        //创建输出对象
        self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.videoPreviewLayer setFrame:self.imgview.layer.bounds];
        [self.imgview.layer addSublayer:self.videoPreviewLayer];
    }
    else
    {
        [self.videoPreviewLayer setSession:self.captureSession];
        self.videoPreviewLayer.hidden = NO;
    }
    [self.captureSession startRunning];
    
    return YES;
}

-(BOOL)stopRending
{
    [self.captureSession stopRunning];
    self.videoPreviewLayer.hidden = YES;
    self.captureSession = nil;
    return YES;
}

-(UIImage*) createQRForString:( NSString *)str ImageName: (NSString *) imagename
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *outputImage = [filter outputImage];
    CGRect extent = CGRectIntegral(outputImage.extent);
    CGFloat scale = MIN(self.imgview.bounds.size.width/CGRectGetWidth(extent),self.imgview.bounds.size.height/CGRectGetHeight(extent));
    size_t width  = CGRectGetWidth(extent)  * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceCMYK();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:outputImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
@end

@implementation UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGFloat imageW = 3;
    CGFloat imageH = 3;
    // 1.开启基于位图的图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageW, imageH), NO, 0.0);
    // 2.画一个color颜色的矩形框
    [color set];
    UIRectFill(CGRectMake(0, 0, imageW, imageH));
    
    // 3.拿到图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4.关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
}

@end


@implementation ViewController




-(void) initControls
{
    _button.layer.borderWidth  = 2;
    _button.layer.masksToBounds = YES;
    _button.layer.cornerRadius = 10;
    _button.layer.borderColor  = [UIColor greenColor].CGColor;
    _button.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [_button setBackgroundImage:[UIImage imageWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    [_button setBackgroundImage:[UIImage imageWithColor: [UIColor greenColor]] forState:UIControlStateHighlighted];
   
    
    _btnget.layer.borderWidth  = 2;
    _btnget.layer.masksToBounds = YES;
    _btnget.layer.cornerRadius = 10;
    _btnget.layer.borderColor  = [UIColor greenColor].CGColor;
    _btnget.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [_btnget setBackgroundImage:[UIImage imageWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    [_btnget setBackgroundImage:[UIImage imageWithColor: [UIColor greenColor]] forState:UIControlStateHighlighted];
   
    _btnbuild2d.layer.borderWidth  = 2;
    _btnbuild2d.layer.masksToBounds = YES;
    _btnbuild2d.layer.cornerRadius = 10;
    _btnbuild2d.layer.borderColor  = [UIColor greenColor].CGColor;
    _btnbuild2d.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [_btnbuild2d setBackgroundImage:[UIImage imageWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    [_btnbuild2d setBackgroundImage:[UIImage imageWithColor: [UIColor greenColor]] forState:UIControlStateHighlighted];
    
    _btn2d.layer.borderWidth  = 2;
    _btn2d.layer.masksToBounds = YES;
    _btn2d.layer.cornerRadius = 10;
    _btn2d.layer.borderColor  = [UIColor greenColor].CGColor;
    _btn2d.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [_btn2d setBackgroundImage:[UIImage imageWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    [_btn2d setBackgroundImage:[UIImage imageWithColor: [UIColor greenColor]] forState:UIControlStateHighlighted];
    
    _imgview.layer.cornerRadius = 10;
    _imgview.layer.masksToBounds = YES;
    _imgview.layer.borderWidth  = 2;
    _imgview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _imgview.clipsToBounds = YES;
    _imgview.contentMode = UIViewContentModeScaleAspectFit;
    _imgview.layer.borderColor  = [UIColor greenColor].CGColor;
}

-(void) initCamera
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _button.hidden = true;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateDisplay];
}
-(void) updateDisplay
{
    if( [self.lastChosenMediaType isEqual:(NSString*)kUTTypeImage]){
        self.imgview.image = self.image;
        self.imgview.hidden= NO;
        self.moviePlayerController.view.hidden = YES;
    }
    else if( [self.lastChosenMediaType isEqual:(NSString*)kUTTypeMovie])
    {
        if(self.moviePlayerController == nil)
        {
            self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:self.movieURL];
            UIView *movieview = self.moviePlayerController.view;
            movieview.frame = self.imgview.frame;
            movieview.clipsToBounds = YES;
            [self.view addSubview:movieview];
            [self setMoviePlayerLayoutConstraints];
        }
        else
        {
            self.moviePlayerController.contentURL  = self.movieURL;
        }
        self.imgview.hidden = YES;
        self.moviePlayerController.view.hidden = NO;
        [self.moviePlayerController play];
    }
}
- (void) setMoviePlayerLayoutConstraints
{
    UIView *moviePlayerView = self.moviePlayerController.view;
    UIView *takepictureButton = self.button;
    moviePlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views =
    NSDictionaryOfVariableBindings(moviePlayerView,takepictureButton);
    [self.view addConstraint:
     [ NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moviePlayerView]|" options:0 metrics:nil views:views]];
//    [self.view addConstraint:[ NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[moviePlayerView]-0-[takepictureButton]-|" options:0 metrics:nil views:views]];
}

-(void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType{
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if( [UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0)
    {
        UIImagePickerController *picker =  [[UIImagePickerController alloc]init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"error accessing media" message:@"unsupported media source" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initControls];
    [self initCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 -(IBAction)  click
{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}
-(IBAction)get
{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}
-(IBAction) catpure
{
    [self startRending];
}

-(IBAction)build2d
{
    self.imgview.image = [self createQRForString:@"www.baidu.com" ImageName:@"11"];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.lastChosenMediaType = info[UIImagePickerControllerMediaType];
    if( [self.lastChosenMediaType isEqual:(NSString*)kUTTypeImage])
    {
        self.image = info[UIImagePickerControllerOriginalImage];
    }
    else if( [self.lastChosenMediaType isEqual:(NSString*)kUTTypeMovie])
    {
        self.movieURL = info[UIImagePickerControllerMediaURL];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
