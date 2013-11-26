//
//  KILoginViewController.m
//  klug in
//
//  Created by Jader Belarmino on 25/11/13.
//  Copyright (c) 2013 Velum. All rights reserved.
//

#import "KILoginViewController.h"
#import "KIAppDelegate.h"

@interface KILoginViewController ()

@end

@implementation KILoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)performLogin:(id)sender {
    [self.spinner startAnimating];
    
    KIAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}
- (void)loginFailed
{
    // User switched back to the app without authorizing. Stay here, but
    // stop the spinner.
    [self.spinner stopAnimating];
}

@end
