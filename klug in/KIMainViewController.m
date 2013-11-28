//
//  KIMainViewController.m
//  klug in
//
//  Created by Adriano Lemos on 12/09/13.
//  Copyright (c) 2013 Velum. All rights reserved.
//

#import "KIMainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Rota.h"
#import "PontoRota.h"
#import "Constantes.h"
#import "Ordenador.h"

@interface KIMainViewController () <UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate>
{
    
    CLLocationManager *locationManager;

}
@property (weak, nonatomic) IBOutlet UIPickerView *seletorDeRotas;
@property (weak, nonatomic) IBOutlet UIButton *botaoIniciarRota;
@property (weak, nonatomic) IBOutlet UIButton *botaoAtualizarRotas;
@property (weak, nonatomic) IBOutlet UILabel *lbInformacoes;
@property (strong, nonatomic) NSMutableArray *rota;
@property (strong, nonatomic) NSArray *pontosDaRota;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *rotas;

@property (strong, nonatomic) PontoRota *penultimaParada;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property BOOL penultimaParadaNotificada;

@end

@implementation KIMainViewController


- (id) rota{
    _rota = [[NSMutableArray alloc] init];
    for (PontoRota *ponto in self.pontosDaRota) {
        CLLocation *localizacao = [[CLLocation alloc] initWithLatitude:[ponto.lat doubleValue] longitude:[ponto.longi doubleValue]];
        [_rota addObject: localizacao];
    }
    
    return _rota;
}

- (id) activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        _activityView.center = self.view.center;
        _activityView.accessibilityLabel = @"Carregando Rotas";
        
        [self.view addSubview:_activityView];
    }
    return _activityView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.seletorDeRotas.delegate = self;
    self.seletorDeRotas.dataSource = self;

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    self.sintetizador = [[AVSpeechSynthesizer alloc] init];
    
    [self customizarBotoes];
    
    self.lbInformacoes.hidden = YES;
    
    // Verificar se a base de rotas está vazia e carregar do servidor
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Erro tratado %@, %@", error, [error userInfo]);
        abort();
    }
    int qtdRotas =  [[self.fetchedResultsController fetchedObjects] count];
 
    if (qtdRotas == 0) {
        [self atualizarRotas:nil];
    } else {
        [self atualizaRotas];
        [self.seletorDeRotas reloadAllComponents];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Voz

- (void) falarMensagem: (NSString *)mensagem
{

    // Deixar a voz um pouco mais compassada.
    float speechSpeed = AVSpeechUtteranceDefaultSpeechRate * 0.5;
    
    AVSpeechUtterance *synUtt = [[AVSpeechUtterance alloc] initWithString:mensagem];
    [synUtt setRate:speechSpeed];
    [synUtt setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"pt-br"]];
    
    [self.sintetizador speakUtterance:synUtt];

}

#pragma mark - Botoes

