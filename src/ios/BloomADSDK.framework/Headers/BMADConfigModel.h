//
//  BMADConfigModel.h
//  BMADSDK
//
//  Created by 兵伍 on 2019/3/15.
//  Copyright © 2019 兵伍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BMADConfigModel : NSObject
// 渠道标示（必填）
@property (nonatomic, strong) NSString *appId;
// 接入方App用户id
@property (nonatomic, strong) NSString *userId;

@end


