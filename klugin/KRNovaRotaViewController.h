//
//  KRNovaRotaViewController.h
//  klugrota
//
//  Created by Jader Belarmino on 20/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRNovaRotaViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITextField *origem;
@property (strong, nonatomic) IBOutlet UITextField *destino;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (IBAction)salvarRota:(id)sender;

@end
