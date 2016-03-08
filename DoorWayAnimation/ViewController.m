//
//  ViewController.m
//  DoorWayAnimation
//
//  Created by Huang Hongsen on 3/4/16.
//  Copyright © 2016 cn.daniel. All rights reserved.
//

#import "ViewController.h"
#import "DoorWayRenderer.h"

@interface ViewController ()
@property (nonatomic, strong) DoorWayRenderer *renderer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)start:(id)sender {
    self.renderer = [[DoorWayRenderer alloc] init];
    UIImageView *fromView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    fromView.image = [UIImage imageNamed:@"fromImage.jpg"];
    UIImageView *toView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    toView.image = [UIImage imageNamed:@"toImage.jpg"];
    [self.renderer startDoorWayAnimationFromView:fromView toView:toView inView:self.view duration:1 timingFunction:NSBKeyframeAnimationFunctionEaseInOutCubic completion:nil];
}

@end
