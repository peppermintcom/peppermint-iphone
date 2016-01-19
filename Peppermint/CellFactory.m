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
    cell.tableView = tableView;
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

+(SlideMenuTableViewCell*) cellSlideMenuTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath {
    NSString *cellKey = @"SlideMenuTableViewCell";
    SlideMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    return cell;
}

+(LoginValidateEmailTableViewCell*) cellLoginValidateEmailTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath {
    NSString *cellKey = @"LoginValidateEmailTableViewCell";
    LoginValidateEmailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    return cell;
}

+(InformationTextTableViewCell*) cellInformationTextTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath  {
    NSString *cellKey = @"InformationTextTableViewCell";
    InformationTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    return cell;
}

+(ContactInformationTableViewCell*) cellContactInformationTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<ContactInformationTableViewCellDelegate>)delegate {
    NSString *cellKey = @"ContactInformationTableViewCell";
    ContactInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.delegate = delegate;
    cell.indexPath = indexPath;
    return cell;
}

+(ChatContactTableViewCell*) cellChatContactTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath {
    NSString *cellKey = @"ChatContactTableViewCell";
    ChatContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    if(!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellKey owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.indexPath = indexPath;
    cell.tableView = tableView;
    return cell;
}

@end
