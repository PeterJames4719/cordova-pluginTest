//
//  BMADUniTool.m
//  BMADUniPlugin
//
//  Created by 兵伍 on 2020/5/28.
//  Copyright © 2020 兵伍. All rights reserved.
//

#import "BMADH5Tool.h"
#import <objc/runtime.h>

@implementation BMADH5Tool

+ (instancetype)sharedTool {
    static BMADH5Tool *t;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        t = [[BMADH5Tool alloc] init];
    });
    return t;
}

+ (BOOL)isInvalidString:(NSString *)s {
    if (![s isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if (s.length == 0) {
        return YES;
    }
    
    return NO;
}

+ (void)setDebug:(BOOL)debug {
    BloomAD_plugin_debug = debug;
}

+ (void)log:(NSString *)format, ... {
 
    if (BloomAD_plugin_debug) {
        va_list args;
        va_start(args, format);
        NSString* s=[[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        NSLog(@"BloomADPluginLOG -> %@", s);
    }
}

// 获取当前显示的 UIViewController
+ (UIViewController *)findCurrentShowingViewController {
    //获得当前活动窗口的根视图
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [self findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
}

+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    // 递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) {
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }

    return currentShowingVC;
}

#pragma mark - Device

+ (CGFloat)statusBarHeight {
    if ([[self class] isIPhoneX]) {
        return 44;
    }
    return 20;
}

+ (CGFloat)homeIndicatorHeight {
    if ([[self class] isIPhoneX]) {
        return 35;
    }
    return 0;
}

+ (BOOL)isIPhoneX {
    static dispatch_once_t onceToken;
    static BOOL isIPhoneX;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            if ([UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom > 0) {
                isIPhoneX = YES;
            }
        } else {
            NSInteger height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            isIPhoneX = (height == 812) || (height == 896);
        }
        
    });
    return isIPhoneX;
}

@end
