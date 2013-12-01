//
//  BidDetailsViewController.m
//  TCEPE
//
//  Created by Raphael Araujo on 11/22/13.
//  Copyright (c) 2013 Raphael Araujo. All rights reserved.
//

#import "BidDetailsViewController.h"
#import <AFNetworking.h>

@interface BidDetailsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *bidIDLabel;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;
@property (nonatomic, weak) IBOutlet UILabel *openDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberYearLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIButton *bookmarkedButton;
@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

-(IBAction)bookmarkTapped:(id)sender;
-(IBAction)reloadTapped:(id)sender;

@end

@implementation BidDetailsViewController

@synthesize delegate;

NSObject *bid;

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

    self.scrollView.contentSize = CGSizeMake(320, 550);
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"Buscando licitacões...";
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    
    [HUD show:YES];
    
    [self requestBid];

}

-(void)viewWillAppear:(BOOL)animated
{
    self.loadingView.hidden = NO;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.delegate didTurnBack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestBid
{
    NSString *requestUrl = [URLSERVER stringByAppendingString:  @"?acao=licitacaoID"];
    
    if(self.bidID)
    {
        requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"&codigo=%@", self.bidID]];
    }
    

    NSLog(@"%@", requestUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             bid = responseObject;
             [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
             
             NSArray *bids = (NSArray *)bid;
             if(bids) bid = [bids objectAtIndex:0];
             if(bid)
             {
                 [self formatScrollViewWithBid:bid];
                 
                 NSMutableArray *bookmarks = [[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarks"];
                 
                 if([bookmarks containsObject:[bid valueForKey:@"codigo"]])
                 {
                     self.bookmarkedButton.selected = YES;
                 }
                 [UIView beginAnimations:@"button_in" context:nil];
                 [UIView setAnimationDelegate:self];
                 [UIView setAnimationDuration:0.4];
                 [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                 [UIView setAnimationBeginsFromCurrentState:YES];
                 self.loadingView.hidden = YES;
                 self.infoLabel.alpha = 0.0f;
                 [UIView commitAnimations];
             }
             
             else
             {
                 self.infoLabel.text = @"Licitação não encontrada. Recarregue o conteúdo ou refaça a pesquisa.";
                 
                 [UIView beginAnimations:@"button_in" context:nil];
                 [UIView setAnimationDelegate:self];
                 [UIView setAnimationDuration:0.4];
                 [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                 [UIView setAnimationBeginsFromCurrentState:YES];
                 self.loadingView.hidden = NO;
                 self.infoLabel.alpha = 1.0f;
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

             
             [UIView beginAnimations:@"anime" context:nil];
             [UIView setAnimationDelegate:self];
             [UIView setAnimationDuration:0.4];
             [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
             [UIView setAnimationBeginsFromCurrentState:YES];
             self.loadingView.hidden = NO;
             self.infoLabel.alpha = 1.0f;
             [UIView commitAnimations];
             
             [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
             
         }];
}

-(void)formatScrollViewWithBid:(NSObject *)bid
{
    CGFloat yOffSet;
        
    UIFont *helvetica17 = [UIFont fontWithName:@"Helvetica-bold" size:17.f];
    UIFont *helvetica14 = [UIFont fontWithName:@"Helvetica" size:14.f];

    self.bidIDLabel.text = [NSString stringWithFormat:@"Objeto - %@", self.bidID];
    
    NSString *numberYearStr =@"";
    
    NSString *number = [bid valueForKey:@"numero"];
    
    if(number)
    {
        @try {
            numberYearStr = [NSString stringWithFormat:@"%@/", number];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }

    }
    
    NSString *year = [bid valueForKey:@"ano"];
    
    if(year)
    {
        @try {
            numberYearStr = [numberYearStr stringByAppendingString: year];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }
        
    }
    
    self.numberYearLabel.text = numberYearStr;
    
    NSString *typeStr = [bid valueForKey:@"modalidade"];
    
    if(typeStr)
    {
        @try {
            self.typeLabel.text = [NSString stringWithFormat:@"Modalidade: %@", typeStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }

        
    }
    
    NSString *openDateStr = [bid valueForKey:@"dataabertura"];
    if(openDateStr)
    {
        @try {
            self.openDateLabel.text = openDateStr;
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            self.openDateLabel.text = @"Data de abertura não informada";
        }
        @finally {
        }
    }
    
    NSString *objectStr = [bid valueForKey:@"ClassificacaoObjeto"];
    
    if(objectStr)
    {
        @try {
            
            UILabel *objectLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 140, 308, 100)];
            objectLabel.text = objectStr;//[NSString stringWithFormat: @"%@", [bid valueForKey:@"ClassificacaoObjeto"]];
            objectLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
            objectLabel.numberOfLines = 0;
            [objectLabel sizeToFit];
            [objectLabel adjustsFontSizeToFitWidth];
            
            [self.scrollView addSubview:objectLabel];
            
            yOffSet = objectLabel.frame.origin.y + objectLabel.frame.size.height + 20;

        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }
            }
    
    NSString *kindStr = [bid valueForKey:@"naturezaObj"];
    
    if(kindStr)
    {
        @try {
            CGRect frame = CGRectMake(6, yOffSet, 200, 21);
            UILabel *kindLabel = [[UILabel alloc] initWithFrame:frame];
            kindLabel.font = helvetica17;
            kindLabel.text = @"Natureza do Objeto";
            kindLabel.textColor = kUIColorArray[6];
            
            [self.scrollView addSubview:kindLabel];
            
            yOffSet = kindLabel.frame.origin.y + kindLabel.frame.size.height + 8;
            
            
            UILabel *kindDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, yOffSet, 308, 21)];
            kindDescLabel.text = kindStr;//[NSString stringWithFormat: @"%@", [bid valueForKey:@"ClassificacaoObjeto"]];
            kindDescLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
            kindDescLabel.numberOfLines = 0;
            [kindDescLabel sizeToFit];
            [kindDescLabel adjustsFontSizeToFitWidth];
            
            [self.scrollView addSubview:kindDescLabel];
            
            yOffSet = kindDescLabel.frame.origin.y + kindDescLabel.frame.size.height + 20;

        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }

    }

    
    
    NSString *objectAttributesStr = [bid valueForKey:@"caracteristicaObj"];
    
    if(objectAttributesStr)
    {
        @try {
            CGRect frame = CGRectMake(6, yOffSet, 200, 21);
            UILabel *objectAttributesLabel = [[UILabel alloc] initWithFrame:frame];
            objectAttributesLabel.font = helvetica17;
            objectAttributesLabel.text = @"Característica";
            objectAttributesLabel.textColor = kUIColorArray[6];
            
            [self.scrollView addSubview:objectAttributesLabel];
            
            yOffSet = objectAttributesLabel.frame.origin.y + objectAttributesLabel.frame.size.height + 8;
            
            frame = CGRectMake(6, yOffSet, 308, 21);
            
            UILabel *objectAttributesDescLabel = [[UILabel alloc] initWithFrame:frame];
            objectAttributesDescLabel.font = helvetica14;
            objectAttributesDescLabel.text = objectAttributesStr;
            objectAttributesDescLabel.numberOfLines = 0;
            [objectAttributesDescLabel sizeToFit];
            
            [self.scrollView addSubview:objectAttributesDescLabel];
            
            yOffSet = objectAttributesDescLabel.frame.origin.y + objectAttributesDescLabel.frame.size.height + 20;
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }

    }
    
   
    NSString *phaseStr = [bid valueForKey:@"estagio"];
    
    if(phaseStr)
    {
        @try {
            CGRect frame = CGRectMake(6, yOffSet, 100, 21);
            UILabel *phaseLabel = [[UILabel alloc] initWithFrame:frame];
            phaseLabel.font = helvetica17;
            phaseLabel.text = @"Estágio";
            phaseLabel.textColor = kUIColorArray[6];
            
            [self.scrollView addSubview:phaseLabel];
            
            yOffSet = phaseLabel.frame.origin.y + phaseLabel.frame.size.height + 8;
            
            frame = CGRectMake(6, yOffSet, 308, 21);
            
            UILabel *phaseLabelDesc = [[UILabel alloc] initWithFrame:frame];
            phaseLabelDesc.font = helvetica14;
            phaseLabelDesc.text = phaseStr;
            phaseLabelDesc.numberOfLines = 0;
            [phaseLabelDesc sizeToFit];
            
            [self.scrollView addSubview:phaseLabelDesc];
            
            yOffSet = phaseLabelDesc.frame.origin.y + phaseLabelDesc.frame.size.height + 20;

        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }

       
    }
    
    NSString *statusStr = [bid valueForKey:@"situacao"];
    
    if(statusStr)
    {
        @try {
            CGRect frame = CGRectMake(6, yOffSet, 100, 21);
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:frame];
            statusLabel.font = helvetica17;
            statusLabel.text = @"Situação";
            statusLabel.textColor = kUIColorArray[6];
            
            [self.scrollView addSubview:statusLabel];
            
            yOffSet = statusLabel.frame.origin.y + statusLabel.frame.size.height + 8;
            
            frame = CGRectMake(6, yOffSet, 308, 21);
            
            UILabel *statusLabelDesc = [[UILabel alloc] initWithFrame:frame];
            statusLabelDesc.font = helvetica14;
            statusLabelDesc.text = statusStr;
            statusLabelDesc.numberOfLines = 0;
            [statusLabelDesc sizeToFit];
            
            [self.scrollView addSubview:statusLabelDesc];
            
            yOffSet = statusLabelDesc.frame.origin.y + statusLabelDesc.frame.size.height + 20;

        }
        @catch (NSException *exception) {
        }
        @finally {
        }

        
    }
    
    NSString *totalPriceStr = [bid valueForKey:@"precototal"];
    
    if(totalPriceStr)
    {
        @try {
            CGRect frame = CGRectMake(6, yOffSet, 100, 21);
            UILabel *totalPriceLabel = [[UILabel alloc] initWithFrame:frame];
            totalPriceLabel.font = helvetica17;
            totalPriceLabel.text = @"Preço Total";
            totalPriceLabel.textColor = kUIColorArray[6];
            
            [self.scrollView addSubview:totalPriceLabel];
            
            yOffSet = totalPriceLabel.frame.origin.y + totalPriceLabel.frame.size.height + 8;
            
            frame = CGRectMake(6, yOffSet, 308, 21);
            
            NSArray *splittedStr = [totalPriceStr componentsSeparatedByString:@"."];
            NSString *splittedStrLeft = splittedStr[0];
            NSString *splittedStrRight = splittedStr[1];
            
            totalPriceStr = [NSString stringWithFormat:@"R$ %@,%c%c",splittedStrLeft, [splittedStrRight characterAtIndex:0], [splittedStrRight characterAtIndex:1] ];
            UILabel *totalPriceLabelDesc = [[UILabel alloc] initWithFrame:frame];
            totalPriceLabelDesc.font = helvetica14;
            totalPriceLabelDesc.text = totalPriceStr;
            totalPriceLabelDesc.numberOfLines = 0;
            [totalPriceLabelDesc sizeToFit];
            
            [self.scrollView addSubview:totalPriceLabelDesc];
            
            yOffSet = totalPriceLabelDesc.frame.origin.y + totalPriceLabelDesc.frame.size.height + 20;

        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
        }

            }

}

-(IBAction)bookmarkTapped:(id)sender
{
    NSMutableArray *bookmarks = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"bookmarks"];
    
    NSMutableArray *newBookmarks;
    
    if(self.bookmarkedButton.selected)
    {
        [bookmarks removeObject:[bid valueForKey:@"codigo"]];
        newBookmarks = bookmarks;
        self.bookmarkedButton.selected = NO;
    }
    
    else
    {
        if([bookmarks count] > 0)
        {
            newBookmarks = [NSMutableArray arrayWithArray:bookmarks];
            
            if(![newBookmarks containsObject:[bid valueForKey:@"codigo"]])
            {
                [newBookmarks addObject:[bid valueForKey:@"codigo"]];
            }
        }
        else
        {
            newBookmarks = [[NSMutableArray alloc] init];

            [newBookmarks addObject:[bid valueForKey:@"codigo"]];
        }
        self.bookmarkedButton.selected = YES;

    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:newBookmarks forKey:@"bookmarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [self.delegate bookmarkBidTapped];
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
    self.loadingView.hidden = NO;
    self.infoLabel.alpha = 0.0f;
    [UIView commitAnimations];
    
    [self requestBid];
    
}


@end
