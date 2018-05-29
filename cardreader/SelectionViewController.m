//
//  SelectionViewController.m
//  cardreader
//
//  Created by Noverio Joe on 29/05/18.
//  Copyright © 2018 ocbc. All rights reserved.
//

#import "SelectionViewController.h"
#import "ViewController.h"

@interface SelectionViewController (){
    BOOL isReadingEKTP;
}

@end

@implementation SelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)scanningEKTP:(id)sender {
    isReadingEKTP = true;
    [self performSegueWithIdentifier:@"SegueToScan" sender:nil];
}

- (IBAction)scanningNPWP:(id)sender {
    isReadingEKTP = false;
    [self performSegueWithIdentifier:@"SegueToScan" sender:nil];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueToScan"]){
        ViewController *nextVc = (ViewController*)segue.destinationViewController;
        nextVc.isReadingEktp = isReadingEKTP;
    }
}

@end
