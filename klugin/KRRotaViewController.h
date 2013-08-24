//
//  KRRotaViewController.h
//  klugrota
//
//  Created by Jader Belarmino on 19/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rota.h"   
#import <CoreLocation/CoreLocation.h>

@interface KRRotaViewController : UITableViewController  <NSFetchedResultsControllerDelegate,
CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Rota *rotaSelecionada;

@end
