//
//  BloomADSDKCallbackDelegates.h
//  BloomADSDK
//
//  Created by 兵伍 on 2020/5/23.
//  Copyright © 2020 兵伍. All rights reserved.
//
#import "BloomADSDKProtocols.h"

#ifndef BloomADSDKCallbackDelegates_h
#define BloomADSDKCallbackDelegates_h

// 激励视频广告回调事件
typedef NS_ENUM(NSInteger, BMADRewardVideoCallbackEvent) {
    BMADRewardVideoCallbackEventAdLoadSuccess,       // 加载成功
    BMADRewardVideoCallbackEventAdLoadError,         // 加载失败
    BMADRewardVideoCallbackEventAdDidLoadVideo,      // 视频下载成功
    BMADRewardVideoCallbackEventAdWillVisible,       // 即将展现
    BMADRewardVideoCallbackEventAdDidClick,          // 点击广告
    BMADRewardVideoCallbackEventAdPlayFinish,        // 播放结束
    BMADRewardVideoCallbackEventAdPlayError,         // 播放出错
    BMADRewardVideoCallbackEventAdDidClose,          // 点击关闭
    BMADRewardVideoCallbackEventAdRewardSuccess,     // 奖励成功
};

// 开屏广告回调事件
typedef NS_ENUM(NSInteger, BMADSplashAdCallbackEvent) {
    BMADSplashAdCallbackEventNoAd,               // 没有广告
    BMADSplashAdCallbackEventAdLoadSuccess,      // 加载成功
    BMADSplashAdCallbackEventAdLoadError,        // 加载出错
    BMADSplashAdCallbackEventAdWillVisible,      // 即将展现
    BMADSplashAdCallbackEventAdDidClick,         // 点击广告
    BMADSplashAdCallbackEventAdDidClose,         // 已经关闭
};

// Banner广告回调事件
typedef NS_ENUM(NSInteger, BMADBannerAdCallbackEvent) {
    BMADBannerAdCallbackEventAdLoadSuccess,      // 加载成功
    BMADBannerAdCallbackEventAdLoadError,        // 加载出错
    BMADBannerAdCallbackEventAdWillVisible,      // 即将展现
    BMADBannerAdCallbackEventAdDidClick,         // 点击广告
    BMADBannerAdCallbackEventAdDidClose,         // 点击关闭
};

// banner广告尺寸
typedef NS_ENUM(NSInteger, BMADBannerAdRatio) {
    BMADBannerAdRatio_640x100,
    BMADBannerAdRatio_600x150,
    BMADBannerAdRatio_600x300,
    BMADBannerAdRatio_600x400
};

// 插屏广告回调事件
typedef NS_ENUM(NSInteger, BMADInterstitialAdCallbackEvent) {
    BMADInterstitialAdCallbackEventAdLoadSuccess,      // 加载成功
    BMADInterstitialAdCallbackEventAdLoadError,        // 加载出错
    BMADInterstitialAdCallbackEventAdWillVisible,      // 即将展现
    BMADInterstitialAdCallbackEventAdDidClick,         // 点击广告
    BMADInterstitialAdCallbackEventAdDidClose,         // 点击关闭
};

// 插屏广告尺寸
typedef NS_ENUM(NSInteger, BMADInterstitialAdSize) {
    BMADInterstitialAdSize_random,
    BMADInterstitialAdSize_small,
    BMADInterstitialAdSize_middle,
    BMADInterstitialAdSize_big,
};

typedef NS_ENUM(NSInteger, BMADPlayerPlayState) {
    BMADPlayerStateFailed    = 0,
    BMADPlayerStateBuffering = 1,
    BMADPlayerStatePlaying   = 2,
    BMADPlayerStateStopped   = 3,
    BMADPlayerStatePause     = 4,
    BMADPlayerStateDefalt    = 5
};

#pragma mark - 开屏广告回调
@protocol BMADSplashAdCallbackDelegate <NSObject>
@optional
/**
* SDK 开屏广告回调接口
* @param event BMADSplashAdCallbackEvent枚举类型
* @param error 错误信息
* @param info  包含 id
*
*/
- (void)bm_ad_splashAdCallbackWithEvent:(BMADSplashAdCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info;
@end

#pragma mark - 激励视频广告回调
@protocol BMADRewardVideoAdCallbackDelegate <NSObject>
/**
 * SDK 激励视频广告回调接口
 * @param event BMADRewardVideoCallbackEvent枚举类型
 * @param error 错误信息
 * @param info  包含 id
 *
 */
- (void)bm_ad_rewardVideoCallbackWithEvent:(BMADRewardVideoCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info;

@end

#pragma mark- 横幅广告回调
@protocol BMADBannerAdCallbackDelegate <NSObject>
@optional
/**
* SDK 横幅广告回调接口
* @param event BMADBannerAdCallbackEvent枚举类型
* @param error 错误信息
* @param info  包含 id
*
*/
- (void)bm_ad_bannerAdView:(UIView<BMADBannerAdViewProtocol> *)adView callbackWithEvent:(BMADBannerAdCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info;
@end

#pragma mark - 插屏广告回调
@protocol BMADInterstitialAdCallbackDelegate <NSObject>
@optional
/**
* SDK 插屏广告回调接口
* @param event BMADInterstitialAdCallbackEvent枚举类型
* @param error 错误信息
* @param info  包含 id
*
*/
- (void)bm_ad_interstitialAdCallbackWithEvent:(BMADInterstitialAdCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info;
@end

#pragma mark - 原生模板广告回调
@protocol BMADNativeExpressAdDelegete <NSObject>
@required
// 广告加载成功/失败
- (void)bm_ad_nativeExpressAdManager:(id<BMADNativeExpressAdManagerProtocol>)manager didFinishLoad:(NSArray<id<BMADNativeExpressAdProtocol>> *)ads error:(NSError *)error;

@optional

// 渲染成功
- (void)bm_ad_nativeExpressAdViewRenderSuccess:(id<BMADNativeExpressAdProtocol>)ad;

// 渲染失败
- (void)bm_ad_nativeExpressAdViewRenderFail:(id<BMADNativeExpressAdProtocol>)ad;

// 广告展示
- (void)bm_ad_nativeExpressAdViewWillShow:(id<BMADNativeExpressAdProtocol>)ad;

// 点击广告
- (void)bm_ad_nativeExpressAdViewClicked:(id<BMADNativeExpressAdProtocol>)ad;

// 点击关闭
- (void)bm_ad_nativeExpressAdViewClosed:(id<BMADNativeExpressAdProtocol>)ad reason:(NSString *)reason;
@end

#pragma mark - Draw视频广告回调
@protocol BMADExpressDrawVideoAdCallbackDelegate <NSObject>
@required
// 广告加载成功/失败
- (void)bm_ad_drawVideoAdManager:(id<BMADExpressDrawVideoAdManagerProtocol>)manager didFinishLoad:(NSArray<id<BMADExpressDrawVideoAdProtocol>> *)ads error:(NSError *)error;

@optional
// 广告即将展现
- (void)bm_ad_drawVideoAdViewWillShow:(NSString *)adId;

// 广告点击
- (void)bm_ad_drawVideoAdViewDidClick:(NSString *)adId;

// 视频播放状态改变
- (void)bm_ad_drawVideoAdView:(NSString *)adId stateDidChanged:(BMADPlayerPlayState)playerState;

// 视频播放结束
- (void)bm_ad_drawVideoAdPlayerDidPlayFinish:(NSString *)adId error:(NSError *)error;
@end

#endif /* BloomADSDKCallbackDelegates_h */
