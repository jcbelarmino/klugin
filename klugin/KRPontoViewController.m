//
//  KRPontoViewController.m
//  klugrota
//
//  Created by Jader Belarmino on 20/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import "KRPontoViewController.h"
#import "KRPontoCell.h"
#import "PontoRota.h"
#import "KRNovoPontoViewController.h"   
#import "KREditPontoViewController.h"
#import "Ordenador.h"

@interface KRPontoViewController ()

@end
@implementation KRPontoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.erroLeitura.text = @"";
    self.title = [NSString stringWithFormat:@"%@ -> %@", self.rotaSelecionada.origem, self.rotaSelecionada.destino];
    //self.locationManager.delegate = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    self.erroLeitura.text = [NSString stringWithFormat:@"Erro leitura atual: %2.1fm",location.horizontalAccuracy];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 
    if ([segue.identifier isEqualToString:@"addPonto"]){
        KRNovoPontoViewController *npvc = segue.destinationViewController;
        npvc.managedObjectContext = self.managedObjectContext;
        npvc.rota = self.rotaSelecionada;
    }else  if ([segue.identifier isEqualToString:@"editPonto"]){
        KREditPontoViewController *editPontoViewController = segue.destinationViewController;
        editPontoViewController.managedObjectContext = self.managedObjectContext;
        //pega a lista de pontos e ordena
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ordem" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSMutableArray *pontosDaRotaOrdenado = [NSMutableArray arrayWithArray:[self.rotaSelecionada.pontosDaRota allObjects]];
        [pontosDaRotaOrdenado sortUsingDescriptors:sortDescriptors];
        NSArray *pontos = pontosDaRotaOrdenado;
        //recupera o ponto que será editado
        editPontoViewController.pontoRotaEdit = [pontos objectAtIndex: [[[sender ordem] text] intValue]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.rotaSelecionada.pontosDaRota.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"pontoCell";
    
    KRPontoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KRPontoCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...   
    NSArray *pontos = [Ordenador ordenaPontos:self.rotaSelecionada.pontosDaRota];     
    cell.valLat.text = [[[pontos objectAtIndex: [indexPath row]] lat] stringValue] ;
    cell.valLongi.text = [[[pontos objectAtIndex:[indexPath row]] longi] stringValue];
    cell.tipoMarcador.text = [[pontos objectAtIndex: [indexPath row]] tipo]  ;
    cell.marcador.text =  [(PontoRota *)[pontos objectAtIndex:[indexPath row]] marcador] ;
    //começando os pontos com 1;
    int ordem = [[(PontoRota *)[pontos objectAtIndex:[indexPath row]] ordem] intValue]  ;
    cell.ordem.text = [NSString stringWithFormat:@"%i",ordem];
    cell.valErroLeituraPonto.text = [[[pontos objectAtIndex:[indexPath row]] erroHorizontal] stringValue];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

- (IBAction)sendEmail:(id)sender {
    NSError *writeError = nil;
    NSMutableArray *pontos = [[NSMutableArray alloc] initWithCapacity:self.rotaSelecionada.pontosDaRota.count];
    NSArray *pontosDaRotaOrdenado = [Ordenador ordenaPontos:self.rotaSelecionada.pontosDaRota];
    for (PontoRota *p in pontosDaRotaOrdenado) {
        [pontos addObject:p.dictionary];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pontos options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON Output: %@", jsonString);
    [self sendEmailTo:@"jcbelarmino@gmail.com,adriano.lemos.dev@gmail.com,jaderbelarmino@outlook.com"
          withSubject:[NSString stringWithFormat:@"ROTA: %@ - %@", self.rotaSelecionada.origem, self.rotaSelecionada.destino]
             withBody:jsonString];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucesso"
                                                    message:@"Email Enviado"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
-(void) sendEmailTo:(NSString *)to withSubject:(NSString *)subject withBody:(NSString *)body {
    NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
                            [to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}
@end
