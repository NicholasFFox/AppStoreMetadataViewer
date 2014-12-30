//
//  MetadataCollectionViewCell.m
//  MetadataViewer
//
//  Created by Nicholas Fox on 12/30/14.
//  Copyright (c) 2014 nickfoxdesigns. All rights reserved.
//

#import "MetadataCollectionViewCell.h"

@implementation MetadataCollectionViewCell

- (MetadataCollectionViewCell *) init {
    self = [super init];
    
    self.screenshotData = [[NSMutableArray alloc] initWithCapacity:5];
    
    return self;
}


- (void) configureCellWithTitle:(NSString *)title andDetails:(NSString *)details {
    self.title.text = title;
    self.details.text = [details description];
    
    self.artwork.image = nil;
}



@end
