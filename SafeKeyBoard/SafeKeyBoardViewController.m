//
//  SafeKeyBoardViewController.m
//  demo
//
//  Created by gaofu on 2017/3/27.
//  Copyright © 2017年 siruijk. All rights reserved.
//
//  Abstract:键盘

#import "SafeKeyBoardViewController.h"
#import "SafeKeyboard.h"

@interface SafeKeyBoardViewController ()

@end

@implementation SafeKeyBoardViewController
{
    __weak IBOutlet UITextField *_safeKeyboard;
    
}

#pragma mark -
#pragma mark  Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    SafeKeyboard*safeKeyboard = [SafeKeyboard keyboardWithTextField:_safeKeyboard];
    [safeKeyboard safeKeyBoardDidChanged:^(NSString *value) {
        NSLog(@"输入结果:%@",value);
    }];
    
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
