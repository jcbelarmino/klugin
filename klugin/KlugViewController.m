//
//  KlugViewController.m
//  klugin
//
//  Created by Adriano Lemos on 06/06/13.
//  Copyright (c) 2013 Adriano Lemos. All rights reserved.
//

#import "KlugViewController.h"
#import "UTMConverter.h"
#import "Rota.h"
#import "PontoRota.h"
#import "ActionSheetStringPicker.h"
#import "Constantes.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Ordenador.h"


@interface KlugViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbInformacao;
@property (strong, nonatomic) GMSMutablePath *rota;
@property (strong, nonatomic) NSArray *pontosDaRota;
@property (nonatomic, strong) NSMutableArray *rotas;

- (void)rotaFoiSelecionada:(NSNumber *)selectedIndex element:(id)element;
@end


@implementation KlugViewController


- (id) rota{
    _rota = [[GMSMutablePath alloc] init];
    for (PontoRota *ponto in self.pontosDaRota) {
        [_rota addCoordinate:CLLocationCoordinate2DMake([ponto.lat doubleValue], [ponto.longi doubleValue])];
    }
        //[_rota addCoordinate:CLLocationCoordinate2DMake(-15.79966, -47.88725)]; // Início
      //  [_rota addCoordinate: 
  
    return _rota;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lbInformacao.text = @"";
    
    [self obtemRotasDoServidor];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Erro tratado %@, %@", error, [error userInfo]);
        abort();
    }

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    [self showPicker];
}

/**
 *
 */
