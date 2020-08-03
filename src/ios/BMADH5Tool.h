//
//  BMADUniTool.h
//  BMADUniPlugin
//
//  Created by 兵伍 on 2020/5/28.
//  Copyright © 2020 兵伍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL BloomAD_plugin_debug = YES;

NS_ASSUME_NONNULL_BEGIN

@class BMADUniModule;

@interface BMADH5Tool : NSObject
//@property (nonatomic, strong) NSDictionary *splashInfo;
//@property (nonatomic, assign) NSInteger splashInterval;
//@property (nonatomic, strong, nullable) BMADUniModule *module;

+ (instancetype)sharedTool;
+ (void)setDebug:(BOOL)debug;
+ (void)log:(NSString *)format, ... ;
+ (BOOL)isInvalidString:(NSString *)s;
+ (UIViewController *)findCurrentShowingViewController;

+ (CGFloat)statusBarHeight;
@end

NS_ASSUME_NONNULL_END
