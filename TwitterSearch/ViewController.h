//
//  ViewController.h
//  TwitterSearch
//
//  Created by Raul Uranga on 7/12/12.
//  Copyright (c) 2012 GrupoW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "Tweet.h"
#import "TweetCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "TTTTimeIntervalFormatter.h"
#import "MBProgressHUD.h"
#import "SSPullToRefreshView.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, RKObjectLoaderDelegate, SSPullToRefreshViewDelegate>  {
    __weak IBOutlet UISearchBar *_searchBar;
    __weak IBOutlet UITableView *_tableView;
     __weak SSPullToRefreshView *_pullToRefreshView;
    BOOL usingPullToRefresh;
}

@property (strong, nonatomic) NSMutableArray *tweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(weak, nonatomic) SSPullToRefreshView *pullToRefreshView;

@end
