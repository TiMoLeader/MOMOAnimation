//
//  TransitionAnimation.h
//  MoMoPoint
//
//  Created by fighting on 17/5/19.
//  Copyright © 2017年 李鹏举. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,TransitionType) {
    TransitionTypePresent = 0,  //presentView转场动画
    TransitionTypeDismiss   //dismissView转场动画
};

@interface TransitionAnimation : NSObject<UIViewControllerAnimatedTransitioning,CAAnimationDelegate>

+ (instancetype)transitionWithTransitionType:(TransitionType)type;


@end
