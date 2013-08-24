//
//  KRNovoPontoViewController.h
//  klugrota
//
//  Created by Jader Belarmino on 20/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Rota.h"

@interface KRNovoPontoViewController : UITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *marcador;
@property (strong, nonatomic) IBOutlet UITextField *valLat;
@property (strong, nonatomic) IBOutlet UITextField *valLongi;
@property (strong, nonatomic) IBOutlet UITextField *erroLeitura;
@property (strong, nonatomic) IBOutlet UILabel *tipoMarcador;
@property  (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) CLLocationManager *locationManager;
/**
 Rota selecionada.
 */
@property (strong, nonatomic) Rota *rota;
- (IBAction)salvarPonto:(id)sender;
- (IBAction)pararLeituraLocalizacao:(id)sender;


@end
