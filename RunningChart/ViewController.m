//
//  ViewController.m
//  RunningChart
//
//  Created by lixin on 5/26/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "ViewController.h"
#import "PulsingChart.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet PulsingChart *chartViewBasic;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)putValueTap:(id)sender {
//    for ( int i = 0; i < 5; i ++) {
    float randomValue = (float)(arc4random()%10000)/10000.0f;
    [_chartViewBasic putNextValue:randomValue];
//    }
}
- (IBAction)pauseTap:(id)sender {
    [_chartViewBasic pause];
}
- (IBAction)resumeTap:(id)sender {
    [_chartViewBasic run];
}

@end
