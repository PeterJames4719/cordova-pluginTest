//
//  BloomAdPlugin.m
//  TestDemo
//
//  Created by 兵伍 on 2020/8/3.
//

#import "BloomAdPlugin.h"
#import <BloomADSDK/BloomADSDK.h>
#import "BMADH5Tool.h"
#import "LaunchPlaceHolder.h"
#import "SplashLogoView.h"
#import "AppDelegate.h"

@interface BloomAdPlugin()<BMADRewardVideoAdCallbackDelegate, BMADInterstitialAdCallbackDelegate, BMADBannerAdCallbackDelegate, BMADSplashAdCallbackDelegate, NSXMLParserDelegate>

@property (nonatomic, strong) NSString *rvCallback;
@property (nonatomic, strong) NSString *interCallback;

@property (nonatomic, strong) id<BMADBannerAdManagerProtocol> bannerAd;
@property (nonatomic, strong) id<BMADRewardVideoAdManagerProtocol> rewardVideo;

@property (nonatomic, strong) NSMutableDictionary *bannerCallbackDict;
@property (nonatomic, strong) NSMutableDictionary *bannerViewDict;
@property (nonatomic, strong) UIView *splashView;

@property (nonatomic, strong) NSXMLParser *configParser;
@property (nonatomic, strong) NSString *bloomAdElement;
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *splashLogo;
@end

@implementation BloomAdPlugin

- (void)setupBloomADSDK {
    
    // 创建初始化配置实例
    BMADConfigModel *config = [[BMADConfigModel alloc] init];
    
    // 渠道id，必填(由我司分配），下面的是测试用
    //config.appId = @"ba0063bfbc1a5ad878";
    config.appId = self.appId;
    
    /***********关于userId的设置**********/
    // userId为可选参数，但是设置userId可以方便追查问题，请接入方按下面步骤设置
    
    // 1.如果已登录，可以直接在初始化的时候设置userId
    // config.userId = @"userId007";
    
    // 2.如果未登录，可以在登录成功后获取配置，再设置userId
    // BMADConfigModel *config = [BloomADSDKApi getConfig];
    // config.userId = @"userId";
    
    // 3.退出登录后，置空userId
    // BMADConfigModel *config = [BloomADSDKApi getConfig];
    // config.userId = nil;
    
    // 初始化SDK
    BOOL result = [BloomADSDKApi setupWithConfig:config];
    
    BMADConfigModel *config2 = [BloomADSDKApi getConfig];
    NSLog(@"userId:%@", config2.userId);
    NSLog(@"BloomADSDK setup success:%d", result);
    NSLog(@"BloomADSDK version:%@", [BloomADSDKApi sdkVersion]);
}

- (void)showSplashAdFromLaunch:(BOOL)launch {
    NSString *splashLogoPath = self.splashLogo;
    if ([splashLogoPath hasPrefix:@"www/"]) {
        splashLogoPath = [[splashLogoPath componentsSeparatedByString:@"www/"] lastObject];
    }
    NSString *pa = [self.commandDelegate pathForResource:splashLogoPath];
    UIImage *logo = [UIImage imageWithContentsOfFile:pa];
    
    UIWindow *window = ((AppDelegate *)[self appDelegate]).window;
    
    // 开屏占位视图(加载开屏广告时的占位视图)
    LaunchPlaceHolder *placeHolder = [LaunchPlaceHolder loadViewFromXib];
    placeHolder.frame = window.bounds;
    
    // 开屏自定义logo视图(显示在开屏广告底部)
    SplashLogoView *logoView = [SplashLogoView loadViewFromXib];
    logoView.frame = CGRectMake(0, 0, window.bounds.size.width, floor(window.bounds.size.height/4.0));
    logoView.logoImgView.image = logo;
    
    // 加载开屏
    self.splashView = [BloomADSDKApi splashAdViewFromWindow:window delegate:self placeHolder:placeHolder customView:logoView timeout:3 isLaunch:launch group:@"s1"];
}

#pragma mark - 开屏广告回调

- (void)bm_ad_splashAdCallbackWithEvent:(BMADSplashAdCallbackEvent)event error:(NSError *)error andInfo:(NSDictionary *)info {
    NSLog(@"splash event:%zd, error:%@, info:%@", event, error, info);
    
    if (event == BMADSplashAdCallbackEventAdLoadSuccess) {
        // 保存上次开屏时间
        double ts = [[NSDate date] timeIntervalSince1970];
        NSLog(@"splash -> save ts:%lf", ts);
        [[NSUserDefaults standardUserDefaults] setDouble:ts forKey:@"AppLastSplashShownTimestamp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 移除开屏
    if (event == BMADSplashAdCallbackEventAdDidClose) {
        [self.splashView removeFromSuperview];
        self.splashView = nil;
    }
}

- (void)handleApplicationWillEnterForeground:(NSNotification *)notification {
    double last = [[NSUserDefaults standardUserDefaults] doubleForKey:@"AppLastSplashShownTimestamp"];
    double ts = [[NSDate date] timeIntervalSince1970];
    double delt = ts - last;
    
    NSLog(@"splash -> interval:%lf", delt);

    NSInteger interval = 10;// 3分钟间隔展示开屏
    if (interval <= 0) {
        return;
    }
    
    if (delt >= interval) {
        NSLog(@"splash -> should show");
        [self showSplashAdFromLaunch:NO];
    }
}

- (void)pluginInitialize {
    NSLog(@"BloomAdPlugin -> pluginInitialize");
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self parseConfig];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    });
}

- (void)dealloc {
    NSLog(@"BloomAdPlugin -> dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)parseConfig {
    UIWindow *window = ((AppDelegate *)[self appDelegate]).window;
    CDVViewController *vc = (id)window.rootViewController;
    if ([vc isKindOfClass:[CDVViewController class]]) {
        NSString *path = [vc performSelector:@selector(configFilePath)];
        
        NSURL* url = [NSURL fileURLWithPath:path];

        self.configParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        if (self.configParser == nil) {
            NSLog(@"Failed to initialize XML parser.");
            return;
        }
        self.configParser.delegate = self;
        [self.configParser parse];
    }
}



#pragma mark XML

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict
{
    if ([elementName isEqualToString:@"bloom-ad"]) {
        self.bloomAdElement = elementName;
        NSLog(@"bloom-ad config:%@", attributeDict);
    } else if (self.bloomAdElement && [elementName isEqualToString:@"param"]) {
        NSString *name = attributeDict[@"name"];
        NSString *value = attributeDict[@"value"];
        if ([name isEqualToString:@"appId"]) {
            self.appId = value;
        } else if ([name isEqualToString:@"splashLogo"]) {
            self.splashLogo = value;
        }
    }
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName
{
    if ([elementName isEqualToString:@"bloom-ad"]) {
        [self.configParser abortParsing];
        self.bloomAdElement = nil;
        // 初始化广告SDK
        [self setupBloomADSDK];
            
        // 显示开屏
        [self showSplashAdFromLaunch:YES];
    }
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
        [BMADH5Tool log:@"setUserId:%@", uid];
    } else {
        BMADConfigModel *config = [BloomADSDKApi getConfig];
        config.userId = nil;
        [BMADH5Tool log:@"setUserId:nil"];
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

@end
