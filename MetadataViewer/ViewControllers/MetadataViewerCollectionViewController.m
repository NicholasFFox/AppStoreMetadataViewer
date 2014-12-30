//
//  MetadataViewerCollectionViewController.m
//  MetadataViewer
//
//  Created by Nicholas Fox on 12/30/14.
//  Copyright (c) 2014 nickfoxdesigns. All rights reserved.
//

#import "MetadataViewerCollectionViewController.h"
#import "MetadataCollectionViewCell.h"


@interface MetadataViewerCollectionViewController ()

@end

@implementation MetadataViewerCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //hide status bar for cleaner appearance
    [self prefersStatusBarHidden];
    
    
    // register cell classes
    [self.collectionView registerClass:[MetadataCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    //reach out and get metadata
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/lookup?id=912144293"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // The server answers with an error because it doesn't receive the params
        
        if (data != nil) {
            // Convert the returned data into a dictionary.
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error != nil) {
                
                NSLog(@"%@", [error localizedDescription]);
                
            } else{
                
                NSDictionary *md = [[returnedDict objectForKey:@"results"] objectAtIndex:0];
                
                self.metadata = md;
                
                //debug logging
                //                for (NSString *key in [md allKeys]) {
                //                    NSLog(@"key %@ - value %@", key, [md objectForKey:key]);
                //                }
                
            }
        }
        dispatch_semaphore_signal(semaphore);
        
    }];
    [getDataTask resume];
    
    //TODO: rewrite to retry if request fails.
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.metadata.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MetadataCollectionViewCell *cell = [collectionView
                                        dequeueReusableCellWithReuseIdentifier:@"metadataCell"
                                        forIndexPath:indexPath];
    
    
    
    NSString *title = [[self.metadata allKeys]objectAtIndex:indexPath.row];
    
    
    NSString *details = @"";
    if ([[self.metadata objectForKey:title] isKindOfClass:[NSArray class]]) {
        for (NSString *item in [self.metadata objectForKey:title]) {
            details = [NSString stringWithFormat:@"%@\n%@", details, item];
        }
        
    } else {
        details = [[self.metadata objectForKey:title] description];
    }
    
    //plug basic info into cell
    [cell configureCellWithTitle:title andDetails:details];
    
    //update height of cell
    [UIView animateWithDuration:0.2f animations:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
    }];
    
    
    //handle artwork and screenshot cells
    
    if ([[title lowercaseString] containsString:@"artwork"]) {
        
        NSURL *imageURL = [NSURL URLWithString:details];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            if (imageData) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    //verify cell is still showing, and if so then update image and display
                    MetadataCollectionViewCell *updateCell = (id)[collectionView cellForItemAtIndexPath:indexPath];
                    if (updateCell) {
                        [cell.artwork setImage:[UIImage imageWithData:imageData]];
                        
                        //TODO: Scrolling feels awkward...
                        
                        [UIView animateWithDuration:0.2f animations:^{
                            [self.collectionView.collectionViewLayout invalidateLayout];
                        }];
                        
                    }
                });
            }
        });
        
        
    } else if ([[title lowercaseString] containsString:@"screenshot"]) {
        
        NSArray *screenshotData = [self.metadata objectForKey:title];
        
        if (screenshotData && screenshotData.count > 0) {
            
            NSString *screenshotURL = [[self.metadata objectForKey:title] objectAtIndex:0];
            
            NSURL *imageURL = [NSURL URLWithString:screenshotURL];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            
            dispatch_async(queue, ^{
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                
                if (imageData) {
                    [cell.screenshotData addObject:imageData];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        MetadataCollectionViewCell *updateCell = (id)[collectionView cellForItemAtIndexPath:indexPath];
                        if (updateCell) {
                            
                            [cell.artwork setImage:[UIImage imageWithData:imageData]];
                            [cell.artwork setContentMode:UIViewContentModeScaleAspectFit];
                            
                            //TODO: Scrolling feels a bit awkward...
                            [UIView animateWithDuration:0.2f animations:^{
                                [self.collectionView.collectionViewLayout invalidateLayout];
                            }];
                            
                        }
                    });
                }
            });
        }
    }
    
    
    return cell;
    
}


/*
 * This is where I am going to dynamically determine the size of the cell, and size appropriately.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MetadataCollectionViewCell *cell = (MetadataCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    //grab height of title and details, add spacing
    int height = cell.title.bounds.size.height + cell.details.bounds.size.height + 50;
    
    //if cell has image, add additional spacing
    if (cell.artwork.image) {
        height += 170;
    }
    
    return CGSizeMake(self.view.superview.frame.size.width-20, height);
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