- (void) customizarBotoes
{
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    
    
    [self.botaoIniciarRota setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.botaoIniciarRota setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    [self.botaoAtualizarRotas setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.botaoAtualizarRotas setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
}

- (IBAction)iniciarRota:(UIButton *)sender {
    
    int index = [self.seletorDeRotas selectedRowInComponent:0];
    
    self.seletorDeRotas.hidden = !self.seletorDeRotas.hidden;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Erro tratado %@, %@", error, [error userInfo]);
        abort();
    }

    Rota *rotaSelecionada = [[self.fetchedResultsController fetchedObjects] objectAtIndex:index] ;
    self.lbInformacoes.text = [NSString stringWithFormat:@"Rota de %@ para %@",rotaSelecionada.origem, rotaSelecionada.destino ];
    self.pontosDaRota = [Ordenador ordenaPontos:rotaSelecionada.pontosDaRota];
    self.pontosNotificadosAbaixo15 = [[NSMutableDictionary alloc] initWithCapacity:self.pontosDaRota.count];
    self.pontosNotificados40para15 = [[NSMutableDictionary alloc] initWithCapacity:self.pontosDaRota.count];
    self.pontosNotificados65para40 = [[NSMutableDictionary alloc] initWithCapacity:self.pontosDaRota.count];
    
    //avisa que a rota está começando
    [self falarMensagem:[NSString stringWithFormat:@" %@ iniciada.",self.lbInformacoes.text]];
    
    /*
    if ( UIAccessibilityIsVoiceOverRunning() ) {
        UIAccessibilityPostNotification( UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@" %@ iniciada.",self.lbInformacoes.text] );
    }*/
    
    for (int idx = (self.pontosDaRota.count -1); idx > 0; idx--) {
        
        PontoRota *ponto_atual = [self.pontosDaRota objectAtIndex:idx];
        PontoRota *ponto_anter = [self.pontosDaRota objectAtIndex:(idx - 1)];
        
        if ( [ponto_atual.tipo isEqualToString:@"Parada de ônibus"] && [ponto_anter.tipo isEqualToString:@"Parada de ônibus"] ) {
            self.penultimaParada = ponto_anter;
            break;
        } else {
            self.penultimaParada = nil;
        }
    }
    
}

- (IBAction)atualizarRotas:(UIButton *)sender {
    
    [self obtemRotasDoServidor];
    
    [self atualizaRotas];
    
    [self.seletorDeRotas reloadAllComponents];

}


#pragma mark - Servidor

-(void)obtemRotasDoServidor
{
    [self.activityView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString= [NSString stringWithFormat:@"http://klugin-jcb.rhcloud.com/rest/rotas"];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data){
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityView stopAnimating];
            [self atualizaRotas];
            [self.seletorDeRotas reloadAllComponents];
        });
    });

    
}

#pragma mark - CoreLocation

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    if (location.horizontalAccuracy < ACURACIA_MINIMA) {
        
        for (int i=0; i<(self.rota.count); i++) {
            
            CLLocationCoordinate2D coord = ((CLLocation *)[self.rota objectAtIndex: i]).coordinate;
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
                    titulo = @"Aviso. Chegando a";
                    [self.pontosNotificados65para40 setObject:pr forKey:[NSNumber numberWithInt:i]];
                    notificar = YES;
                } else if ( (distancia > DISTANCIA_MINIMA && distancia <= DISTANCIA_INTER) &&
                           ![self.pontosNotificados40para15 objectForKey:[NSNumber numberWithInt:i]] ) {
                    titulo = @"Aviso. Próximo a";
                    [self.pontosNotificados40para15 setObject:pr forKey:[NSNumber numberWithInt:i]];
                    
                    if ( [self.penultimaParada.ordem intValue] == [pr.ordem intValue] ){
                        if ( !_penultimaParadaNotificada ){
                            [self notificaPenultimaParada];
                            _penultimaParadaNotificada = YES;
                        }
                    } else {
                        notificar = YES;
                    }
                } else if ( distancia <= DISTANCIA_MINIMA &&
                           ![self.pontosNotificadosAbaixo15 objectForKey:[NSNumber numberWithInt:i]] ) {
                    titulo = @"Aviso. Aproximando-se ";
                    [self.pontosNotificadosAbaixo15 setObject:pr forKey:[NSNumber numberWithInt:i]];
                    
                    if ( [self.penultimaParada.ordem intValue] == [pr.ordem intValue] ){
                        if ( !_penultimaParadaNotificada ){
                            [self notificaPenultimaParada];
                            _penultimaParadaNotificada = YES;
                        }
                    } else {
                        notificar = YES;
                    }
                }
                
                if ( notificar ){
                    //Notifica com alerta
                    NSString *msg = [NSString stringWithFormat:@"%@ %@. Distância de: %2.0f metros. %@. Próximo ponto a %d metros", titulo, pr.marcador, distancia, pr.orientacao, [pr.distanciaProxPonto intValue]];
                    
                    [self falarMensagem:msg];
                    
                    /*
                    if ( UIAccessibilityIsVoiceOverRunning() ) {
                        UIAccessibilityPostNotification( UIAccessibilityAnnouncementNotification, msg );
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titulo
                                                                        message:msg
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    }*/
                    
                    //Atualiza label com a lista de pontos notificados
                    self.lbInformacoes.text = [NSString stringWithFormat:@"%@. %@", self.lbInformacoes.text, pr.marcador];
                }
            }
        }
    }
    
}

