//
//  CellFactory.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - TableViewCell
#import "EmptyResultTableViewCell.h"
#import "ContactTableViewCell.h"
#import "SearchMenuTableViewCell.h"
#import "LoginTableViewCell.h"
#import "LoginTextFieldTableViewCell.h"
#import "SlideMenuTableViewCell.h"
#import "LoginValidateEmailTableViewCell.h"
#import "InformationTextTableViewCell.h"
#import "ContactInformationTableViewCell.h"
#import "ChatTableViewCell.h"
#import "ChatTableViewMailCell.h"

#pragma mark - CollectionViewCell
#import "EmailLoginCollectionViewCell.h"

@interface CellFactory : NSObject

#define CELL_HEIGHT_EMPTYRESULT_TABLEVIEWCELL  52
+(EmptyResultTableViewCell*) cellEmptyResultTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_CONTACT_TABLEVIEWCELL 56
+(ContactTableViewCell*) cellContactTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath withDelegate:(id<ContactTableViewCellDelegate>) delegate;

#define CELL_HEIGHT_SEARCH_MENU_TABLEVIEWCELL 44
+(SearchMenuTableViewCell*) cellSearchMenuTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_HEIGHT_LOGIN_TABLEVIEWCELL 36
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

#define CELL_HEIGHT_CHAT_TABLEVIEWCELL  60
+(ChatTableViewCell*) cellChatTableViewCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath andDelegate:(id<ChatTableViewCellDelegate>) delegate;

#define CELL_HEIGHT_CHAT_TABLEVIEWMAILCELL_IDLE_MAX  300
+(ChatTableViewMailCell*) cellChatTableViewMailCellFromTable:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath;

#define CELL_SIZE_EMAILLOGIN_COLLECTIONVIEWCELL CGSizeMake(SCREEN_WIDTH/3.75, SCREEN_WIDTH/3.75)
+(EmailLoginCollectionViewCell*) cellEmailLoginCollectionViewCellFromCollectionView:(UICollectionView*)collectionView forIndexPath:(NSIndexPath*)indexPath;

@end
