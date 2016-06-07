//
//  TranscriptionViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 07/06/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "TranscriptionViewController.h"

#define TITLE_TEXT_SIZE                     20

@interface TranscriptionViewController ()
@end

@implementation TranscriptionViewController {
    NSArray *allLanguagesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Title
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:TITLE_TEXT_SIZE];
    self.titleLabel.text = LOC(@"AUTOMATIC TRANSCRIPTION", @"Transcription").localizedCapitalizedString;
    
    self.tableView.rowHeight = CELL_HEIGHT_SEARCH_MENU_TABLEVIEWCELL;
    allLanguagesArray = [self.transcriptionModel.supportedLanguageCodesDictionary.allValues
                   sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _transcriptionModel = nil;
}

- (TranscriptionModel*) transcriptionModel {
    if(!_transcriptionModel) {
        _transcriptionModel = [TranscriptionModel new];
    }
    return _transcriptionModel;
}

-(NSString*)languageForRowIndex:(NSInteger)index {
    return [allLanguagesArray objectAtIndex:index];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return allLanguagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchMenuTableViewCell *cell = [CellFactory cellSearchMenuTableViewCellFromTable:tableView forIndexPath:indexPath];
    
    NSString *language = [self languageForRowIndex:indexPath.row];
    cell.titleLabel.text = language;
    cell.cellTag = indexPath.row;
    NSString *langCode = [self.transcriptionModel codeForLanguage:language];
    cell.iconImageName = @"icon_tick";
    cell.iconHighlightedImageName = @"icon_tick";
    
    BOOL isSelected = [self.transcriptionModel.transctiptionLanguageCode isEqualToString:langCode];
    cell.iconImageView.hidden = !isSelected;
    cell.delegate = self;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self cellSelectedWithTag:indexPath.row];
}

#pragma mark - Create Instance

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:[NSBundle mainBundle]];
    TranscriptionViewController *transcriptionViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_TRANSCRIPTION];
    return transcriptionViewController;
}

#pragma mark - CloseButton

-(IBAction)backButtonPressed:(id)sender {
    if(!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - SearchMenuTableViewCellDelegate

-(void)cellSelectedWithTag:(NSUInteger) cellTag {
    NSInteger index = cellTag;
    NSString *language = [self languageForRowIndex:index];
    NSString *langCode = [self.transcriptionModel codeForLanguage:language];
    [self.transcriptionModel setTransctiptionLanguageCode:langCode];
    [self.tableView reloadData];
}

@end
