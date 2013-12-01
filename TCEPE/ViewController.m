//
//  ViewController.m
//  TCEPE
//
//  Created by Raphael Araujo on 11/17/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import "ViewController.h"
#import "BidsViewController.h"

@interface ViewController ()
- (IBAction)actionEmailComposer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tcepe.png"]];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.title = @"Início";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(((UIButton *)sender).tag == 1)
    {
        BidsViewController *vc = [segue destinationViewController];
        vc.areBookmarks = YES;
    }
}

- (IBAction)actionEmailComposer {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"ouvidoria@tce.pe.gov.br"]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    
    else {
        
        NSLog(@"O seu dispositivo móvel está incapaz de enviar email no momento.");
        
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(!error)
    {
        if(result == MFMailComposeResultSent)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sucesso!" message:[NSString stringWithFormat:@"Sua mensagem foi encaminhada à Ouvidoria do TCE-PE."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Erro!" message:[NSString stringWithFormat:@" Tente novamente em instantes!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
