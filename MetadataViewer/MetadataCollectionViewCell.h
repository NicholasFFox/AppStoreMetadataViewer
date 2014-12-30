//
//  MetadataCollectionViewCell.h
//  MetadataViewer
//
//  Created by Nicholas Fox on 12/30/14.
//  Copyright (c) 2014 nickfoxdesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetadataCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *details;

@property (strong, nonatomic) IBOutlet UIImageView *artwork;

//this is currently unused
@property (strong, nonatomic) NSMutableArray *screenshotData;


- (void) configureCellWithTitle:(NSString*)title andDetails:(NSString*)details;

@end
