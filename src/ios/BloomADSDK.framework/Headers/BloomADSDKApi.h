//
//  BloomADSDKApi.h
//  BMADSDK
//
//  Created by 兵伍 on 2019/3/15.
//  Copyright © 2019 兵伍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BMADConfigModel.h"
#import "BloomADSDKCallbackDelegates.h"
#import "BMADExpressDrawVideoAd.h"


@interface BloomADSDKApi : NSObject
/**当前：1.0.8(1)
 * @return SDK 版本
 */
+ (NSString *)sdkVersion;

/**
 * SDK 初始化接口
 * @param config 配置类对象
 * @return 是否初始化成功，1：成功；0：失败；
 */
+ (BOOL)setupWithConfig:(BMADConfigModel *)config;

/**
 * 获取配置类对象
 * @return 配置类BMADConfigModel实例
 */
+ (BMADConfigModel *)getConfig;

#pragma mark - 开屏广告
/**
* 显示开屏广告（不需要自己添加View）
* @param window App根window
* @param placeholder 加载开屏广告时的占位视图
* @param customView 显示在开屏广告底部的自定义视图（一般可以放上logo）
* @param timeout 超时时间（1-10秒）
* @param launch 是否是启动，从后台进入前台设置NO
* @param group 广告组，一般可以传@"s1"
*/
+ (UIView *)splashAdViewFromWindow:(UIWindow *)window delegate:(id<BMADSplashAdCallbackDelegate>)delegate placeHolder:(UIView *)placeholder customView:(UIView *)customView timeout:(CGFloat)timeout isLaunch:(BOOL)launch group:(NSString *)group;


#pragma mark - 插屏广告

/**
* 显示插屏广告
* 随机显示不同大小的插屏广告
* @param vc 广告展示基于的viewController
* @param delegate 回调代理
* @param group 广告组，一般可以传@"i1"
*/
+ (void)showInterstitialAdWithViewController:(UIViewController *)vc delegate:(id<BMADInterstitialAdCallbackDelegate>)delegate group:(NSString *)group;

#pragma mark - 横幅广告
/** 获取横幅广告加载器实例
* @return 横幅广告加载器实例
*/
+ (id<BMADBannerAdManagerProtocol>)bannerAdManager;

#pragma mark - 激励视频
/** 获取激励视频广告加载器实例
* @return 激励视频广告加载器实例
*/
+ (id<BMADRewardVideoAdManagerProtocol>)rewardVideoAdManager;

#pragma mark - 原生模板广告
/** 获取原生广告加载器实例
* @return 原生广告加载器实例
*/
+ (id<BMADNativeExpressAdManagerProtocol>)nativeExpressAdManager;

#pragma mark - Draw视频广告
/** 获取Draw视频广告加载器实例
* @return Draw视频广告加载器实例
*/
+ (id<BMADExpressDrawVideoAdManagerProtocol>)expressDrawVideoAdManager;
@end


