//
//  ViewController.m
//  OpenGL-ES2.0
//
//  Created by TuLigen on 16/9/21.
//  Copyright © 2016年 TuLigen. All rights reserved.
//

#import "ViewController.h"
#import "ES2.0/ESRenderView.h"

@interface ViewController ()
{
    ESRenderView *_renderView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _renderView = [[ESRenderView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_renderView];
}
-(void) viewWillDisappear:(BOOL)animated
{
    [_renderView viewWillDisappear];
}
- (IBAction)userCamera:(id)sender {
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)popListUI:(id)sender {
    
}
- (IBAction)popView:(id)sender {
}

@end
