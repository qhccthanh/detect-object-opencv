//
//  SelectionViewController.m
//  LogoDetector
//
//  Created by Quach Ha Chan Thanh on 11/17/16.
//  Copyright © 2016 altaibayar tseveenbayar. All rights reserved.
//

#import "SelectionViewController.h"
#import "ImageUtils.h"
#import "ReportViewController.h"
#import "CameraViewController.h"

@interface SelectionViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *selectionArray;

@end

@implementation SelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectionArray =   [[NSMutableArray alloc] initWithArray:@[
                                                            @"Feature2D",
                                                            @"MatchingTemplate",
                                                            @"Matching Template Rotation",
                                                            @"Feature2D + Matching Template",
                                                            @"Back",
                                                            ]
                         ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backAction {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITableViewDataSources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _selectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = _selectionArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _selectionArray.count - 1) {
        [self dismissViewControllerAnimated:true completion:nil];
        return NULL;
    }
    
    if (indexPath.row == 0) {
        CameraViewController *cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeViewController"];
        
        if(cameraVC) {
            cameraVC.templateImage = self.templateSelected;
            [self presentViewController:cameraVC animated:true completion:nil];
        }
            
    }
    
    ReportViewController *reportVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    
    if (reportVC) {
        reportVC.templateSelected = self.templateSelected;
        [self presentViewController:reportVC animated:true completion:nil];
    }
    
    return NULL;
}


@end








