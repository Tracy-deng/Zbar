//
//  ScanTicketViewController.m
//  扫码
//
//  Created by dave-n1 on 2017/2/13.
//  Copyright © 2017年 tracy. All rights reserved.
//

#import "ScanTicketViewController.h"
#import "Masonry.h"

#define kBorderW [[UIScreen mainScreen] bounds].size.height * 0.2
static const CGFloat kMargin = 30;
@interface ScanTicketViewController ()<AVAudioPlayerDelegate>
{
    
    UIView * scanWindow;
}
@property (nonatomic, strong) ZBarReaderView * readView ;
@property (nonatomic, strong) UIImageView    * scanNetImageView;
@property (nonatomic, strong) CAAnimation    * animation ;
@property (nonatomic, strong) AVAudioPlayer  * audioplayer ; // 播放音效
@end


@implementation ScanTicketViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self setZbarRedearViewStart];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [self closeZbarRedarViewStop];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // 这个属性必须打开否则返回的时候会出现黑边
    self.view.clipsToBounds=YES;

    // 1. 初始化扫描界面
    [self configuredZBarReader];
    
    // 2. 添加背景遮罩界面
    [self setUpMaskView];
    
    // 3. 添加界面上需要展示的信息
    [self setViewWithTitle];
    
    self.animation = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    
  
}

- (void)setZbarRedearViewStart{
    
    _readView.torchMode = 0;      // 关闭闪光灯
    [_readView start];            // 开始扫描二维码
    [self startImageAnimation];   // 开启扫码动画
}


- (void)closeZbarRedarViewStop{
    
    _readView.torchMode = 0;     // 关闭闪光灯
    [_readView stop];            // 结束扫描二维码
    [self stopImageAnimation];   // 关闭扫码动画
}
/**
 *初始化扫描二维码对象ZBarReaderView
 *设置扫描二维码视图的窗口布局、参数
 */
- (void)configuredZBarReader{
    
    //初始化照相机窗口
    _readView = [[ZBarReaderView alloc]init];
    
    _readView.backgroundColor = [UIColor redColor];

    // 设置扫描代理
    _readView.readerDelegate = self;
    // 关闭闪光灯
    _readView.torchMode = 0;
    
     _readView.zoom = 0; //设置下摄像头焦距
    
    [_readView.session setSessionPreset:AVCaptureSessionPresetHigh];  // 设置摄像捕捉等级最高
    // 将其照相机拍摄视图显示到视图上去
    [self.view addSubview:_readView];
    
    // 二维码/条形码设置
    ZBarImageScanner * scanner = _readView.scanner;
    
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    //Layout ZBarReaderView

    _readView.frame = self.view.bounds;
    
    [self setupScanWindowView];
}

- (void)setupScanWindowView
{
    CGFloat scanWindowH = self.view.frame.size.width * 0.8;
    CGFloat scanWindowW = self.view.frame.size.width * 0.8;
    
    
    _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
    CGFloat buttonWH = 18;
    
    scanWindow = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.1, kBorderW, scanWindowW, scanWindowH)];
    scanWindow.backgroundColor = [UIColor clearColor];
    scanWindow.clipsToBounds = YES;
    scanWindow.layer.borderColor = [UIColor blueColor].CGColor;
    scanWindow.layer.borderWidth = 1;
    [_readView addSubview:scanWindow];
    
    
    
    UIButton *topLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWH, buttonWH)];
    [topLeft setImage:[UIImage imageNamed:@"QRCodeTopLeft"] forState:UIControlStateNormal];
    [scanWindow addSubview:topLeft];
    
    UIButton *topRight = [[UIButton alloc] initWithFrame:CGRectMake(scanWindowW - buttonWH, 0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"QRCodeTopRight"] forState:UIControlStateNormal];
    [scanWindow addSubview:topRight];
    
    UIButton *bottomLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, scanWindowH - buttonWH, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"QRCodeBottomLeft"] forState:UIControlStateNormal];
    [scanWindow addSubview:bottomLeft];
    
    UIButton *bottomRight = [[UIButton alloc] initWithFrame:CGRectMake(topRight.frame.origin.x, bottomLeft.frame.origin.y, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"QRCodeBottomRight"] forState:UIControlStateNormal];
    [scanWindow addSubview:bottomRight];
    
    
}

