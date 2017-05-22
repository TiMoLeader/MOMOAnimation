//
//  TransitionAnimation.m
//  MoMoPoint
//
//  Created by fighting on 17/5/19.
//  Copyright © 2017年 李鹏举. All rights reserved.
//

#import "TransitionAnimation.h"

#define ANIMATION_DURATION 0.55

@interface TransitionAnimation ()

@property (nonatomic, assign) TransitionType type;

@property (nonatomic , strong)UIView * containerView;

@end

@implementation TransitionAnimation

+ (instancetype)transitionWithTransitionType:(TransitionType)type
{
    return [[self alloc]initWithTransitionType:type];
}

- (instancetype)initWithTransitionType:(TransitionType)type
{
    if(self = [super init]){
        _type = type;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return ANIMATION_DURATION;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    switch (_type) {
        case TransitionTypePresent:
        {
            [self presentAnimation:transitionContext];
        }
            break;
        case TransitionTypeDismiss:
        {
            [self dismissAnimation:transitionContext];
        }
            break;
            
        default:
            break;
    }
}

- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.containerView = [transitionContext containerView];
    [self.containerView addSubview:toVC.view];
    
    NSArray * cyclePathArray = [self createCyclePath];
    
    CAShapeLayer * maskLayer = [self createTransitionAnimationWithFromValue:cyclePathArray[0] andToValue:cyclePathArray[1] andTContext:transitionContext];
    toVC.view.layer.mask = maskLayer;
}

- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    self.containerView = [transitionContext containerView];
    [self.containerView insertSubview:toView atIndex:0];
    
    NSArray * cyclePathArray = [self createCyclePath];
    
    CAShapeLayer * maskLayer = [self createTransitionAnimationWithFromValue:cyclePathArray[1] andToValue:cyclePathArray[0] andTContext:transitionContext];
    
    fromVC.view.layer.mask = maskLayer;
}

- (NSArray *)createCyclePath
{
    //小圆path
    UIBezierPath *smallCycle = [UIBezierPath bezierPathWithArcCenter:self.containerView.center radius:10 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    //大圆path
    CGFloat radius = sqrtf(pow(self.containerView.frame.size.width/2.0, 2) + pow(self.containerView.frame.size.width/2.0, 2));
    UIBezierPath *bigCycle = [UIBezierPath bezierPathWithArcCenter:self.containerView.center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    return @[smallCycle,bigCycle];
}

- (CAShapeLayer *)createTransitionAnimationWithFromValue:(UIBezierPath *)fromValue andToValue:(UIBezierPath *)toValue andTContext:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animation];
    maskLayerAnimation.delegate = self;
    maskLayerAnimation.fromValue = (__bridge id _Nullable)(fromValue.CGPath);
    maskLayerAnimation.toValue = (__bridge id _Nullable)(toValue.CGPath);
    maskLayerAnimation.duration = [self transitionDuration:transitionContext];
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [maskLayerAnimation setValue:transitionContext forKey:@"transitionContext"];
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    return maskLayer;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.containerView = nil;
    switch (_type) {
        case TransitionTypePresent:{
            id<UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
            [transitionContext completeTransition:YES];
            [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
        }
            break;
            
        case TransitionTypeDismiss:{
            id<UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            if ([transitionContext transitionWasCancelled]) {
                [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
            }
        }
            break;
        default:
            break;
    }
}
@end
