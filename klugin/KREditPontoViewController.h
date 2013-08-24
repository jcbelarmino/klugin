//
//  KREditPontoViewController.h
//  klugin
//
//  Created by Jader Belarmino on 14/07/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PontoRota.h"

@interface KREditPontoViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UILabel *valTipoMarcador;
@property (strong, nonatomic) IBOutlet UITextField *valMarcador;
@property (strong, nonatomic) IBOutlet UITextField *valLatitude;
@property (strong, nonatomic) IBOutlet UITextField *valLongitude;
@property (strong, nonatomic) IBOutlet UITextField *valErroleitura;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PontoRota *pontoRotaEdit;

- (IBAction)salvarPonto:(id)sender;

@end
