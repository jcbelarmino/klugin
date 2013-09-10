//
//  KREditPontoViewController.m
//  klugin
//
//  Created by Jader Belarmino on 14/07/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import "KREditPontoViewController.h"

@interface KREditPontoViewController ()
@property (strong, nonatomic) NSArray *tipos;
@end

@implementation KREditPontoViewController

- (id)tipos{
    if (_tipos != nil) {
        return _tipos;
    }
    //Corrigir esse array, deve vir da base de dados.
    return  [NSArray arrayWithObjects:@"Parada de ônibus", @"Faixa de pedestre", @"Dica", @"Semáforo", @"Outro", nil];
    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.valMarcador.text = self.pontoRotaEdit.marcador;
    self.valTipoMarcador.text = self.pontoRotaEdit.tipo;
    self.valLatitude.text= [NSString stringWithFormat:@"%3.6f", [self.pontoRotaEdit.lat floatValue]];
    self.valLongitude.text= [NSString stringWithFormat:@"%3.6f", [self.pontoRotaEdit.longi floatValue]];
    self.valErroleitura.text = [NSString stringWithFormat:@"%3.1f", [self.pontoRotaEdit.erroHorizontal floatValue]];
    
    // TODO: Remover completamente junto com a TAB
    // [self showPicker];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 // TODO: Remover completamente junto com a TAB
 
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
    self.valTipoMarcador.text = [self.tipos objectAtIndex:[selectedIndex integerValue]];
}
- (void)actionPickerCancelled:(id)sender {
    //pega o primeiro elemento
    self.valTipoMarcador.text = [self.tipos objectAtIndex:0];

}
-(BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
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

- (IBAction)salvarPonto:(id)sender {
    
    self.pontoRotaEdit.marcador = [self.valMarcador text];
    self.pontoRotaEdit.tipo = [self.valTipoMarcador text];
    self.pontoRotaEdit.longi = [NSNumber numberWithDouble: [self.valLongitude.text doubleValue]];
    self.pontoRotaEdit.lat = [NSNumber numberWithDouble:[self.valLatitude.text doubleValue]];
    self.pontoRotaEdit.erroHorizontal = [NSNumber numberWithDouble:[self.valErroleitura.text doubleValue]];
   
    NSError *erro = nil;
    [self.managedObjectContext save:&erro];
    if (erro != nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro" message:@"Erro ao alterar." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucesso" message:@"Ponto Alterado" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    //volta para a lista de pontos
    [self.navigationController popViewControllerAnimated:YES];
}
@end