- (void)setUpMaskView{
    
    UIColor *maskColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    UIView *leftMask = [[UIView alloc]init];
    [self.view addSubview:leftMask];
    leftMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [leftMask mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.left.equalTo(self.view);
        make.right.equalTo(scanWindow.mas_left);
    }];
    
    UIView *rightMask = [[UIView alloc]init];
    [self.view addSubview:rightMask];
    rightMask.backgroundColor = maskColor;
    [rightMask mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.right.equalTo(self.view);
        make.left.equalTo(scanWindow.mas_right);
    }];
    
    UIView *topMask = [[UIView alloc]init];
    [self.view addSubview:topMask];
    topMask.backgroundColor = maskColor;
    [topMask mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view);
        make.left.equalTo(leftMask.mas_right);
        make.right.equalTo(rightMask.mas_left);
        make.bottom.equalTo(scanWindow.mas_top);
    }];
    
    UIView *bottomMask = [[UIView alloc]init];
    [self.view addSubview:bottomMask];
    bottomMask.backgroundColor = maskColor;
    [bottomMask mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view);
        make.left.equalTo(leftMask.mas_right);
        make.right.equalTo(rightMask.mas_left);
        make.top.equalTo(scanWindow.mas_bottom);
    }];
    
}

- (void)setViewWithTitle{
    
    // 添加返回按钮
    UIButton * popButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [popButton setImage:[[UIImage imageNamed:@"scan_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateNormal];
    
    [popButton addTarget:self action:@selector(didPop) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:popButton];
    
    popButton.imageEdgeInsets = UIEdgeInsetsMake(12.5,12.5,12.5,12.5);
    //禁止Navigation手势滑动返回操作
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 30)]];
    
    [popButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-30);
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@70);
    }];
}

// 点击返回
- (void)didPop{
    [self.navigationController popViewControllerAnimated:YES];
}


// 开启扫码图片的动画
- (void)startImageAnimation{
    if (_scanNetImageView.isHidden == NO) {
        _scanNetImageView.hidden = NO;
    }
    
    if(self.animation){
        // 1. 将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = _scanNetImageView.layer.timeOffset;
        // 2. 根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        
        // 3. 要把偏移时间清零
        [_scanNetImageView.layer setTimeOffset:0.0];
        // 4. 设置图层的开始动画时间
        [_scanNetImageView.layer setBeginTime:beginTime];
        
        [_scanNetImageView.layer setSpeed:1.0];
        
    }else{
        
        CGFloat scanNetImageViewH = 241;
        CGFloat scanWindowH = self.view.frame.size.width - kMargin * 2;
        CGFloat scanNetImageViewW = scanWindow.frame.size.width;
        
        _scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(scanWindowH);
        scanNetAnimation.duration = 1.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [scanWindow addSubview:_scanNetImageView];
    }
}

// 关闭扫码图片的动画
- (void)stopImageAnimation{
    
    _scanNetImageView.hidden = YES;
}

#pragma mark（二维码/条形码 识别成功后会进入此方法）
- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{

    [self addScanTicketVoice];
    
    ZBarSymbol * symbol = nil;
    for (symbol in symbols) {
        break;
    }
    NSString * urlStr = symbol.data;
    
    // 解析返回扫码得到的string
    if(urlStr == nil || urlStr.length <= 0){
        
        NSLog(@"二维码解析失败");
        
        
    }else{
        NSLog(@"二维码解析成功");
        [self closeZbarRedarViewStop]; // 扫码成之后，那么即可停止扫码
        
#pragma mark  1. 代理传值   2. block传值
        if (self.delegate && [self.delegate respondsToSelector:@selector(coderReaderWithResult:)]) {
            [self.delegate coderReaderWithResult:urlStr];
        }
        
        if (self.codeScanBlock) {
            self.codeScanBlock(urlStr);
        }
        
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"扫描成功" message:[NSString stringWithFormat:@"二维码内容:\n%@",urlStr] preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //继续扫描
            [self setZbarRedearViewStart];
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
       
    }
    
    
    NSLog(@"%@",urlStr);


}

// 增加扫码的音效
- (void)addScanTicketVoice{
    
    // 定义URL NSBundle 获取文件的路径
    NSURL * audioPath = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle]pathForResource:@"FadeIn" ofType:@"wav"]];
    NSError * error = nil;
    _audioplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioPath error:&error];
    // 设置代理
    _audioplayer.delegate = self;
    // 判断是否有误
    if (error != nil) {
        NSLog(@"播放遇到了错误了信息 :%@",[error description]);
        return;
    }
    
    // 开始播放
    [_audioplayer play];

    
}

// 结束播放
- (void)stopScanTicketVoice{
    
    [_audioplayer stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
