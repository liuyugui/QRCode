自己写的使用原生的AVFoundation处理二维码工程



打开关闭闪光灯

AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
if ([device hasTorch]) {
[device lockForConfiguration:nil];
[device setTorchMode: AVCaptureTorchModeOff];
[device unlockForConfiguration];
}


扫描二维码


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

这里要提醒的是 

RectOfInterest

这个值是屏幕比例，并且是xy坐标对调了的








