//
//  DoorWayRenderer.h
//  DoorWayAnimation
//
//  Created by Huang Hongsen on 3/4/16.
//  Copyright © 2016 cn.daniel. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NSBKeyframeAnimationFunctions.h"

@interface DoorWayRenderer : NSObject<GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *animationView;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic, strong) void(^completion)(void);
@property (nonatomic) NSBKeyframeAnimationFunction timingFunction;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) CGFloat percent;

- (void) startDoorWayAnimationFromView:(UIView *)fromView toView:(UIView *)toView inView:(UIView *)containerView duration:(NSTimeInterval)duration;

- (void) startDoorWayAnimationFromView:(UIView *)fromView toView:(UIView *)toView inView:(UIView *)containerView duration:(NSTimeInterval)duration completion:(void(^)(void))completion;

- (void) startDoorWayAnimationFromView:(UIView *)fromView toView:(UIView *)toView inView:(UIView *)containerView duration:(NSTimeInterval)duration timingFunction:(NSBKeyframeAnimationFunction)timingFunction completion:(void(^)(void))completion;

@end
