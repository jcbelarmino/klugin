//
//  KRPontoViewController.h
//  klugrota
//
//  Created by Jader Belarmino on 20/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rota.h"
#import <CoreLocation/CoreLocation.h>
#import "Constantes.h"

@interface KRPontoViewController : UITableViewController <CLLocationManagerDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Rota *rotaSelecionada;
@property (nonatomic, strong) NSString *nomeRota;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UILabel *erroLeitura;

- (IBAction)sendEmail:(id)sender;

-(void) sendEmailTo:(NSString *)to withSubject:(NSString *)subject withBody:(NSString *)body;
@end
