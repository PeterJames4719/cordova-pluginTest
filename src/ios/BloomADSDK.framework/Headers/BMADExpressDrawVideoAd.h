//
//  BMADExpressDrawVideoAd.h
//  BMADSDK
//
//  Created by 兵伍 on 2020/4/7.
//  Copyright © 2020 兵伍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BloomADSDKProtocols.h"

//#import "BMADErrorHandler.h"

@interface BMADExpressDrawVideoAd : NSObject<BMADExpressDrawVideoAdProtocol>
@property (nonatomic, strong) UIView *adView;
- (void)render;
- (void)unbind;
@end

@class BMADIDConfig;
@protocol BMADExpressDrawVideoAdImplementorCallback <NSObject>
- (void)drawVideoAdFinishLoad:(NSArray *)ads error:(NSError *)error config:(BMADIDConfig *)config;
@end
