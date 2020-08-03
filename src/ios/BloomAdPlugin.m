//
//  BloomAdPlugin.m
//  TestDemo
//
//  Created by 兵伍 on 2020/8/3.
//

#import "BloomAdPlugin.h"
#import <BloomADSDK/BloomADSDK.h>
#import "BMADH5Tool.h"

@interface BloomAdPlugin()<BMADRewardVideoAdCallbackDelegate, BMADInterstitialAdCallbackDelegate, BMADBannerAdCallbackDelegate>

@property (nonatomic, strong) NSString *rvCallback;
@property (nonatomic, strong) NSString *interCallback;

@property (nonatomic, strong) id<BMADBannerAdManagerProtocol> bannerAd;
@property (nonatomic, strong) id<BMADRewardVideoAdManagerProtocol> rewardVideo;

@property (nonatomic, strong) NSMutableDictionary *bannerCallbackDict;
@property (nonatomic, strong) NSMutableDictionary *bannerViewDict;
@end

@implementation BloomAdPlugin

- (void)pluginInitialize {
    NSLog(@"BloomAdPlugin -> pluginInitialize");
}

- (void)dealloc {
    NSLog(@"BloomAdPlugin -> dealloc");
}

#pragma mark - Getter and Setter

- (NSMutableDictionary *)bannerCallbackDict {
    if (!_bannerCallbackDict) {
        _bannerCallbackDict = [NSMutableDictionary dictionary];
    }
    return _bannerCallbackDict;
}

- (NSMutableDictionary *)bannerViewDict {
    if (!_bannerViewDict) {
        _bannerViewDict = [NSMutableDictionary dictionary];
    }
    return _bannerViewDict;
}

#pragma mark - init

- (void)setUserId:(CDVInvokedUrlCommand *)method {
    NSString *uid = method.arguments[0];
    if ([uid isKindOfClass:[NSString class]]) {
        BMADConfigModel *config = [BloomADSDKApi getConfig];
        config.userId = uid;
    }
}

#pragma mark - outer methods

- (void)showRewardVideoAd:(CDVInvokedUrlCommand *)method {
    
    self.rvCallback = method.callbackId;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:method.arguments[0] forKey:@"unitId"];
    
    [self _showRewardVideoAd:info];
}

- (void)showBannerAd:(CDVInvokedUrlCommand *)method {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    NSString *callback = method.callbackId;
    [info setObject:method.arguments[0] forKey:@"unitId"];
    [info setObject:method.arguments[1] forKey:@"layout"];
    [info setObject:method.arguments[2] forKey:@"margins"];

    [self _showBannerAd:info callback:callback];
}

- (void)destroyBannerAd:(CDVInvokedUrlCommand *)method {
    [self _destroyBannerAd:@{@"unitId":method.arguments[0]}];
}

- (void)showInterstitialAd:(CDVInvokedUrlCommand *)method {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    self.interCallback = method.callbackId;
    [info setObject:method.arguments[0] forKey:@"unitId"];
    
    [self _showInterstitialAd:info];
}

#pragma mark - inner methods

- (void)_showRewardVideoAd:(NSDictionary *)info {
    
    if (!_rewardVideo) {
        _rewardVideo = [BloomADSDKApi rewardVideoAdManager];
    }
    
    NSString *group = info[@"unitId"];
    if ([BMADH5Tool isInvalidString:group]) {
        group = @"rv1";
    }
    NSInteger timeout = [info[@"timeout"] integerValue];
    if (timeout <= 0) {
        timeout = 10;
    }
    [_rewardVideo loadRewardVideoWithViewController:[BMADH5Tool findCurrentShowingViewController] delegate:self timeout:timeout group:group];
}

