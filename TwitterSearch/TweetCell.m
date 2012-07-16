//
//  TweetCell.m
//  TwitterSearch
//
//  Created by Raul Uranga on 7/13/12.
//  Copyright (c) 2012 GrupoW. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell

@synthesize userLabel;
@synthesize usernameLabel;
@synthesize timeLabel;
@synthesize textLabel;
@synthesize userImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {   
    [super layoutSubviews];
    CGRect usernameRect = usernameLabel.frame;    
    CGRect useRect = userLabel.frame;
    useRect.origin.x = usernameRect.origin.x + usernameRect.size.width + 3;
    userLabel.frame = useRect;
    self.imageView.frame = CGRectMake( 10, 8, 48, 48 );
}


@end
