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
#import "Constantes.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Ordenador.h"
#import "Toast+UIView.h"

@interface KlugViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbInformacao;
@property (strong, nonatomic) GMSMutablePath *rota;
@property (strong, nonatomic) NSArray *pontosDaRota;
@property (nonatomic, strong) NSMutableArray *rotas;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) PontoRota *penultimaParada;

@end


@implementation KlugViewController


- (id) rota{
    _rota = [[GMSMutablePath alloc] init];
    for (PontoRota *ponto in self.pontosDaRota) {
        [_rota addCoordinate:CLLocationCoordinate2DMake([ponto.lat doubleValue], [ponto.longi doubleValue])];
    }
  
    return _rota;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lbInformacao.text = @"";
    
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
  
    [self exibirSelecionadorDeRotas];
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
        
        // Testa se a rota já existe e, caso exista, deleta antes (atualizar).
        [self limpaRotaExistente:rota];
        
        // Salva a rota lida
        Rota *rotaSalva = [self salvaRota:rota];
        
        NSArray* pontosRota = [rota objectForKey:@"pontosRota"];
        for (NSDictionary* ponto in pontosRota) {
            // Salva o ponto da rota
            [self salvaPonto:ponto daRota:rotaSalva];
        }
    }
}

-(void)limpaRotaExistente:(NSDictionary *)rota
{
    
    NSFetchRequest *consulta = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entidade = [NSEntityDescription entityForName:@"Rota" inManagedObjectContext:self.managedObjectContext];
    
    [consulta setEntity:entidade];
    
    NSPredicate *predicado = [NSPredicate
                              predicateWithFormat:@" (origem like %@) AND (destino like %@) ",
                              [rota objectForKey:@"origem"], [rota objectForKey:@"destino"]];
    
    [consulta setPredicate:predicado];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                [NSSortDescriptor sortDescriptorWithKey:@"origem"
                                                              ascending:YES]];
    [consulta setSortDescriptors:sortDescriptors];
    
    NSError *erro;
    
    NSArray *resultados = [self.managedObjectContext executeFetchRequest:consulta error:
                           &erro];
    
    if ( (resultados != nil) && (resultados.count > 0) ) {
        [self.managedObjectContext deleteObject:resultados[0]];
        [self.managedObjectContext save:&erro];
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
        NSLog(@"Erro: não foi possível salvar a rota [%@ -> %@] id(%@) !", rota.origem, rota.destino, novaRota[@"id"] );
    } else {
        NSLog(@"Rota: [%@ -> %@] salva com sucesso!", rota.origem, rota.destino );
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
        NSLog(@"Erro: não foi possível salvar o ponto id[%@]!", novoPonto[@"id"] );
    } else {
        NSLog(@"Ponto: id[%@] salvo com sucesso!", novoPonto[@"id"] );
    }
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"iniciou");
}

- (void)atualizaRotas
{
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
            [self.rotas addObject:[NSString stringWithFormat:@"De %@ Para %@", rota.origem, rota.destino]  ];
        }
    }
    
}

-(void)exibirSelecionadorDeRotas
{
    [self atualizaRotas];
    
    NSString *actionSheetTitle = @"Escolha uma rota"; //Action Sheet Title
    NSString *cancelTitle = @"Cancela";
    NSString *selecionar = @"Selecionar";
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:selecionar, nil];
    
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

    CGRect pickerFrame = CGRectMake(0, 100, 0, 200);
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    [self.actionSheet addSubview:self.pickerView];
 
    UISegmentedControl *btSelecionar = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Atualizar"]];
    btSelecionar.momentary = YES;
    btSelecionar.frame = CGRectMake(230, 7.0f, 80.0f, 30.0f);
    btSelecionar.segmentedControlStyle = UISegmentedControlStylePlain;
    btSelecionar.tintColor = [UIColor blackColor];
    btSelecionar.accessibilityLabel = @"Atualizar as Rotas";
    [btSelecionar addTarget:self action:@selector(AtualizaRotasDoPicker:) forControlEvents:UIControlEventValueChanged];
    [self.actionSheet addSubview:btSelecionar];
 
    [self.actionSheet showInView:self.view];
    
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

