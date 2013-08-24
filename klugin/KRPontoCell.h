//
//  KRPontoCell.h
//  klugrota
//
//  Created by Jader Belarmino on 20/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRPontoCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *valLat;
@property (strong, nonatomic) IBOutlet UILabel *valLongi;
@property (strong, nonatomic) IBOutlet UILabel *marcador;
@property (strong, nonatomic) IBOutlet UILabel *tipoMarcador;
@property (strong, nonatomic) IBOutlet UILabel *ordem;
@property (strong, nonatomic) IBOutlet UILabel *valErroLeituraPonto;

@end
