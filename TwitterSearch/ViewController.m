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
@synthesize pullToRefreshView = _pullToRefreshView;
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

- (BOOL)isTweetAlreadyAdded:(Tweet *)tweet {
    NSArray *duplicates = [tweets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id_str == %@", tweet.id_str]];
    return [duplicates count] > 0 ? YES : NO;
}

- (void)searchRequest {
    
    // 1 - set up search params!
    NSString *q = searchQuery;
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
    
    // 4 - display loading indicator
    if (usingPullToRefresh) {
        [self.pullToRefreshView startLoading];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1 - start listen UIKeyboard!
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHiiden:) name:UIKeyboardWillHideNotification object:nil];
    
    tweets = [[NSMutableArray alloc] init];
    
    // 1.1 - Initialize UISearchBar
    [self.searchBar setText:@"iOS 5"];
    searchQuery = [self.searchBar text];
    
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
    
    // 3.1 - set up  SSPullToRefreshView
    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    
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
    
    // 1.1 - set up TTTTimeIntervalFormatter singleton
    static TTTTimeIntervalFormatter *_timeIntervalFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        [_timeIntervalFormatter setUsesAbbreviatedCalendarUnits:YES];
        [_timeIntervalFormatter setLocale:[NSLocale currentLocale]];
    }); 
    
    // 2 - setup custom cell
    TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // 3 - start filling all labels!
    Tweet *tweet = [tweets objectAtIndex:indexPath.row];
    
    cell.usernameLabel.text = tweet.from_user;
    cell.userLabel.text = [NSString stringWithFormat:@"@%@", tweet.from_user];
    
    // 3.1 - format date with TTTTimeIntervalFormatter
    NSDateFormatter *df = [[NSDateFormatter alloc] init];                                                         
    [df setDateFormat:@"eee, dd MMM yyyy HH:mm:ss ZZZZ"]; //Tue, 10 Jul 2012 15:50:04 +0000
    NSDate *date = [df dateFromString:tweet.created_at];
    NSDate *now = [[NSDate alloc] init];
    cell.timeLabel.text = [_timeIntervalFormatter stringForTimeIntervalFromDate:now toDate:date];
    
    cell.textLabel.text = tweet.text;
    
    // 4 - load profile image
    [cell.imageView setImageWithURL:[NSURL URLWithString:tweet.profile_image_url] placeholderImage:[UIImage imageNamed:@"twitteranon0.png"]];
    cell.imageView.layer.cornerRadius = 5.0;
    cell.imageView.layer.masksToBounds = YES;
    
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
    
    // 1 - hide keyboard
    [self.searchBar resignFirstResponder];
    
    // 2 - save search textfield value
    searchQuery = [self.searchBar text];
    usingPullToRefresh = NO;
    
    // 3 - this is a new search, remove all previous tweets!
    [tweets removeAllObjects];
    [self.tableView reloadData];
    
    // 4 - perform search
    [self searchRequest];
}


#pragma mark -
#pragma mark RKObjectLoaderDelegate implementation

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error localizedDescription]);
    // 1 - display error message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error retrieving Tweets" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    
    // 2 - hide loading indicator
    if (usingPullToRefresh) {
        [self.pullToRefreshView finishLoading];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    usingPullToRefresh = NO;
    
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"response code: %d", [response statusCode]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    
    NSLog(@"objects[%d]", [objects count]);
    
    // 1 - populate TableView
    [self.tableView beginUpdates];  
    NSArray* reversedArray = [[objects reverseObjectEnumerator] allObjects];            //revert fetched tweets!
    NSMutableArray *insertion = [[NSMutableArray alloc] init];                          //this array will hold all NSIndexPaths objects
    int insertIdx = 0;   
    for (Tweet *t in reversedArray) {
        if (![self isTweetAlreadyAdded:t]) {                                            //check is tweet is already added in array
            [tweets insertObject:t atIndex:insertIdx];                                  //insert new tweet
            [insertion addObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]];  //insert NSIndexPath
            insertIdx++;
        }
    }   
    [self.tableView insertRowsAtIndexPaths:insertion withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    
    // 2 - hide loading indicator
    if (usingPullToRefresh) {
        [self.pullToRefreshView finishLoading];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    usingPullToRefresh = NO;
    
}

#pragma mark -
#pragma mark SSPullToRefreshViewDelegate implementation

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
    usingPullToRefresh = YES;
    [self searchRequest];
}

@end
