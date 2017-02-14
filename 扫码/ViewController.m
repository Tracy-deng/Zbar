//
//  ViewController.m
//  扫码
//
//  Created by dave-n1 on 2017/2/13.
//  Copyright © 2017年 tracy. All rights reserved.
//

#import "ViewController.h"
#import "ScanTicketViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanButton setTitle:@"扫描小票" forState:UIControlStateNormal];
    scanButton.backgroundColor = [UIColor redColor];
    [scanButton setTintColor:[UIColor yellowColor]];
    [self.view addSubview:scanButton];
    
    scanButton.frame = CGRectMake(100, 100, 200, 30);
    [scanButton addTarget:self action:@selector(didPushScan) forControlEvents:(UIControlEventTouchUpInside)];
    
}


- (void)didPushScan
{
    ScanTicketViewController * scan = [[ScanTicketViewController alloc]init];
    [self.navigationController pushViewController:scan animated:NO];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
