//
//  KlugViewController.h
//  klugin
//
//  Created by Adriano Lemos on 06/06/13.
//  Copyright (c) 2013 Adriano Lemos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface KlugViewController : UITableViewController<CLLocationManagerDelegate,UITableViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UIActionSheetDelegate>{
    CLLocationManager *locationManager;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IBOutlet UILabel *labelRotaEscolhida;
@property (strong, nonatomic) IBOutlet UITableViewCell *celulaEscolhida;
@property (strong, nonatomic) IBOutlet UIView *viewMensagens;
@property (strong, nonatomic) IBOutlet UILabel *erroLeitura;
@property (nonatomic, strong) NSMutableDictionary *pontosNotificadosAbaixo15;
@property (nonatomic, strong) NSMutableDictionary *pontosNotificados40para15;
@property (nonatomic, strong) NSMutableDictionary *pontosNotificados65para40;

@end
