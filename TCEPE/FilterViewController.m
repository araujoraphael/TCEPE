//
//  BidsViewController.m
//  TCEPE
//
//  Created by Raphael Araujo on 11/18/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import "FilterViewController.h"
#import "OptionsViewController.h"
#import "BidsViewController.h"

@interface FilterViewController ()
@property (nonatomic, weak) IBOutlet UIPickerView *yearDatePicker;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *yearButton;
@property (nonatomic, weak) IBOutlet UIButton *judgeButton;
@property (nonatomic, weak) IBOutlet UIButton *typeButton;
@property (nonatomic, weak) IBOutlet UIButton *phaseButton;
@property (nonatomic, weak) IBOutlet UIButton *statusButton;

@end

@implementation FilterViewController

NSInteger currentFilter;

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

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.title = @"Filtro";
}

#pragma mark - OptionsDelegate methods

- (void) didSelectOptionWithIndex:(NSNumber *)index option:(NSString *)option
{
    switch (index.integerValue) {
        case 0:
            [self.yearButton setTitle:option forState:UIControlStateNormal];
            [self.yearButton setTitle:option forState:UIControlStateHighlighted];
            break;
        case 1:
            [self.judgeButton setTitle:option forState:UIControlStateNormal];
            [self.judgeButton setTitle:option forState:UIControlStateHighlighted];
            break;
        case 2:
            [self.phaseButton setTitle:option forState:UIControlStateNormal];
            [self.phaseButton setTitle:option forState:UIControlStateHighlighted];
            break;
        case 3:
            [self.typeButton setTitle:option forState:UIControlStateNormal];
            [self.typeButton setTitle:option forState:UIControlStateHighlighted];
            break;
        case 4:
            [self.statusButton setTitle:option forState:UIControlStateNormal];
            [self.statusButton setTitle:option forState:UIControlStateHighlighted];
            break;
        default:
            break;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"bidssegue"])
    {
        if((![self.phaseButton.titleLabel.text isEqualToString:@"Todos"]) || (![self.statusButton.titleLabel.text isEqualToString:@"Todas"]) )
        {
            return YES;
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção" message:@"Você deve selecionar, pelo menos, um ESTÁGIO ou uma SITUAÇÃO para prosseguir." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            return NO;
        }

    }
    
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(((UIButton *)sender).tag < 5)
    {
        OptionsViewController *vc = [segue destinationViewController];
        vc.filterId = ((UIButton *)sender).tag;
        vc.delegate = self;
        
        currentFilter = vc.filterId;
    }
    else
    {
        BidsViewController *vc = [segue destinationViewController];
        NSDictionary *yearValues = YEARS_DIC;
        NSDictionary *judgeValues = JUDGEMENT_DIC;
        NSDictionary *typeValues = TYPE_DIC;
        NSDictionary *phaseValues = PHASE_DIC;
        NSDictionary *statusValues = STATUS_DIC;
        
        NSString *year = [yearValues valueForKey:self.yearButton.titleLabel.text];
        NSString *judge = [judgeValues valueForKey:self.judgeButton.titleLabel.text];
        NSString *type = [typeValues valueForKey:self.typeButton.titleLabel.text];
        NSString *phase = [phaseValues  valueForKey:self.phaseButton.titleLabel.text];
        NSString *status = [statusValues valueForKey:self.statusButton.titleLabel.text];
        
        vc.yearValue = year;
        vc.judgeValue = judge;
        vc.typeValue = type;
        vc.phaseValue = phase;
        vc.statusValue = status;
        vc.areBookmarks = NO;
        
    }
}
@end