/**
 *  Quando o botão de seleção do ActionSheet for clicado este método recuperará a rota
 *  selecionada e atualizará os objetos e listas de controle de notificação.
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int index = [self.pickerView selectedRowInComponent:0];
    
    Rota *rotaSelecionada = [[self.fetchedResultsController fetchedObjects] objectAtIndex:index] ;
    self.labelRotaEscolhida.text = [NSString stringWithFormat:@"Rota de %@ para %@",rotaSelecionada.origem, rotaSelecionada.destino ];
    self.pontosDaRota = [Ordenador ordenaPontos:rotaSelecionada.pontosDaRota];
    self.pontosNotificadosAbaixo15 = [[NSMutableDictionary alloc] initWithCapacity:self.pontosDaRota.count];
    self.pontosNotificados40para15 = [[NSMutableDictionary alloc] initWithCapacity:self.pontosDaRota.count];
    self.pontosNotificados65para40 = [[NSMutableDictionary alloc] initWithCapacity:self.pontosDaRota.count];
    
    for (int idx = (self.pontosDaRota.count -1); idx > 0; idx--) {
        PontoRota *ponto_atual = [self.pontosDaRota objectAtIndex:idx];
        PontoRota *ponto_anter = [self.pontosDaRota objectAtIndex:(idx - 1)];
        if ( [ponto_atual.marcador isEqualToString:@"Parada de ônibus"] && [ponto_anter.marcador isEqualToString:@"Parada de ônibus"] ) {
            self.penultimaParada = ponto_anter;
            break;
        } else {
            self.penultimaParada = nil;
        }
    }
    
    [self.pickerView removeFromSuperview];
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];

}

- (void)AtualizaRotasDoPicker:(id)sender{
    
    [self.actionSheet.viewForBaselineLayout makeToast:@"Atualizando as rotas"
                                             duration:2.0
                                             position:@"top"
                                                title:@""];

    [self obtemRotasDoServidor];
    
    [self atualizaRotas];
    
    [self.pickerView reloadAllComponents];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // Colocar o número de acordo com o Array de rotas
    return self.rotas.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.rotas objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.celulaEscolhida) {
        [self exibirSelecionadorDeRotas];
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

/**
 * Este é o método central de controle da aplicação. Toda atualização da posição do device
 * aciona este código que verifica o que deve ser notificado para orientar o usuário.
 **/
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
            double errosSomados = [self distanciaNotificacaoPontoLido:location pontoRota:pr];
            double distancia    = [location distanceFromLocation:locationPontoRota];
            
            if (distancia < errosSomados){
                
                BOOL notificar = NO;
                NSString *titulo;
                
                if ( (distancia > DISTANCIA_INTER && distancia <= DISTANCIA_MAXIMA) &&
                    ![self.pontosNotificados65para40 objectForKey:[NSNumber numberWithInt:i]] ) {
                    titulo = @"Chegando a";
                    [self.pontosNotificados65para40 setObject:pr forKey:[NSNumber numberWithInt:i]];
                    notificar = YES;
                } else if ( (distancia > DISTANCIA_MINIMA && distancia <= DISTANCIA_INTER) &&
                           ![self.pontosNotificados40para15 objectForKey:[NSNumber numberWithInt:i]] ) {
                    titulo = @"Próximo a";
                    [self.pontosNotificados40para15 setObject:pr forKey:[NSNumber numberWithInt:i]];
                    notificar = YES;
                } else if ( distancia <= DISTANCIA_MINIMA &&
                           ![self.pontosNotificadosAbaixo15 objectForKey:[NSNumber numberWithInt:i]] ) {
                    titulo = @"Chegou a";
                    [self.pontosNotificadosAbaixo15 setObject:pr forKey:[NSNumber numberWithInt:i]];
                    
                    if ( [self.penultimaParada.ordem intValue] == [pr.ordem intValue] ){
                        [self notificaPenultimaParada];
                    } else {
                        notificar = YES;
                    }
                }

                if ( notificar ){
                    //Notifica com alerta
                    NSString *msg = [NSString stringWithFormat:@"%@. %@. Distância de: %2.1f", pr.tipo, pr.marcador, distancia];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titulo
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

    }
    
    NSLog(@" KLUGViewController [lat: %f , long: %f]", location.coordinate.latitude, location.coordinate.longitude);
    
}

-(void) notificaPenultimaParada
{

    NSString *msg = @"Você chegou à penúltima parada. Assim que puder avise ao condutor que deserá na próxima parada";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aviso"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

/**
 Calcula a distância de notificaçãoo baseado no erro dos pontos lidos.
 */
-(double) distanciaNotificacaoPontoLido:(CLLocation*) pontoLido pontoRota:(PontoRota *) pontoRota{
    
    NSLog(@"distância de notificação %f", ([pontoRota.erroHorizontal doubleValue] + pontoLido.horizontalAccuracy));
    return [pontoRota.erroHorizontal doubleValue] + pontoLido.horizontalAccuracy;
    
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