-(void) notificaPenultimaParada
{
    
    NSString *msg = @"Você chegou à penúltima parada. Assim que puder avise ao condutor que deserá na próxima parada";
    
    // Não há necessidade de jogar na tela quando o VoiceOver estiver ativo.
    // Em casos assim, o usuário apenas ouvirá a notificação sem ter que desativar
    // nada (por exemplo: uma popup de alerta) com vários movimentos até encontrar
    // o botão de fechar ou coisa do gênero.
    
    [self falarMensagem:msg];
    
    /*
    if ( UIAccessibilityIsVoiceOverRunning() ) {
        UIAccessibilityPostNotification( UIAccessibilityAnnouncementNotification, msg );
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aviso"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    */
}

/**
 Calcula a distância de notificaçãoo baseado no erro dos pontos lidos.
 */
-(double) distanciaNotificacaoPontoLido:(CLLocation*) pontoLido pontoRota:(PontoRota *) pontoRota{
    
    NSLog(@"distância de notificação %f", ([pontoRota.erroHorizontal doubleValue] + pontoLido.horizontalAccuracy));
    return [pontoRota.erroHorizontal doubleValue] + pontoLido.horizontalAccuracy;
    
}


#pragma mark - CoreData

-(void)limpaRotaExistente:(NSDictionary *)rota
{
    
    NSFetchRequest *consulta = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entidade = [NSEntityDescription entityForName:@"Rota" inManagedObjectContext:self.managedObjectContext];
    
    [consulta setEntity:entidade];
    
    NSPredicate *predicado = [NSPredicate
                              predicateWithFormat:@" (idRota = %@) ",
                              [rota objectForKey:@"id"]];
    
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
    rota.idRota = novaRota[@"id"];
    
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
    pontoRota.orientacao = [novoPonto objectForKey:@"orientacao" ] == [NSNull null] ? nil : [novoPonto objectForKey:@"orientacao"];
    NSNumber *distanciaProximoPonto = [novoPonto objectForKey:@"distanciaProxPonto"] == [NSNull null] ? nil : [novoPonto objectForKey:@"distanciaProxPonto"];
    pontoRota.distanciaProxPonto = [NSNumber numberWithInteger:[distanciaProximoPonto integerValue]];
    pontoRota.minhaRota = rota;
    
    NSError *erro = nil;
    [self.managedObjectContext save:&erro];
    if (erro != nil){
        NSLog(@"Erro: não foi possível salvar o ponto id[%@]!", novoPonto[@"id"] );
    } else {
        NSLog(@"Ponto: id[%@] salvo com sucesso!", novoPonto[@"id"] );
    }
}

- (void)atualizaRotas
{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
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


#pragma mark - Picker

-(int) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component   {
    return self.rotas.count;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row  forComponent:(NSInteger)component{

    // TODO: Ajustando a interface do picker. Mover isso para um lugar melhor.
    if ( [[pickerView subviews] count] > 8 ){
        [(UIView*)[[pickerView subviews] objectAtIndex:0] setHidden:YES];
        [(UIView*)[[pickerView subviews] objectAtIndex:1] setHidden:YES];
        [(UIView*)[[pickerView subviews] objectAtIndex:2] setHidden:YES];
        [(UIView*)[[pickerView subviews] objectAtIndex:5] setHidden:YES];
        [(UIView*)[[pickerView subviews] objectAtIndex:6] setHidden:YES];
        [(UIView*)[[pickerView subviews] objectAtIndex:7] setHidden:YES];
        [(UIView*)[[pickerView subviews] objectAtIndex:8] setHidden:YES];
    }
    
    return [self.rotas objectAtIndex:row];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent: (NSInteger)component{
}


@end