-(void)obtemRotasDoServidor
{
    
    NSString *urlString= [NSString stringWithFormat:@"http://klugin-jcb.rhcloud.com/rest/rotas"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSArray *jsonResultSetArray = (NSArray*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    for (NSDictionary *rota in jsonResultSetArray){
        // Salva a rota lida
        Rota *rotaSalva = [self salvaRota:rota];
        
        NSArray* pontosRota = [rota objectForKey:@"pontosRota"];
        for (NSDictionary* ponto in pontosRota) {
            // Salva o ponto da rota
            [self salvaPonto:ponto daRota:rotaSalva];
        }
    }
}

-(Rota *)salvaRota:(NSDictionary *)novaRota
{
    Rota *rota;
    
    rota = [NSEntityDescription insertNewObjectForEntityForName:@"Rota" inManagedObjectContext:self.managedObjectContext];
    rota.origem = novaRota[@"origem"];
    rota.destino = novaRota[@"destino"];
    
    NSError *erro = nil;
    [self.managedObjectContext save:&erro];
    if (erro != nil){
        NSLog(@"Rota: [%@ -> %@] salva com sucesso!", rota.origem, rota.destino );
    } else {
        NSLog(@"Erro: não foi possível salvar a rota [%@ -> %@] id(%@) !", rota.origem, rota.destino, novaRota[@"id"] );
    }
    
    return rota;
}

-(void)salvaPonto:(NSDictionary*) novoPonto daRota:(Rota *) rota
{
    PontoRota *pontoRota;
    pontoRota = [NSEntityDescription insertNewObjectForEntityForName:@"PontoRota" inManagedObjectContext:self.managedObjectContext];
    
    pontoRota.marcador = [novoPonto objectForKey:@"marcador" ];
    pontoRota.longi = [NSNumber numberWithDouble: [[novoPonto objectForKey:@"longi" ] doubleValue]];
    pontoRota.lat = [NSNumber numberWithDouble:[[novoPonto objectForKey:@"lat" ] doubleValue]];
    pontoRota.erroHorizontal = [NSNumber numberWithDouble:[[novoPonto objectForKey:@"erroHorizontal" ] doubleValue]];
    pontoRota.geoText = [novoPonto objectForKey:@"geoText" ];
    pontoRota.ordem = [NSNumber numberWithInteger: [[novoPonto objectForKey:@"ordem" ] integerValue]];
    pontoRota.tipo = [novoPonto objectForKey:@"tipo" ];
    pontoRota.minhaRota = rota;
    
    NSError *erro = nil;
    [self.managedObjectContext save:&erro];
    if (erro != nil){
        NSLog(@"Ponto: id[%@] salvo com sucesso!", novoPonto[@"id"] );
    } else {
        NSLog(@"Erro: não foi possível salvar o ponto id[%@]!", novoPonto[@"id"] );
    }
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"iniciou");
}
- (void)showPicker{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Erro tratado %@, %@", error, [error userInfo]);
        abort();
    }
    int qtdRotas =  [[self.fetchedResultsController fetchedObjects] count];
    self.rotas = [[NSMutableArray alloc] initWithCapacity: qtdRotas];
    //tem rotas cadastradas
    if (qtdRotas >0) {
        for (Rota *rota in [self.fetchedResultsController fetchedObjects]) {
            [self.rotas addObject:[NSString stringWithFormat:@"%@ -> %@", rota.origem, rota.destino]  ];
        }
        // Selecionar a rota
        [ActionSheetStringPicker showPickerWithTitle:@"Selecione a rota"
                                                rows:self.rotas
                                    initialSelection:0
                                              target:self
                                       successAction:@selector(rotaFoiSelecionada:element:)
                                        cancelAction:@selector(actionPickerCancelled:)
                                              origin:self.view];
    }else{//não tem rotas cadastradas
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Olá!"
                                                        message:@"Cadastre uma rota na tab \"Rotas\""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
   
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.celulaEscolhida) {
        [self showPicker];
    }else if ([self.rota count]>0) {
        [self localizarUsuario];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opa!"
                                                        message:@"Não existem pontos na rota."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations lastObject];
    //identifica a acurácia da medida
    self.erroLeitura.text = [NSString stringWithFormat:@"Erro: vertical: %2.2F. Horizontal %2.2F",
                        location.verticalAccuracy, location.horizontalAccuracy];
    //só calcula se a acurácia horizontal for boa.
    if (location.horizontalAccuracy < ACURACIA_MINIMA) {
        for (int i=0; i<(self.rota.count); i++) {
            
            CLLocationCoordinate2D coord = [self.rota coordinateAtIndex:i];
            CLLocation *locationPontoRota = [[CLLocation alloc] initWithLatitude:coord.latitude
                                                                 longitude:coord.longitude];
            //notifica se a distância for menor que a distância dos erros e o ponto ainda não foi notificado.
            PontoRota *pr = [self.pontosDaRota objectAtIndex:i];
            if ([location distanceFromLocation:locationPontoRota] < [self distanciaNotificacaoPontoLido:location pontoRota:pr]
                    && ![self.pontosNotificados objectForKey:[NSNumber numberWithInt:i]] ) {
                //grava o ponto notificado;
                [self.pontosNotificados setObject:pr forKey:[NSNumber numberWithInt:i]];
                //Notifica com alerta
                NSString *msg = [NSString stringWithFormat:@"%@. %@. Distância de: %2.1f", pr.tipo, pr.marcador, [location distanceFromLocation:locationPontoRota]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chegou em"
                                                                message:msg
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                //Atualiza label com a lista de pontos notificados
                self.lbInformacao.text = [NSString stringWithFormat:@"%@. %@", self.lbInformacao.text, pr.marcador];
            }
        }

    }
    
    NSLog(@" KLUGViewController [lat: %f , long: %f]", location.coordinate.latitude, location.coordinate.longitude);
    
}
/**
 Calcula a distância de notificaçãoo baseado no erro dos pontos lidos.
 */
-(double) distanciaNotificacaoPontoLido:(CLLocation*) pontoLido pontoRota:(PontoRota *) pontoRota{
    
    NSLog(@"distância de notificação %f", ([pontoRota.erroHorizontal doubleValue] + pontoLido.horizontalAccuracy));
    return [pontoRota.erroHorizontal doubleValue] + pontoLido.horizontalAccuracy;
    
}
- (void)rotaFoiSelecionada:(NSNumber *)selectedIndex element:(id)element {
    int index = [selectedIndex intValue];
    Rota *rotaSelecionada = [[self.fetchedResultsController fetchedObjects] objectAtIndex:index] ;
    self.labelRotaEscolhida.text = [NSString stringWithFormat:@"%@ -> %@",rotaSelecionada.origem, rotaSelecionada.destino ];
    self.pontosDaRota = [Ordenador ordenaPontos:rotaSelecionada.pontosDaRota];
    self.pontosNotificados = [[NSMutableDictionary alloc] initWithCapacity:self.pontosDaRota.count];
  //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    //self.animalTextField.text = [self.animals objectAtIndex:self.selectedIndex];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rota" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *nomeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"origem" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nomeDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Memory management.
    
    return _fetchedResultsController;
}


- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

- (IBAction)localizarUsuario{
    
    
    BOOL estaNaRota = NO;
    int iPoint = 0;
    // Tratar o evento de localização para quando o usuário quiser se situar.
    CLLocationCoordinate2D posicao = locationManager.location.coordinate; //CLLocationCoordinate2DMake(-15.79805, -47.88793);
    
    //self.lbInformacao.text = [NSString stringWithFormat:@"[lat: %f , long: %f]", posicao.latitude, posicao.longitude];
    
    // Varrer o array de pontos da rota e testar cada par até o final.
    for (; iPoint < (self.rota.count-1); iPoint++) {
        CLLocationCoordinate2D pontoA = [self.rota coordinateAtIndex:iPoint];
        CLLocationCoordinate2D pontoB = [self.rota coordinateAtIndex:(iPoint + 1)];
        if ( [self ponto:posicao estaEntre: pontoA e: pontoB] ) {
            self.lbInformacao.text = @"Você está na rota!";
            estaNaRota = YES;
            break;
        }
    }
    NSString *mensagem;
    if (estaNaRota) {
        // Mostra uma MessageBox de sucesso.
        CLLocation *pos = [[CLLocation alloc] initWithLatitude:posicao.latitude longitude:posicao.longitude];
        CLLocation *pto = [[CLLocation alloc] initWithLatitude:[self.rota coordinateAtIndex:(iPoint + 1)].latitude  longitude:[self.rota coordinateAtIndex:(iPoint + 1)].longitude];
        CLLocationDistance metros = [pos distanceFromLocation:pto];
        mensagem =
        [NSString stringWithFormat:@"Você está na rota, entre %@ e  %@, a %f metros de %@.",
         [[[self pontosDaRota] objectAtIndex:iPoint] marcador],
         [[[self pontosDaRota] objectAtIndex:(iPoint + 1) ] marcador],
         metros,
         [[[self pontosDaRota] objectAtIndex:(iPoint + 1) ] marcador]];
    } else {
        // Mostra que está fora da rota
        mensagem = @"Você está fora da rota";
    }
    UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Localização" message:mensagem delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [servicesDisabledAlert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) ponto:(CLLocationCoordinate2D)atual estaEntre:(CLLocationCoordinate2D)inicioRota e:(CLLocationCoordinate2D)fimRota{
    
    BOOL resposta = NO;
    
    UTMConverter *conversor = [[UTMConverter alloc] init];
    
    UTMCoordinates pontoAtual = [conversor latitudeAndLongitudeToUTMCoordinates:atual];
    UTMCoordinates rota_ini = [conversor latitudeAndLongitudeToUTMCoordinates:inicioRota];
    UTMCoordinates rota_fim = [conversor latitudeAndLongitudeToUTMCoordinates:fimRota];
    
    UTMCoordinates ponto_inter;
    
    if( rota_ini.easting == rota_fim.easting && rota_ini.northing == rota_fim.northing ){
        rota_ini.northing -= 0.00001;
    }
    
    UTMDouble U = ((pontoAtual.northing - rota_ini.northing) * (rota_fim.northing - rota_ini.northing)) + ((pontoAtual.easting - rota_ini.easting) * (rota_fim.easting - rota_ini.easting));
    
    
    UTMDouble Udenom = pow(rota_fim.northing - rota_ini.northing, 2.0) + pow(rota_fim.easting - rota_ini.easting, 2.0);
    
    U /= Udenom;
    
    ponto_inter.northing    = rota_ini.northing + (U * (rota_fim.northing - rota_ini.northing));
    ponto_inter.easting     = rota_ini.easting + (U * (rota_fim.easting - rota_ini.easting));

    ponto_inter.hemisphere  = kUTMHemisphereSouthern;
    ponto_inter.gridZone    = rota_fim.gridZone;
    
    UTMDouble minx, maxx, miny, maxy;
    
    minx = MIN(rota_ini.northing, rota_fim.northing);
    maxx = MAX(rota_ini.northing, rota_fim.northing);
    
    miny = MIN(rota_ini.easting, rota_fim.easting);
    maxy = MAX(rota_ini.easting, rota_fim.easting);
    
    if ( (ponto_inter.northing >= minx && ponto_inter.northing <= maxx) && (ponto_inter.easting >= miny && ponto_inter.easting <= maxy) ){
        
        NSLog(@"O ponto [%f, %f] está dentro da rota", ponto_inter.easting, ponto_inter.northing );
        
        CLLocationCoordinate2D interp = [conversor UTMCoordinatesToLatitudeAndLongitude:ponto_inter];
        
        NSLog(@"O ponto de interseção é [%f, %f] ", interp.latitude, interp.longitude );
        
        CLLocation *loc_atual = [[CLLocation alloc] initWithLatitude:atual.latitude longitude:atual.longitude];
        CLLocation *loc_inter = [[CLLocation alloc] initWithLatitude:interp.latitude longitude:interp.longitude];
        
        CLLocationDistance metros = [loc_atual distanceFromLocation:loc_inter];
        
        NSLog(@"A distância até a rota é [%f] ", metros );
        
        resposta = (metros > 10.0) ? NO : YES;
    } else {
        
        CLLocationCoordinate2D interp = [conversor UTMCoordinatesToLatitudeAndLongitude:ponto_inter];
        
        NSLog(@"O ponto fora da reta é [%f, %f] ", interp.latitude, interp.longitude );
    }
    
    return resposta;
}


@end
