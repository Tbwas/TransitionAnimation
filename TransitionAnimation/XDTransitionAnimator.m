//
//  XDTransitionAnimator.m
//  TransitionAnimation
//
//  Created by xindong on 17/7/26.
//  Copyright © 2017年 xindong. All rights reserved.
//

#import "XDTransitionAnimator.h"
#import <UIKit/UIKit.h>

#define kWindowWidth  [UIScreen mainScreen].bounds.size.width
#define kWindowHeight [UIScreen mainScreen].bounds.size.height

@interface XDTransitionAnimator ()<CAAnimationDelegate>

@property (nonatomic, strong) void(^animationComplete)(BOOL success);

@end

@implementation XDTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 2.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    /*
     The `snapshotViewAfterScreenUpdates` method will return a blank view on iPhone 7 simulator. Specific see https://forums.developer.apple.com/thread/63438.
     */
    UIView *snapshotView = [fromView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = fromView.frame;
    fromView.hidden = YES;
    
    /*
     @Note: containerView's subviews contain `fromView` by default, therefore we shouldn't call `[containerView addSubview:fromView]`.
     */
    [containerView addSubview:toView];
    [containerView addSubview:snapshotView];
    
    [self xd_configAnimation:containerView duration:[self transitionDuration:transitionContext]];
    
    self.animationComplete = ^(BOOL success) {
        BOOL animationCancelled = transitionContext.transitionWasCancelled;
        // If transition was cancelled by PercentDriveInteractive, we should restore it pass `NO`.
        [transitionContext completeTransition:!animationCancelled];
        [snapshotView removeFromSuperview];
        fromView.hidden = NO;
        if (animationCancelled) {
            NSLog(@"animation cancelled");
        } else {
            NSLog(@"animation compeleted");
        }
    };
}

- (void)xd_configAnimation:(UIView *)animationView duration:(NSTimeInterval)animationDuration {
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    translationAnimation.fromValue = @(kWindowHeight / 2); //center.point
    translationAnimation.toValue = @(3 * kWindowHeight / 2);
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1.0);
    scaleAnimation.toValue = @(0.2);
    
    CABasicAnimation *alpaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alpaAnimation.fromValue = @(1.0);
    alpaAnimation.toValue = @(0.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    animationGroup.animations = @[translationAnimation, scaleAnimation, alpaAnimation];
    animationGroup.duration = animationDuration;
    animationGroup.removedOnCompletion = NO;
    [animationView.layer addAnimation:animationGroup forKey:@"animation"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.animationComplete) {
        self.animationComplete(flag);
    }
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

@end
