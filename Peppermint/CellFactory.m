//
//  CellFactory.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "CellFactory.h"

@implementation CellFactory

+(EmptyResultTableViewCell*) cellEmptyResultTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath {
    NSString *cellKey = @"EmptyResultTableViewCell";
    EmptyResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    return cell;
}

+(ContactTableViewCell*) cellContactTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<ContactTableViewCellDelegate>) delegate {
    NSString *cellKey = @"ContactTableViewCell";
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.indexPath = indexPath;
    cell.delegate = delegate;
    return cell;
}

+(SearchMenuTableViewCell*) cellSearchMenuTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath {
    NSString *cellKey = @"SearchMenuTableViewCell";
    SearchMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    return cell;
}

+(LoginTableViewCell*) cellLoginTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<LoginTableViewCellDelegate>) delegate{
    NSString *cellKey = @"LoginTableViewCell";
    LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.indexPath = indexPath;
    cell.delegate = delegate;
    return cell;
}

+(LoginTextFieldTableViewCell*) cellLoginTextFieldTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<LoginTextFieldTableViewCellDelegate>) delegate {
    NSString *cellKey = @"LoginTextFieldTableViewCell";
    LoginTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.indexPath = indexPath;
    cell.delegate = delegate;
    return cell;
}

@end
