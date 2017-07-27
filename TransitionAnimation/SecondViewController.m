//
//  FirstViewController.m
//  TransitionAnimation
//
//  Created by xindong on 17/7/26.
//  Copyright © 2017年 xindong. All rights reserved.
//

#import "SecondViewController.h"
#import "XDTransitionAnimator.h"

@interface SecondViewController ()<UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, assign) BOOL shouldComplete;

@property (nonatomic, assign) CGPoint firstTouchedAbsolutePoint;
@property (nonatomic, assign) CGPoint firstTouchedRelativePoint;

@end

@implementation SecondViewController

- (instancetype)init {
    if (self = [super init]) {
        self.transitioningDelegate = self;
        /*
         @Note: Don't forget call this method, otherwise current viewController's view will be still in the view-hierarchy, and won't dealloc when current viewController dimissed.
         */
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"SecondViewController";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = (CGRect){0, 28, 375, 31};
    [self.view addSubview:titleLabel];
    
    [self xd_addPanGesture];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        self.firstTouchedAbsolutePoint = self.view.center;
        self.firstTouchedRelativePoint = [panGesture translationInView:panGesture.view];
    }
    return YES;
}

#pragma mark -

- (void)xd_addPanGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(xd_handleGesture:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

- (void)xd_handleGesture:(UIPanGestureRecognizer *)gesture {
    // The first point touched is {0, 0}.
    CGPoint translationPoint = [gesture translationInView:gesture.view];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGFloat fractionY = translationPoint.y / self.view.frame.size.height;
            self.shouldComplete = fractionY > 0.3;
            [self.interactiveTransition updateInteractiveTransition:fractionY];
            
            CGFloat xOffset = translationPoint.x - self.firstTouchedRelativePoint.x;
            CGFloat yOffset = translationPoint.y - self.firstTouchedRelativePoint.y;
            NSLog(@"xOffset: %.2f   yOffset: %0.2f", xOffset, yOffset);
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            [self xd_gestureEndHandled];
            break;
            
        case UIGestureRecognizerStateCancelled:
            [self xd_gestureEndHandled];
            break;
            
        default:
            break;
    }
}

- (void)xd_gestureEndHandled {
    if (self.shouldComplete) {
        [self.interactiveTransition finishInteractiveTransition];
    } else {
        [self.interactiveTransition cancelInteractiveTransition];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [XDTransitionAnimator new];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveTransition ?: nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
