//
//  CellFactory.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmptyResultTableViewCell.h"
#import "ContactTableViewCell.h"
#import "SearchMenuTableViewCell.h"

@interface CellFactory : NSObject

#define CELL_HEIGHT_EMPTYRESULT_TABLEVIEWCELL 290
+(EmptyResultTableViewCell*) cellEmptyResultTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_CONTACT_TABLEVIEWCELL 56
+(ContactTableViewCell*) cellContactTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_SEARCH_MENU_TABLEVIEWCELL 44
+(SearchMenuTableViewCell*) cellSearchMenuTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

@end
