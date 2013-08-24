//
//  KRRotaCell.h
//  klugrota
//
//  Created by Jader Belarmino on 19/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rota.h"    

@interface KRRotaCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nomeRota;
@property (nonatomic, strong) Rota *rota;
@end
