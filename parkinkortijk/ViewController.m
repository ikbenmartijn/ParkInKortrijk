//
//  ViewController.m
//  parkinkortijk
//
//  Created by Martijn Vandenberghe on 22/05/13.
//  Copyright (c) 2013 Martijn Vandenberghe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize dataBron;
@synthesize sensoren, vrijeParkeerplaatsen;
@synthesize parkeerplaatsenKaart, parkeerplaatsenTabel, parkeerplaatsenTabelRefreshControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    //Zet de kaart en de tabel uit op de view
    //1. Kaart
    parkeerplaatsenKaart = [[MKMapView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                       self.view.bounds.origin.y,
                                                                       CGRectGetWidth(self.view.bounds),
                                                                       150)];
    [self.view addSubview:parkeerplaatsenKaart];
    
    //2a. Tabel
    parkeerplaatsenTabel = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                         150,
                                                                         CGRectGetWidth(self.view.bounds),
                                                                         CGRectGetHeight(self.view.bounds) - 150)];
    [parkeerplaatsenTabel setDelegate:self];
    [parkeerplaatsenTabel setDataSource:self];
    [self.view addSubview:parkeerplaatsenTabel];
    
    //2b. Refreshcontrol voor de tabel
    parkeerplaatsenTabelRefreshControl = [[UIRefreshControl alloc] init];
    [parkeerplaatsenTabelRefreshControl addTarget:self action:@selector(herlaadData:) forControlEvents:UIControlEventValueChanged];
    [parkeerplaatsenTabel addSubview:parkeerplaatsenTabelRefreshControl];
    
    //Haal de data op en bevolk de views
    dataBron = [[DataBron alloc] init];
    [dataBron setDelegate:self];
}

#pragma mark - DataBron delegate methods

- (void)dataOpgevraagdVoorAlleSensoren:(NSArray*)gekregenSensoren {    
    //Alle sensoren zijn opgevraagd, deel de data met de tabel
    
    //Creeër ruimte voor de vrije parkeerplaatsen
    if (!vrijeParkeerplaatsen) {
         vrijeParkeerplaatsen = [[NSMutableArray alloc] init];
    }
    
    //Overloop de sensoren en voeg toe aan 'vrije plaatsen' en plaats een pin op de kaart
    for (Sensor *sensor in gekregenSensoren) {
        if (sensor.vrij) {
            [vrijeParkeerplaatsen addObject:sensor];
            
            SimpelePin *pin = [[SimpelePin alloc] initMetCoordinaat:sensor.locatie.coordinate];
            [parkeerplaatsenKaart addAnnotation:pin];
        }
    }
    
    //Zorg ervoor dat de kaart de pins op een nuttige manier toont
    [self zoomInOpDeKaart:self.parkeerplaatsenKaart];
    
    //Vul de tabel
    [parkeerplaatsenTabel reloadData];
}

#pragma mark - Eigen functies

- (void)zoomInOpDeKaart:(MKMapView*)kaart {
    MKMapRect zoomRect = MKMapRectNull;
    
    //Haal de onderstaande lijnen uit comments als je ook de gebruiks' locatie wil meenemen in de kaart
    /*
     MKMapPoint annotationPoint = MKMapPointForCoordinate(kaart.userLocation.coordinate);
     zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
     */
    
    //Overloop elke pin, neem telkens het gebied al 'union' zodat we van een superklein naar een goed leesbare kaart gaan
    for (id<MKAnnotation> annotation in kaart.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 1.0, 1.0);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    //Wat magie om niet helemaal tegen de randen te plakken
    zoomRect.origin.y = zoomRect.origin.y - 250;
    zoomRect.size.width = zoomRect.size.width * 1.1;
    zoomRect.size.height = zoomRect.size.height * 1.1;
    
    //Pas de zoomrect toe
    [kaart setVisibleMapRect:zoomRect animated:YES];
}

- (void)herlaadData:(id)sender {
    //Leeg de bestaande tabel, kaart en data
    for (id<MKAnnotation>pin in parkeerplaatsenKaart.annotations) {
        [parkeerplaatsenKaart removeAnnotation:pin];
    }
    vrijeParkeerplaatsen = nil;
    
    //Haal nieuwe data en stop de refresher
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        parkeerplaatsenTabelRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Laden..."];
        [dataBron haalParkeerDataOp:self];
        dispatch_async(dispatch_get_main_queue(), ^{            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"H:mm"];
            NSString *laatstGeladen = [NSString stringWithFormat:@"Laatst geladen op %@", [formatter stringFromDate:[NSDate date]]];
            parkeerplaatsenTabelRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:laatstGeladen];
            
            [self.parkeerplaatsenTabelRefreshControl endRefreshing];
        });
    });    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [vrijeParkeerplaatsen count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"SensorCel";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]; } //did the subtitle style

    cell.textLabel.text = [[vrijeParkeerplaatsen objectAtIndex:indexPath.row] straat];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Zone: %i - Plaatsnummer: %i", [[vrijeParkeerplaatsen objectAtIndex:indexPath.row] parkingZone],
                                                                                           [[vrijeParkeerplaatsen objectAtIndex:indexPath.row] parkingBay]];
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}




@end
