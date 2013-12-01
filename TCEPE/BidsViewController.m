//
//  BidsViewController.m
//  TCEPE
//
//  Created by Raphael Araujo on 11/21/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import "BidsViewController.h"
#import "BidTableViewCell.h"
#import <AFNetworking.h>

@interface BidsViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

-(IBAction)reloadTapped:(id)sender;
@end

@implementation BidsViewController

NSArray *bids;
NSMutableArray *bookmarkBids;
NSMutableArray *bookmarks;
NSString *selectedBidID;

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
	// Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tcepe.png"]];

    self.isBacking = NO;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"Buscando licitacões...";
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    
    [HUD show:YES];
    if(!self.areBookmarks)
    {
        [self filterBids];
    }
    
    else
    {
       bookmarks = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"bookmarks"];
        
        bookmarkBids = [[NSMutableArray alloc] initWithCapacity:[bookmarks count]];
        
        if([bookmarks count] > 0)
            [self requestBid:bookmarks[0] willIndex:0];
        else
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.hidden = YES;
    self.tableView.alpha = 0.0;
    self.loadingView.hidden = NO;
    if(!self.isBacking) bids = nil;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.title = @"Licitações";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        self.loadingView.hidden = YES;
        self.tableView.hidden = NO;
        
        // animate in
        [UIView beginAnimations:@"button_in" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.tableView.alpha = 1.0f;
        [UIView commitAnimations];

    }
}

-(void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedBidID = [[bids objectAtIndex:indexPath.row] valueForKey:@"codigo"];
    [self performSegueWithIdentifier:@"BidDetailSegue" sender:self];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BidDetailsViewController *vc = [segue destinationViewController];
    vc.delegate = self;
    vc.bidID = selectedBidID;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [bids count];
}


// ; the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"BidTableViewCell";
    
    BidTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSObject *bid = [bids objectAtIndex:indexPath.row];
    if(!cell)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BidTableViewCell" owner:self options:nil];
        cell = (BidTableViewCell *)[nibs objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.typeLabel.text = [bid valueForKey:@"modalidade"];
    cell.objectLabel.text = [bid valueForKey:@"ClassificacaoObjeto"];
    cell.yearLabel.text = [bid valueForKey:@"ano"];
    cell.processLabel.text = [NSString stringWithFormat:@"%@/%@",[bid valueForKey:@"numero"], cell.yearLabel.text ];
        
    if([[cell.typeLabel.text uppercaseString]  isEqual: @"CONCORRÊNCIA"])
    {
        cell.colorIndicatorView.backgroundColor = kUIColorArray[0];
        cell.typeLabel.textColor = kUIColorArray[0];
    }
    else if([[cell.typeLabel.text uppercaseString]  isEqual: @"CONVITE"])
    {
        cell.colorIndicatorView.backgroundColor = kUIColorArray[1];
        cell.typeLabel.textColor = kUIColorArray[1];
    }
    
    else if([[cell.typeLabel.text uppercaseString]  isEqual: @"DISPENSA"])
    {
        cell.colorIndicatorView.backgroundColor = kUIColorArray[2];
        cell.typeLabel.textColor = kUIColorArray[2];
    }
    
    else if([[cell.typeLabel.text uppercaseString]  isEqual: @"INEXIGIBILIDADE"])
    {
        cell.colorIndicatorView.backgroundColor = kUIColorArray[3];
        cell.typeLabel.textColor = kUIColorArray[3];
    }
    
    else if([[cell.typeLabel.text uppercaseString]  isEqual: @"LEILÃO"])
    {
        cell.colorIndicatorView.backgroundColor = kUIColorArray[4];
        cell.typeLabel.textColor = kUIColorArray[4];
    }
    
    else if([[cell.typeLabel.text uppercaseString]  isEqual: @"PREGÃO ELETRÔNICO"])
    {
        cell.colorIndicatorView.backgroundColor = kUIColorArray[5];
        cell.typeLabel.textColor = kUIColorArray[5];
    }
    
    else if([[cell.typeLabel.text uppercaseString]  isEqual: @"PREGÃO PRESENCIAL"])
    {
        cell.colorIndicatorView.backgroundColor = kUIColorArray[6];
        cell.typeLabel.textColor = kUIColorArray[6];
    }
    
    else if([[cell.typeLabel.text uppercaseString]  isEqual: @"TOMADA DE PREÇOS"])
    {
        cell.colorIndicatorView.backgroundColor = kUIColorArray[7];
        cell.typeLabel.textColor = kUIColorArray[7];
    }
    
    NSMutableArray *bookmarks = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"bookmarks"];
    
    if([bookmarks containsObject:[bid valueForKey:@"codigo"]])
    {
        cell.bookmarkedButton.selected = YES;
    }
    
    else
    {
        cell.bookmarkedButton.selected = NO;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}