- (void)_showBannerAd:(NSDictionary *)info callback:(NSString *)callback {
    [BMADH5Tool log:@"showBannerAd:%@", info];

    if (!_bannerAd) {
        _bannerAd = [BloomADSDKApi bannerAdManager];
    }
    
    NSString *group = info[@"unitId"];
    if ([BMADH5Tool isInvalidString:group]) {
        group = @"b1";
    }
    
    if (self.bannerCallbackDict[group]) {
        
    } else {
        if (callback) {
            [self.bannerCallbackDict setObject:callback forKey:group];
        }
    }
    
    NSInteger interval = [info[@"interval"] integerValue];
//    if (interval < 30) {
//        interval = 30;
//    }
    
    CGFloat ratio = [info[@"ratio"] floatValue];
    if (ratio <= 0) {
        ratio = 6.4;
    }
    
    NSArray *margins = info[@"margins"];
    CGFloat left = [margins[0] floatValue];
    CGFloat top = [margins[1] floatValue];
    CGFloat right = [margins[2] floatValue];
    CGFloat bottom = [margins[3] floatValue];
    NSString *layout = info[@"layout"];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat statusBarHeight = [BMADH5Tool statusBarHeight];
    
    CGFloat width, height;
    width = screenSize.width - left - right;
    height = width / ratio;
    
    CGRect frame;
    if ([layout isEqualToString:@"top"]) {
        top += statusBarHeight;
        frame = CGRectMake(left, top, width, height);
    } else {
        frame = CGRectMake(left, screenSize.height - bottom - height, width, height);
    }
    
    [_bannerAd loadBannerAdWithFrame:frame viewController:[BMADH5Tool findCurrentShowingViewController] delegate:self interval:interval group:group];
}

- (void)_destroyBannerAd:(NSDictionary *)info {
    [BMADH5Tool log:@"destroyBannerAd:%@", info];
    
    NSString *group = info[@"unitId"];
    if ([BMADH5Tool isInvalidString:group]) {
        group = @"b1";
    }
    
    UIView *adView = self.bannerViewDict[group];
    if (adView) {
        [_bannerAd removeBannerAd:adView];
        if (group) {
            [self.bannerViewDict removeObjectForKey:group];
        }
        [BMADH5Tool log:@"destroyBannerAd:1"];
        
    } else {
        [BMADH5Tool log:@"destroyBannerAd:0"];
    }
}

- (void)_showInterstitialAd:(NSDictionary *)info {
    
    NSString *group = info[@"unitId"];
    if ([BMADH5Tool isInvalidString:group]) {
        group = @"i1";
    }
    [BloomADSDKApi showInterstitialAdWithViewController:[BMADH5Tool findCurrentShowingViewController] delegate:self group:group];
    
}

#pragma mark - AdDelegate
/*
- (void)bm_ad_splashAdCallbackWithEvent:(BMADSplashAdCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info {
    
    BOOL keep = NO;
    if (event == BMADSplashAdCallbackEventNoAd ||
        event == BMADSplashAdCallbackEventAdLoadError ||
        event == BMADSplashAdCallbackEventAdDidClose) {
        //keep = NO;
        [self.splashView removeFromSuperview];
        self.splashView = nil;
        [BMADUniTool sharedTool].module = nil;
    } else if (event == BMADSplashAdCallbackEventAdLoadSuccess) {
        // 保存上次开屏时间
        double ts = [[NSDate date] timeIntervalSince1970];
        [BMADUniTool log:@"reshow splash -> save ts:%lf", ts];
        [[NSUserDefaults standardUserDefaults] setDouble:ts forKey:@"BMADUniSplashAdLastShowKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (self.splashCallback) {
        NSMutableDictionary *result = [info mutableCopy];
        NSString *eventString = [[self class] splash_eventStringWithEvent:event];
        if (eventString) {
            [result setObject:eventString forKey:@"event"];
            if (error) {
                NSString *msg = error.userInfo[NSLocalizedDescriptionKey]?: @"";
                [result setObject:@(error.code) forKey:@"code"];
                [result setObject:msg forKey:@"msg"];
            }
            self.splashCallback(result, keep);
        }
    }
}
*/

- (void)bm_ad_rewardVideoCallbackWithEvent:(BMADRewardVideoCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info {
    BOOL keep = YES;
    if (event == BMADRewardVideoCallbackEventAdLoadError || event == BMADRewardVideoCallbackEventAdDidClose) {
        keep = NO;
    }
    
    if (self.rvCallback) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:info];
        [result setObject:[[self class] rewardVideo_eventStringWithEvent:event] forKey:@"event"];
        if (error) {
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey]?: @"";
            [result setObject:@(error.code) forKey:@"code"];
            [result setObject:msg forKey:@"msg"];
        }
        
        CDVPluginResult *r = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        r.keepCallback = @(keep);
        [self.commandDelegate sendPluginResult:r callbackId:self.rvCallback];
    }
}

