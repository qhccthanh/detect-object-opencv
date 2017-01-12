//
//  PickTemplateViewController.m
//  LogoDetector
//
//  Created by Quach Ha Chan Thanh on 11/17/16.
//  Copyright © 2016 altaibayar tseveenbayar. All rights reserved.
//

#import "PickTemplateViewController.h"
#import "SelectionViewController.h"
#import "DZImageEditingController.h"
#import "CLImageEditor.h"

@interface PickTemplateViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLImageEditorDelegate>

@property NSMutableArray<UIImage *> *templateTypeArray;
@property NSMutableArray<NSString *> *headerTypeArray;

@end

@implementation PickTemplateViewController

- (void)viewDidLoad {
    
    // Do any additional setup after loading the view.
    
    _templateTypeArray = [[NSMutableArray alloc] init];
    
    // Add array UIImage for section HCN Vertical
    [_templateTypeArray addObjectsFromArray:@[
                                              [UIImage imageNamed:@"LyZalo.jpg"],
                                              [UIImage imageNamed:@"Olong.jpg"],
                                              [UIImage imageNamed:@"Balo.JPG"],
                                              [UIImage imageNamed:@"IP4.jpg"],
                                              [UIImage imageNamed:@"Vi.jpg"],
                                              [UIImage imageNamed:@"Quat.jpeg"],
                                              ]];

    
    // Add header Section
    _headerTypeArray = [[NSMutableArray alloc] initWithObjects:@"Hình chữ nhật đứng", @"Hình chữ nhật ngang", @"Hình vuông", nil];
    
    NSArray *listFile = [self listFileAtPath:CACHE_PATH];
    
    for (NSString* file in listFile) {
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[CACHE_PATH stringByAppendingPathComponent:file]];
        if (image) {
            [_templateTypeArray addObject:image];
        }
    }
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//The event handling photo method
- (void)addNewTemplateAction {
    //  Location on tap
    
    //  CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    //Do stuff here...
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction* takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                    
                                                                    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                                          message:@"Device has no camera"
                                                                                                                         delegate:nil
                                                                                                                cancelButtonTitle:@"OK"
                                                                                                                otherButtonTitles: nil];
                                                                    [myAlertView show];
                                                                }
                                                                else{
                                                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                    picker.delegate = self;
                                                                    picker.allowsEditing = NO;
                                                                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                    
                                                                    [self presentViewController:picker animated:YES completion:NULL];
                                                                }
                                                            }];
    
    UIAlertAction* selectPhotoAction = [UIAlertAction actionWithTitle:@"Select Photo" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                  picker.delegate = self;
                                                                  picker.allowsEditing = NO;
                                                                  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                  
                                                                  [self presentViewController:picker animated:YES completion:NULL];
                                                              }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:^{}];
                                                         }];
    
    [alert addAction:takePhotoAction];
    [alert addAction:selectPhotoAction];
    [alert addAction:cancelAction];
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [collectionView setContentInset:UIEdgeInsetsMake(8, 0, 8, 0)];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _templateTypeArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell;
    NSString *reuseIdentifierCell = @"ImageCell";
    
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        reuseIdentifierCell = @"AddNewTemplateCell";
    }
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 10;
    cell.layer.borderWidth = 2;
    cell.layer.borderColor = [UIColor colorWithRed:24.0/255 green:49.0/255 blue:79.0/255 alpha:1].CGColor;
    
    UIImageView *imageView = [cell.contentView viewWithTag:101];
    if (imageView) {
        imageView.image =  _templateTypeArray[indexPath.row];
    }
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        [self addNewTemplateAction];
    } else {
        SelectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectionViewController"];
        
        if (vc) {
            vc.templateSelected = _templateTypeArray[indexPath.row];
            [self.navigationController pushViewController:vc animated:true];
        }
    }
    
    return false;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        return CGSizeMake(collectionView.frame.size.width, 80);
    }
    
    return CGSizeMake(collectionView.frame.size.width * 0.48, 250);
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        CLImageEditor *editingViewController = [[CLImageEditor alloc] initWithImage:pickImage];
        
        //required
        editingViewController.delegate = self;
        
        [self.navigationController presentViewController:editingViewController animated:true completion:nil];
    }];
}

#pragma mark - CLImageEditorDelegate

- (void)imageEditor:(CLImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image {
    
    [_templateTypeArray addObject:image];
    [self.templateCollectionView reloadData];
    NSString *fileName = [NSString stringWithFormat:@"%d.jpg",(int)[NSDate new].timeIntervalSince1970];
    NSString *saveImagePath = [CACHE_PATH stringByAppendingPathComponent:fileName];
    
    [UIImageJPEGRepresentation(image, 0.8) writeToFile:saveImagePath atomically:YES];
    
    
    [editor dismissViewControllerAnimated:true completion:nil];
}

- (void)imageEditorDidCancel:(CLImageEditor *)editor {
    
    [editor dismissViewControllerAnimated:true completion:nil];
}

-(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

@end
