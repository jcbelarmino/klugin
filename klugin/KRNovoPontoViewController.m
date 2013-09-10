//
//  KRNovoPontoViewController.m
//  klugrota
//
//  Created by Jader Belarmino on 20/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import "KRNovoPontoViewController.h"
#import "PontoRota.h"
#import "KRPontoViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface KRNovoPontoViewController ()

@property (strong, nonatomic) NSArray *tipos;
@property (strong, nonatomic) NSString *geoText;
@end

@implementation KRNovoPontoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    self.erroLeitura.text = [NSString stringWithFormat:@"%2.1f",location.horizontalAccuracy];
    self.valLat.text = [NSString stringWithFormat:@"%3.6f", location.coordinate.latitude];
    self.valLongi.text = [NSString stringWithFormat:@"%3.6f",location.coordinate.longitude];
        
}

-(BOOL) isPontoValidoLat:(double) lat Lon:(double) longi Erro:(double) erroHorizontal{
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat
                                                     longitude:longi];
    for (PontoRota *pr in self.rota.pontosDaRota) {
        CLLocation *locationPontoRota = [[CLLocation alloc] initWithLatitude:[pr.lat doubleValue]
                                                                   longitude:[pr.longi doubleValue]];
        if ([location distanceFromLocation:locationPontoRota] < (erroHorizontal + [pr.erroHorizontal doubleValue])){
            return FALSE;
        }
    }
    return TRUE;
}

- (id)tipos{
    if (_tipos != nil) {
        return _tipos;
    }
    //Corrigir esse array, deve vir da base de dados.
    return  [NSArray arrayWithObjects:@"Parada de ônibus", @"Faixa de pedestre", @"Dica", @"Semáforo", @"Outro", nil];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.erroLeitura.text = @" ";
    self.valLat.text = @"";
    self.valLongi.text =@"";
    
    GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
    GMSReverseGeocodeCallback handler = ^(GMSReverseGeocodeResponse *response,
                                          NSError *error) {
        self.geoText = response.firstResult.addressLine1;
        
    };
    [geocoder reverseGeocodeCoordinate:self.locationManager.location.coordinate
                     completionHandler:handler];
    self.valLat.text = [NSString stringWithFormat:@"%2.6f",self.locationManager.location.coordinate.latitude];
    self.valLongi.text = [NSString stringWithFormat:@"%2.6f",self.locationManager.location.coordinate.longitude];
    self.erroLeitura.text = [NSString stringWithFormat:@"%2.1f",self.locationManager.location.horizontalAccuracy];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    // IMPORTANTE: Como essa tab vai sair da aplicação, retirei o picker customizado que estávamos usando
    // no projeto como parte do processo de limpeza.
    // [self showPicker];
}

/*
   TODO: Remover completamente esse método e o que ele realiza juntamente com a TAB.
 
- (void)showPicker{
    // Selecionar a rota
    [ActionSheetStringPicker showPickerWithTitle:@"Tipo de marcador"
                                            rows: self.tipos
                                initialSelection:0
                                          target:self
                                   successAction:@selector(tipoEscolhido:element:)
                                    cancelAction:@selector(actionPickerCancelled:)
                                          origin:self.view];
}
 
*/

- (void)tipoEscolhido:(NSNumber *)selectedIndex element:(id)element {
    self.tipoMarcador.text = [self.tipos objectAtIndex:[selectedIndex integerValue]];
}
- (void)actionPickerCancelled:(id)sender {
    //pega o primeiro elemento
    self.tipoMarcador.text = [self.tipos objectAtIndex:0];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
}
#pragma mark - Table view data source


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)salvarPonto:(id)sender {

    if ([self isPontoValidoLat:[self.valLat.text doubleValue]
                           Lon:[self.valLongi.text doubleValue]
                          Erro:[self.erroLeitura.text doubleValue]]) {
        PontoRota *pontoRota;
        pontoRota = [NSEntityDescription insertNewObjectForEntityForName:@"PontoRota" inManagedObjectContext:self.managedObjectContext];
        pontoRota.marcador = self.marcador.text;
        pontoRota.longi = [NSNumber numberWithDouble: [self.valLongi.text doubleValue]];
        pontoRota.lat = [NSNumber numberWithDouble:[self.valLat.text doubleValue]];
        pontoRota.erroHorizontal = [NSNumber numberWithDouble:[self.erroLeitura.text doubleValue]];
        pontoRota.geoText = self.geoText;
        pontoRota.ordem = [NSNumber numberWithInteger: self.rota.pontosDaRota.count];
        pontoRota.tipo = self.tipoMarcador.text;
        pontoRota.minhaRota = self.rota;
        
        NSError *erro = nil;
        [self.managedObjectContext save:&erro];
        if (erro != nil){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro" message:@"Erro ao incluir." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucesso" message:@"Ponto Incluído" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        //volta para a lista de pontos
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro!!" message:@"Já existe um ponto muito próximo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
        
}

- (IBAction)pararLeituraLocalizacao:(id)sender {
    
    [self.locationManager stopUpdatingLocation];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parou!!" message:@"Leitura de Localização." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


@end
