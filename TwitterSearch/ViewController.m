//
//  ViewController.m
//  TwitterSearch
//
//  Created by Raul Uranga on 7/12/12.
//  Copyright (c) 2012 GrupoW. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize tweets;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)keyboardShown:(NSNotification *)note {
    // resize UITableView depending on the keyboard size
    CGRect keyboardFrame;
    [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGRect tableViewFrame =  self.tableView.frame;
    tableViewFrame.size.height -= keyboardFrame.size.height;
    [self.tableView setFrame:tableViewFrame];
}

- (void)keyboardHiiden:(NSNotification *)note {
    // reset UITableView size
    [self.tableView setFrame:self.view.bounds];
}

#pragma mark - View lifecycle

- (void)searchRequest {
    
    // 1 - set up search params!
    NSString *q = @"iOS 5";
    NSString *rpp=@"5";
    NSString *with_twitter_user_id = @"true";
    NSString *result_type = @"recent";
    // 2 - map params in to a NSDictionary
    NSDictionary *queryParams;
    queryParams = [NSDictionary dictionaryWithObjectsAndKeys:q, @"q", rpp, @"rpp", with_twitter_user_id, @"with_twitter_user_id", result_type, @"result_type", nil];
    // 3 - send request
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    RKURL *URL = [RKURL URLWithBaseURL:[objectManager baseURL] resourcePath:@"/search.json" queryParameters:queryParams];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@", [URL resourcePath], [URL query]] delegate:self];
    
    NSLog(@"resource path: %@", [NSString stringWithFormat:@"%@?%@", [URL resourcePath], [URL query]]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1 - start listen UIKeyboard!
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHiiden:) name:UIKeyboardWillHideNotification object:nil];
    
    tweets = [[NSMutableArray alloc] init];
    
    // 2 - set up the base URL
    RKURL *baseURL = [RKURL URLWithBaseURLString:@"http://search.twitter.com/"];
    RKObjectManager *objectManager = [RKObjectManager objectManagerWithBaseURL:baseURL];
    objectManager.client.baseURL = baseURL;
    
    // 3 - map Tweet class with the JSON response
    RKObjectMapping *tweetMapping = [RKObjectMapping mappingForClass:[Tweet class]];
    [tweetMapping mapKeyPathsToAttributes:@"created_at",@"created_at",
                                         @"from_user",@"from_user",
                                         @"from_user_name",@"from_user_name",
                                         @"profile_image_url",@"profile_image_url",
                                         @"text",@"text",
                                         @"id_str",@"id_str",nil];
    [objectManager.mappingProvider setMapping:tweetMapping forKeyPath:@"results"];
    
    // 4 - send search request!
    [self searchRequest];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSearchBar:nil];
    _searchBar = nil;
    _tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource protocols implementations

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweets count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 1 - set up cell id
    static NSString *CellIdentifier = @"TweetCell";
    
    // 2 - setup custom cell
    TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // 3 - start filling all labels!
    Tweet *tweet = [tweets objectAtIndex:indexPath.row];
    
    cell.usernameLabel.text = tweet.from_user;
    cell.userLabel.text = [NSString stringWithFormat:@"@%@", tweet.from_user];
    cell.timeLabel.text = tweet.created_at;
    cell.textLabel.text = tweet.text;
    
    return cell;
}

#pragma mark -
#pragma mark UISearchBarDelegate implementation

/*
 *  if users clears the search text field, hide the keyboard!
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder) 
                        withObject: nil 
                        afterDelay: 0.1];
    }
}

/*
 *  start new search based on the UISearchBar textfield value
 */
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}


#pragma mark -
#pragma mark RKObjectLoaderDelegate implementation

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error localizedDescription]);
    // 1 - display error message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error retrieving Tweets" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"response code: %d", [response statusCode]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    
    NSLog(@"objects[%d]", [objects count]);
    [tweets removeAllObjects];
    for (Tweet *t in objects) {
        [tweets addObject:t];
    }
    [self.tableView reloadData];
}

@end
