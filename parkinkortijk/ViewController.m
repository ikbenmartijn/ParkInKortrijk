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
@synthesize sensoren;
@synthesize vrijeParkeerplaatsen;

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
    dataBron = [[DataBron alloc] init];
    [dataBron setDelegate:self];
}

#pragma mark - DataBron delegate methods

- (void)dataOpgevraagdVoorAlleSensoren:(NSArray*)gekregenSensoren {
    //Alle sensoren zijn opgevraagd.
    MKMapView *kaart = [[MKMapView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                   self.view.bounds.origin.y,
                                                                   CGRectGetWidth(self.view.bounds),
                                                                   150)];
    [self.view addSubview:kaart];
    
    if (nil == sensoren) {
        sensoren = gekregenSensoren;
        vrijeParkeerplaatsen = [[NSMutableArray alloc] init];
    }
    
    for (Sensor *sensor in sensoren) {
        if (sensor.vrij) {
            [vrijeParkeerplaatsen addObject:sensor];
            SimpelePin *pin = [[SimpelePin alloc] initMetCoordinaat:sensor.locatie.coordinate];
            [kaart addAnnotation:pin];
        }
    }
    
    MKMapRect zoomRect = MKMapRectNull;
    /*
    MKMapPoint annotationPoint = MKMapPointForCoordinate(kaart.userLocation.coordinate);
    zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    */
    for (id<MKAnnotation> annotation in kaart.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 100, 100);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    zoomRect.origin.y = zoomRect.origin.y - 250;
    zoomRect.size.width = zoomRect.size.width * 1.05;
    zoomRect.size.height = zoomRect.size.height * 1.05;
    
    [kaart setVisibleMapRect:zoomRect animated:YES];
    
    UITableView *parkeerTabel = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                              150,
                                                                              CGRectGetWidth(self.view.bounds),
                                                                              CGRectGetHeight(self.view.bounds) - 150)];
    [parkeerTabel setDelegate:self];
    [parkeerTabel setDataSource:self];
    [self.view addSubview:parkeerTabel];
    
    UIRefreshControl *verfrisser = [[UIRefreshControl alloc] init];
    [verfrisser addTarget:dataBron action:@selector(haalParkeerDataOp:) forControlEvents:UIControlEventValueChanged];
    [parkeerTabel addSubview:verfrisser];
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Zone: %i - Bay: %i", [[vrijeParkeerplaatsen objectAtIndex:indexPath.row] parkingZone],
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