- (void)bm_ad_interstitialAdCallbackWithEvent:(BMADInterstitialAdCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info {
    BOOL keep = YES;
    if (event == BMADInterstitialAdCallbackEventAdLoadError) {
        keep = NO;
    }
    
    if (self.interCallback) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:info];
        
        [result setObject:[[self class] intersticial_eventStringWithEvent:event] forKey:@"event"];
        if (error) {
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey]?: @"";
            [result setObject:@(error.code) forKey:@"code"];
            [result setObject:msg forKey:@"msg"];
        }
        
        CDVPluginResult *r = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        r.keepCallback = @(keep);
        [self.commandDelegate sendPluginResult:r callbackId:self.interCallback];
    }
}

- (void)bm_ad_bannerAdView:(UIView<BMADBannerAdViewProtocol> *)adView callbackWithEvent:(BMADBannerAdCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info {
    NSString *group = adView.group;
    
    BOOL keep = YES;
    if (event == BMADBannerAdCallbackEventAdLoadSuccess) {
        if (!adView.superview) {
            UIViewController *top = [BMADH5Tool findCurrentShowingViewController];
            [top.view addSubview:adView];
            if (group) {
                [self.bannerViewDict setObject:adView forKey:group];
            }
        }
    } else if (event == BMADBannerAdCallbackEventAdDidClose) {
        [_bannerAd removeBannerAd:adView];
        if (group) {
            [self.bannerViewDict removeObjectForKey:group];
        }
    }
    
    
    NSString *callback = self.bannerCallbackDict[group];
    if (callback) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:info];
        [result setObject:[[self class] intersticial_eventStringWithEvent:event] forKey:@"event"];
        if (error) {
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey]?: @"";
            [result setObject:@(error.code) forKey:@"code"];
            [result setObject:msg forKey:@"msg"];
        }
        
        CDVPluginResult *r = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        r.keepCallback = @(keep);
        [self.commandDelegate sendPluginResult:r callbackId:callback];
    }
    
}

#pragma mark - EventMapper

+ (NSString *)splash_eventStringWithEvent:(NSInteger)event {
    switch (event) {
        case BMADSplashAdCallbackEventAdLoadSuccess:
            //return @"onAdLoad";
            return nil;
            break;
        case BMADSplashAdCallbackEventAdWillVisible:
            //return @"onAdShow";
            return nil;
            break;
        case BMADSplashAdCallbackEventAdDidClick:
            //return @"onAdClick";
            return nil;
            break;
        case BMADSplashAdCallbackEventAdDidClose:
            return @"onAdDismiss";
            break;
        default:
            return @"onError";
            break;
    }
}

+ (NSString *)rewardVideo_eventStringWithEvent:(NSInteger)event {
    switch (event) {
        case BMADRewardVideoCallbackEventAdLoadSuccess:
            return @"onAdLoad";
            break;
        case BMADRewardVideoCallbackEventAdDidLoadVideo:
            return @"onVideoCached";
            break;
        case BMADRewardVideoCallbackEventAdWillVisible:
            return @"onAdShow";
            break;
        case BMADRewardVideoCallbackEventAdDidClick:
            return @"onAdClick";
            break;
        case BMADRewardVideoCallbackEventAdRewardSuccess:
            return @"onReward";
            break;
        case BMADRewardVideoCallbackEventAdPlayFinish:
            return @"onVideoComplete";
            break;
        case BMADRewardVideoCallbackEventAdDidClose:
            return @"onAdClose";
            break;
        default:
            return @"onError";
            break;
    }
}

+ (NSString *)intersticial_eventStringWithEvent:(NSInteger)event {
    switch (event) {
        case BMADInterstitialAdCallbackEventAdLoadSuccess:
            return @"onAdLoad";
            break;
        case BMADInterstitialAdCallbackEventAdWillVisible:
            return @"onAdShow";
            break;
        case BMADInterstitialAdCallbackEventAdDidClick:
            return @"onAdClick";
            break;
        case BMADInterstitialAdCallbackEventAdDidClose:
            return @"onAdClose";
            break;
        default:
            return @"onError";
            break;
    }
}

//- (void)showRewardVideoAd:(CDVInvokedUrlCommand*)command {
//    NSLog(@"BloomAdPlugin -> showRewardVideoAd");
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"onLoad"}];
//
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//}
//
//- (void)showBannerAd:(CDVInvokedUrlCommand*)command {
//    NSLog(@"BloomAdPlugin -> showBannerAd");
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"onLoad"}];
//
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//}
//
//- (void)showInterstitialAd:(CDVInvokedUrlCommand*)command {
//    NSLog(@"BloomAdPlugin -> showInterstitialAd");
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"onLoad"}];
//
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//}
@end
