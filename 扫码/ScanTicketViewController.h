//
//  ScanTicketViewController.h
//  扫码
//
//  Created by dave-n1 on 2017/2/13.
//  Copyright © 2017年 tracy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark  1.选择代理  2. 选择block  传值获得到的二维码/条形码
@protocol CodeReaderDelegate<NSObject>
@optional

- (void)coderReaderWithResult:(NSString *)result;

@end

typedef void(^CoderReadrResultBlock)(NSString * result);

@interface ScanTicketViewController : UIViewController<ZBarReaderDelegate,ZBarReaderViewDelegate>

// 打开二维码扫描图
- (void)setZbarRedearViewStart;

// 关闭二维码扫描图
- (void)closeZbarRedarViewStop;

@property (nonatomic, copy) CoderReadrResultBlock codeScanBlock;
@property (nonatomic, weak) id<CodeReaderDelegate>delegate;



@end
