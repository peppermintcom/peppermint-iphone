//
//  LoginWithEmailViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginWithEmailViewController.h"

#define NUMBER_OF_GROUPS    2
#define INDEX_NAME_SURNAME    0
#define INDEX_EMAIL           1

#define DISTANCE_BTW_SECTIONS       24

@interface LoginWithEmailViewController ()

@end

@implementation LoginWithEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;    
    self.doneLabel.font = [UIFont openSansSemiBoldFontOfSize:14];
    self.doneLabel.textColor = [UIColor whiteColor];
    self.doneLabel.text = LOC(@"Done",@"Done button text");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_GROUPS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTextFieldTableViewCell *loginTextFieldCell = [CellFactory cellLoginTextFieldTableViewCellFromTable:tableView forIndexPath:indexPath];
    
    NSInteger index = indexPath.section;
    if(index == INDEX_NAME_SURNAME) {
        loginTextFieldCell.textField.placeholder = @"Name surname";
    } else if (index == INDEX_EMAIL) {
        loginTextFieldCell.textField.placeholder = @"Email";
    }
    return loginTextFieldCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = DISTANCE_BTW_SECTIONS;
    return headerHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, DISTANCE_BTW_SECTIONS)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Navigation

-(IBAction) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) doneButtonPressed:(id)sender {
    NSLog(@"done bakalım...");
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