-(void)filterBids
{
    NSString *requestUrl = [URLSERVER stringByAppendingString:  @"?acao=filtro"];
    BOOL noFilter = YES;
    
    if(self.yearValue)
    {
        requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&ano=%@", self.yearValue]];
        
        noFilter = NO;
    }
    
    if(self.judgeValue)
    {
        requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&julgamento=%@", self.judgeValue]];
        
        noFilter = NO;

    }
    
    if(self.typeValue)
    {
        requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&modalidade=%@", self.typeValue]];
        
        noFilter = NO;

    }
    
    if(self.phaseValue)
    {
        requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&estagio=%@", self.phaseValue]];
        
        noFilter = NO;

    }

    if(self.statusValue)
    {
        requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&situacao=%@", self.statusValue]];
        
        noFilter = NO;

    }
    NSLog(@"%@", requestUrl);
    
    //requestUrl = @"http://www.paulodiniz.com.br/tce/webservice.php?acao=filtro&ano=2013&julgamento=2";
    if(noFilter)
    {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

        self.infoLabel.text = @"Você precisa selecionar pelo menos uma opção do filtro na tela anterior.";
        
        [UIView beginAnimations:@"button_in" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.loadingView.hidden = NO;
        self.infoLabel.alpha = 1.0f;
        self.tableView.alpha = 0.0f;
        [UIView commitAnimations];

    }
    
    else
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:requestUrl
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 bids = responseObject;
                 [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                 
                 if([bids count] > 0)
                 {
                     
                     MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                     [self.navigationController.view addSubview:HUD];
                     
                     HUD.dimBackground = YES;
                     HUD.labelText = [NSString stringWithFormat:@"Carregando %d licitações", [bids count]];
                     
                     // Regiser for HUD callbacks so we can remove it from the window at the right time
                     HUD.delegate = self;
                     
                     [HUD show:YES];
                     
                     [self.tableView reloadData];
                 }
                 
                 else
                 {
                     self.infoLabel.text = @"Não foi possível encontrar uma licitação com os parâmetros informados. Tente novamente com outros valores.";
                     
                     [UIView beginAnimations:@"button_in" context:nil];
                     [UIView setAnimationDelegate:self];
                     [UIView setAnimationDuration:0.4];
                     [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                     [UIView setAnimationBeginsFromCurrentState:YES];
                     self.loadingView.hidden = NO;
                     self.infoLabel.alpha = 1.0f;
                     self.tableView.alpha = 0.0f;
                     [UIView commitAnimations];
                     
                 }
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 switch (error.code) {
                     case -1009:
                         self.infoLabel.text = @"Verifique sua conexão com a Internet e recarregue o conteúdo.";
                         break;
                         
                     default:
                         self.infoLabel.text = @"Erro na consulta com o banco de dados. Tente novamente em instantes";
                         break;
                 }
                 //             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Erro na consulta com o banco de dados. Tente novamente em instantes" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 //             [av show];
                 
                 [UIView beginAnimations:@"anime" context:nil];
                 [UIView setAnimationDelegate:self];
                 [UIView setAnimationDuration:0.4];
                 [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                 [UIView setAnimationBeginsFromCurrentState:YES];
                 self.loadingView.hidden = NO;
                 self.infoLabel.alpha = 1.0f;
                 self.tableView.alpha = 0.0f;
                 
                 [UIView commitAnimations];
                 
                 [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                 
             }];
 
    }
}

-(void)didTurnBack
{
    self.isBacking = YES;
}

-(void)bookmarkBidTapped
{
    if(self.areBookmarks)
    {
        NSMutableArray *bookmarks = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"bookmarks"];
        
        bookmarkBids = [[NSMutableArray alloc] initWithCapacity:[bookmarks count]];
        
        if([bookmarks count] > 0)
            [self requestBid:bookmarks[0] willIndex:0];
        else
        {
            [UIView beginAnimations:@"button_in" context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            self.infoLabel.alpha = 0.0f;
            self.tableView.alpha = 0.0f;
            [self.tableView reloadData];
            [UIView commitAnimations];
        }

    }
}

-(void)reloadTapped:(id)sender
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"Buscando licitacões...";
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    
    [HUD show:YES];
    
    [UIView beginAnimations:@"button_in" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.infoLabel.alpha = 0.0f;
    self.tableView.alpha = 0.0f;
    [UIView commitAnimations];
    
    if(!self.areBookmarks)
    {
        [self filterBids];
    }
    
    else
    {
        NSMutableArray *bookmarks = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"bookmarks"];
        
        bookmarkBids = [[NSMutableArray alloc] initWithCapacity:[bookmarks count]];
        
        if([bookmarks count] > 0)
            [self requestBid:bookmarks[0] willIndex:0];
        else
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }
}

-(void)requestBid:(NSString *)bidID willIndex:(NSInteger )index
{
    NSString *requestUrl = [URLSERVER stringByAppendingString:  @"?acao=licitacaoID"];
    
    if(bidID)
    {
        requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&codigo=%@", bidID]];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSObject *bid;
             bid = responseObject;
             [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
             
             NSArray *bidsTmp = (NSArray *)bid;
             NSObject *bidTmp;
             if(bidsTmp) bidTmp = [bidsTmp objectAtIndex:0];
             if(bidTmp)
             {
                 [UIView beginAnimations:@"button_in" context:nil];
                 [UIView setAnimationDelegate:self];
                 [UIView setAnimationDuration:0.4];
                 [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                 [UIView setAnimationBeginsFromCurrentState:YES];
                 self.loadingView.hidden = YES;
                 self.infoLabel.alpha = 0.0f;
                 self.tableView.alpha = 1.0f;

                 [UIView commitAnimations];
                 
                 [bookmarkBids addObject:bidTmp];
                 
                 if(index == [bookmarks count] - 1)
                 {
                     bids = bookmarkBids;
                     [self.tableView reloadData];
                 }
                 else
                 {
                     [self requestBid:bookmarks[index + 1] willIndex:index+1];
                 }
                 
                 
             }
             
             else
             {
                 NSLog(@"erro no método requestBid:withIndex!");
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             switch (error.code) {
                 case -1009:
                     self.infoLabel.text = @"Verifique sua conexão com a Internet e recarregue o conteúdo.";
                     break;
                     
                 default:
                     self.infoLabel.text = @"Erro na consulta com o banco de dados. Tente novamente em instantes";
                     break;
             }
             
             
             [UIView beginAnimations:@"anime" context:nil];
             [UIView setAnimationDelegate:self];
             [UIView setAnimationDuration:0.4];
             [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
             [UIView setAnimationBeginsFromCurrentState:YES];
             self.loadingView.hidden = NO;
             self.infoLabel.alpha = 1.0f;
             self.tableView.alpha = 0.0f;

             [UIView commitAnimations];
             
             [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
             
         }];
}

@end
