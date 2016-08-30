//
//  ViewController.m
//  sacn
//
//  Created by 法大大 on 16/8/30.
//  Copyright © 2016年 fadada. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>


@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    AVCaptureSession * session;//输入输出的中间桥梁
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    
    
    #pragma mark 扫描二维码
    UIButton * goScan = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:goScan];
    [goScan addTarget:self action:@selector(scanQR) forControlEvents:UIControlEventTouchUpInside];
    goScan.frame = CGRectMake(200, 200, 100, 40);
    [goScan setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [goScan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goScan setBackgroundColor:[UIColor orangeColor]];
    
    #pragma mark 生成二维码
    UIImageView * im = [[UIImageView alloc]initWithImage:[self createQRimageWithString:@"你好，我" andWithSize:100]];
    [self.view addSubview:im];
    im.frame = CGRectMake(100, 100, 100, 100);
   
    
    #pragma mark 去相册识别
    UIButton * gotoPic = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:gotoPic];
    [gotoPic addTarget:self action:@selector(choicePhoto) forControlEvents:UIControlEventTouchUpInside];
    gotoPic.frame = CGRectMake(200, 300, 100, 40);
    [gotoPic setTitle:@"去相册读取" forState:UIControlStateNormal];
    [gotoPic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [gotoPic setBackgroundColor:[UIColor orangeColor]];
    
    #pragma mark 打开闪光灯
    UIButton * openLt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:openLt];
    [openLt setTitle:@"打开关闭闪光灯" forState:UIControlStateNormal];
    [openLt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [openLt setBackgroundColor:[UIColor orangeColor]];
    openLt.tag = 1;
    [openLt addTarget:self action:@selector(openLT:) forControlEvents:UIControlEventTouchUpInside];
    openLt.frame = CGRectMake(200, 350, 180, 100);
}


- (void)choicePhoto{
    //调用相册
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
//选中图片的回调
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *content = @"" ;
    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];
    
    //取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        content = result.messageString;
       
    }
    //进行处理(音效、网址分析、页面跳转等)
    
    NSLog(@"二维码内容：%@",content);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



/**
 *  创建二维码
 *
 *  @param str  要创建的字符串
 *  @param size 二维码的宽度
 *
 *  @return 返回二维码图片
 */
- (UIImage *)createQRimageWithString:(NSString *)str andWithSize:(CGFloat)size{

    NSData *stringData = [str dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    CIImage *  ciImage = qrFilter.outputImage;
    UIImage * image = [self createNonInterpolatedUIImageFormCIImage:ciImage withSize:size];
    
    return image;
}

/**
 *  转换图片
 *
 *  @param image CIImage
 *  @param size  返回图片的宽度
 *
 *  @return 返回的图片
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark 二维码扫描模块
-(void)scanQR{

    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    
    UIView * bgView = [[UIView alloc]init];
    [self.view addSubview:bgView];
    bgView.frame = CGRectMake(40, 100, 240, 240);
    bgView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.6];
    
    
    CGFloat ScreenHigh = [UIScreen mainScreen].bounds.size.height;
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [output setRectOfInterest:CGRectMake((100)/ScreenHigh,((ScreenWidth-40)/2)/ScreenWidth,240/ScreenHigh,240/ScreenWidth)];
    
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [session addInput:input];
    [session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [session startRunning];

}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        //[session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        NSLog(@"%@",metadataObject.stringValue);
    }
}


#pragma mark 闪光灯模块

- (void)openLT:(UIButton *)sender{
    
    sender.tag = !sender.tag;
    
    if (sender.tag) {
        
        [self turnOffLed];
        
    }else{
        [self turnOnLed];
    }
    
}

/**
 * 关闭闪光灯
 */
-(void)turnOffLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

/**
 *  打开闪光灯
 */
-(void)turnOnLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }   
}


@end
