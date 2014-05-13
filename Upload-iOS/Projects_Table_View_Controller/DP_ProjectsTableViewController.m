//
//  DP_ProjectsTableViewController.m
//  Upload-iOS
//
//  Created by Danish Ahmed Ansari on 19/03/14.
//  Copyright (c) 2014 Danish Ahmed Ansari. All rights reserved.
//

#import "DP_ProjectsTableViewController.h"
#import "DP_AddProjectViewController.h"
#import "DP_ProjectDetailViewController.h"

#import "DP_FetchProjectsFromServer.h"

#import <UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>

@interface DP_ProjectsTableViewController () <DP_ProjectsHTTPClientDelegate>

@property (nonatomic, strong) DP_FetchProjectsFromServer *client;
@property (nonatomic, strong) NSArray *fetchedResultsArray;

// MBProgressHUD
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation DP_ProjectsTableViewController

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
    
    self.title = @"Projects";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refetchDataFromServer:)
                                                 name:@"REFRESH_DATA" object:nil];
    
    self.navigationController.navigationBar.translucent = FALSE;
    self.fetchedResultsArray = [NSArray array];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ProjectCell"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem *addProjectBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProjectBarButtonPressed:)];
    self.navigationItem.leftBarButtonItem = addProjectBarButton;

    UIBarButtonItem *refreshProjectsListBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchDataFromServer)];
    self.navigationItem.rightBarButtonItem = refreshProjectsListBarButton;
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    [_hud setLabelFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
    
    [self.view addSubview:_hud];

    [self fetchDataFromServer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self.view window] == nil) {
    }
}

- (void)refetchDataFromServer:(NSNotification *)notification {
    [self fetchDataFromServer];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.fetchedResultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell" forIndexPath:indexPath
                             ];
    
    // Configure the cell...
    NSDictionary *dict = self.fetchedResultsArray[indexPath.row];
    cell.textLabel.text = dict[@"name"];
    
    
    NSURL *url = [NSURL URLWithString:dict[@"attachment_medium_url"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak UITableViewCell *weakCell = cell;
    
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.imageView.image = image;
                                       [weakCell setNeedsLayout];
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"FAILED TO DOWNLOAD IMAGE - %@", [error localizedDescription]);
                                   }];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    DP_ProjectDetailViewController *detailViewController = [[DP_ProjectDetailViewController alloc] initWithNibName:@"DP_ProjectDetailViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    detailViewController.project_dict = self.fetchedResultsArray[indexPath.row];
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark - Add Project Bar Button
- (IBAction)addProjectBarButtonPressed:(id)sender {
    DP_AddProjectViewController *addProjectVC = [[DP_AddProjectViewController alloc] initWithNibName:@"DP_AddProjectViewController" bundle:nil];
    UINavigationController *addProjctNavC = [[UINavigationController alloc] initWithRootViewController:addProjectVC];
    
    [self presentViewController:addProjctNavC animated:YES completion:^{
        
    }];
}

- (void)fetchDataFromServer {
    [_hud setLabelText:@"Fetching Projects"];
    [_hud show:TRUE];
    self.client = [DP_FetchProjectsFromServer sharedInstance];
    self.client.delegate = self;
    [self.client getDataForPath:@"projects" withParameters:nil];
}

#pragma mark - DP_FetchProjectsFromServer Delegate Methods

- (void)projectsHTTPClient:(DP_FetchProjectsFromServer *)client didUpdateWithData:(id)projects {
    
    self.fetchedResultsArray = (NSArray *)projects;

    [_hud hide:TRUE afterDelay:0.3];
    [_hud setLabelText:@""];
    [self.tableView reloadData];
}

- (void)projectsHTTPClient:(DP_FetchProjectsFromServer *)client didFailWithError:(NSError *)error {
    [_hud setLabelText:@"Error"];
    [_hud setDetailsLabelText:[error localizedDescription]];
    [_hud hide:TRUE afterDelay:1.0];
    NSLog(@"ERROR - %@", error);
}

@end
