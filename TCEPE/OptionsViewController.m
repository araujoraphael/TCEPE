//
//  OptionsViewController.m
//  TCEPE
//
//  Created by Raphael Araujo on 11/19/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *filterNameLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
-(void)clearTableView;
@end


@implementation OptionsViewController

@synthesize delegate;

NSDictionary *filterOptions;
NSArray *options;
NSInteger selectedRow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tcepe.png"]];
    
    
    switch (self.filterId) {
        case 1:
            filterOptions = JUDGEMENT_DIC;
            self.filterNameLabel.text = @"Critério de julgamento";
            break;
        case 2:
            filterOptions = PHASE_DIC;
            self.filterNameLabel.text = @"Estágio";
            break;
        case 3:
            filterOptions = TYPE_DIC;
            self.filterNameLabel.text = @"Modalidade";
            break;
        case 4:
            filterOptions = STATUS_DIC;
            self.filterNameLabel.text = @"Situação";
            break;
        default:
            filterOptions = YEARS_DIC;
            self.filterNameLabel.text = @"Ano";
            break;
    }
    
    NSArray* keys = [filterOptions allKeys];

    options = [keys  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDelegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self clearTableView];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate didSelectOptionWithIndex:[NSNumber numberWithInteger:self.filterId] option:cell.textLabel.text];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- UITableViewDataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filterOptions count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(indexPath.row == 0)
    {
        if(self.filterId < 3)
         cell.textLabel.text = @"Todos";
        else
        {
            cell.textLabel.text = @"Todas";
        }
    }
    else
    {
        cell.textLabel.text = options[indexPath.row-1];
    }
    
    return cell;
}

-(void)clearTableView
{
    int row = 0;
    int section = 0;
    for (row = 0; row < [filterOptions count]; row++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
       
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
}
@end
