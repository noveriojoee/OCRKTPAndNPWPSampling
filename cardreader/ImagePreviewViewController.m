//
//  ImagePreviewViewController.m
//  cardreader
//
//  Created by Noverio Joe on 29/05/18.
//  Copyright © 2018 ocbc. All rights reserved.
//

#import "ImagePreviewViewController.h"

@interface ImagePreviewViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet UITextView *ResultText;

@end

@implementation ImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.ImageView setImage:self.ImagePreview];
    [self.ResultText setText:self.textResult];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
