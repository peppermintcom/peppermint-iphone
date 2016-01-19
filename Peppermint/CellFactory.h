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
#import "LoginTableViewCell.h"
#import "LoginTextFieldTableViewCell.h"
#import "SlideMenuTableViewCell.h"
#import "LoginValidateEmailTableViewCell.h"
#import "InformationTextTableViewCell.h"
#import "ContactInformationTableViewCell.h"
#import "ChatContactTableViewCell.h"

@interface CellFactory : NSObject

#define CELL_HEIGHT_EMPTYRESULT_TABLEVIEWCELL  210
+(EmptyResultTableViewCell*) cellEmptyResultTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_CONTACT_TABLEVIEWCELL 56
+(ContactTableViewCell*) cellContactTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<ContactTableViewCellDelegate>) delegate;

#define CELL_HEIGHT_SEARCH_MENU_TABLEVIEWCELL 44
+(SearchMenuTableViewCell*) cellSearchMenuTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_LOGIN_TABLEVIEWCELL 42
+(LoginTableViewCell*) cellLoginTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<LoginTableViewCellDelegate>) delegate;

#define CELL_HEIGHT_LOGIN_TEXTFIELD_TABLEVIEWCELL 42
+(LoginTextFieldTableViewCell*) cellLoginTextFieldTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<LoginTextFieldTableViewCellDelegate>) delegate;

#define CELL_HEIGHT_SLIDE_MENU_TABLEVIEWCELL 44
+(SlideMenuTableViewCell*) cellSlideMenuTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_VALIDATE_EMAIL_TABLEVIEWCELL 200
+(LoginValidateEmailTableViewCell*) cellLoginValidateEmailTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_INFORMATION_TABLEVIEWCELL    28
+(InformationTextTableViewCell*) cellInformationTextTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_CONTACT_INFORMATION_TABLEVIEWCELL    70
+(ContactInformationTableViewCell*) cellContactInformationTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<ContactInformationTableViewCellDelegate>)delegate;

#define CELL_HEIGHT_CHAT_CONTACT_TABLEVIEWCELL CELL_HEIGHT_CONTACT_TABLEVIEWCELL
+(ChatContactTableViewCell*) cellChatContactTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

@end
