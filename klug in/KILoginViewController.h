//
//  KILoginViewController.h
//  klug in
//
//  Created by Jader Belarmino on 25/11/13.
//  Copyright (c) 2013 Velum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KILoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (void)loginFailed;
@end
