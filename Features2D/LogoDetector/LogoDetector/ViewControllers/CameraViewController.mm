//
// This sample is published as part of the blog article at www.toptal.com/blog
// Visit www.toptal.com/blog and subscribe to our newsletter to read great posts
////////

//
//  CameraViewController.m
//  LogoDetector
//
//  Created by altaibayar tseveenbayar on 13/05/15.
//  Copyright (c) 2015 altaibayar tseveenbayar. All rights reserved.
//

#import "CameraViewController.h"
#import <opencv2/highgui/ios.h>
#import "UIImage+Orientation.h"
#import "MLManager.h"
#import "ImageUtils.h"
#import "GeometryUtil.h"

#import "Features2D-Homo.hpp"

#ifdef DEBUG
#import "FPS.h"
#endif

//this two values are dependant on defaultAVCaptureSessionPreset
#define CAMERA_WIDTH (540)
#define CAMERA_HIGHT (960)
#define LIMIT_TIME_PROCESS_IMAGE 0.01
#define RATE_SUM_MIN_MAX_REDUCE 1000000

@interface CameraViewController() <CvVideoCameraDelegate>
{
    CvVideoCamera *camera;
    BOOL started;
    
    NSMutableArray *images;
    NSUInteger count;
    
    BOOL flag;
    UIImage *basedObject;
    
    UIImageView *previewImage;
    
    int tH,tW;
    double minSumTemplate;
}

@property Mat scaleTemplateMat;
@property vector<Mat> scaleTemplateMatArray;
@property vector<cv::Size> scaleTemplateSizeArray;
@property double lastTimeProcessImage;
@property cv::Rect lastRectProcessImage;
@property double sumMinMaxLimit;

@end

@implementation CameraViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
//    flag = NO;
    //UI
//    [_btn setTitle: @" " forState: UIControlStateNormal];
//    
//    previewImage = [[UIImageView alloc] initWithFrame:_img.frame];
//    previewImage.contentMode = UIViewContentModeScaleAspectFit;
//    previewImage.backgroundColor = [UIColor blackColor];

    //Camera
    camera = [[CvVideoCamera alloc] initWithParentView: _img];
    camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    camera.defaultFPS = 30;
    camera.useAVCaptureVideoPreviewLayer = NO;
    camera.rotateVideo = NO;

//     camera.grayscaleMode = NO;
    camera.delegate = self;

    started = NO;
    //_img.image = [UIImage imageNamed:@"scene1.jpg"];
    // Scale to with 250
    if (self.templateImage) {
        
        NSArray *arrayScale = @[@(100),@(200),@(300)];
        _scaleTemplateMat = [ImageUtils cvMatFromUIImage:self.templateImage];
        
        for(NSNumber *scaleWith in arrayScale) {
            UIImage *scaleTemplateImage = [ImageUtils imageWithImage:self.templateImage scaledToWidth:[scaleWith floatValue]];
            Mat t  = [ImageUtils cvMatFromUIImage:scaleTemplateImage];
            Mat templateT = t.clone();
            cvtColor(t,t,CV_BGR2GRAY);
            
            Canny(t,t,10,100);
            _scaleTemplateMatArray.push_back(t);
            _scaleTemplateSizeArray.push_back(cv::Size(t.cols,t.rows));
            string tempStr = "";
            
            if (arrayScale.firstObject == scaleWith) {
                Mat temp = MatchingTemplateWithMultiScale(_scaleTemplateMat, templateT, TM_CCOEFF, tempStr);
                
                NSString *resultStr = [NSString stringWithUTF8String:tempStr.c_str()];
                NSArray<NSString *> *componentLogString = [resultStr componentsSeparatedByString:@"\t"];
                if (componentLogString.count == 6) {
                    NSString* minValString = componentLogString[2];
                    NSString* maxValString = componentLogString[3];
                    
                    _sumMinMaxLimit = [minValString doubleValue] + [maxValString doubleValue] - RATE_SUM_MIN_MAX_REDUCE;
                }
            }
        }
        
        _lastTimeProcessImage = [NSDate new].timeIntervalSince1970;
        _lastRectProcessImage = cv::Rect(0,0,0,0);
        
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    //[self test];
    [camera start];
    
    images = [[NSMutableArray alloc] init];
    
    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_water1.jpg"]]);
    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_water2.jpg"]]);
    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_water3.jpg"]]);

}


- (IBAction)btn_TouchUp:(id)sender 
{
    flag = NO;
   // [camera takePicture];
//   // started = !started;
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    [self presentViewController:picker animated:YES completion:NULL];
}



- (IBAction)btn_TouchUp2:(id)sender
{
//    if (previewImage.superview != nil) {
//        [previewImage removeFromSuperview];
//    }
//    [camera start];
    [camera stop];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)photoCamera:(CvPhotoCamera *)photoCamera capturedImage:(UIImage *)image {
    image = [image fixOrientation];
    if (_photoHandler) {
        _photoHandler(image);
    }
}

- (IBAction)btn1_TouchUp:(id)sender
{
    flag = YES;
    //[camera takePicture];
//    // started = !started;
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    [self presentViewController:picker animated:YES completion:NULL];
}



-(void)processImage:(cv::Mat &)image
{
    
    if ([NSDate new].timeIntervalSince1970 - _lastTimeProcessImage < LIMIT_TIME_PROCESS_IMAGE) {
        
        if (_lastRectProcessImage.area() != 0) {
            rectangle(image, _lastRectProcessImage, Scalar(255,0,0) , 3, 8, 0);
        }
        
        return;
    }
    
    
    NSTimeInterval curT = [NSDate new].timeIntervalSince1970;
    
    // STEP 1 cvt to gray
    Mat image_detect = image.clone();
    cvtColor(image_detect, image_detect, CV_BGR2GRAY);
    // STEP 2 defind maxValGen, minValGen, maxLocGen,minLocGen, ratio
    bool found = false;
    double maxValGen = 0;
    double minValGen = INT_MAX;
    cv::Point maxLocGen,minLocGen;
    double ratio = 1;
    
    bool flagBreak = false;
    vector<Mat> cacheCannyMatArray;
    cv::Size sizeTemplatePicked;
    
    // For array template
    for(int j = 0 ; j < _scaleTemplateMatArray.size(); j++) {
        // STEP 3: Paramic image_detect from 30% to 100% step 5%
        Mat templateMat = _scaleTemplateMatArray[j];
        cv::Size templateSize = _scaleTemplateSizeArray[j];
        
        for(int i = 30; i <= 100; i+=5) {
            // STEP 3.1: Scale Scene
            Mat scale_image_detect;
            
            int width_scale = (image_detect.cols * i * 1.0/100);
            int height_scale = (image_detect.rows * i * 1.0/100);
            
            if (width_scale < templateSize.width || height_scale < templateSize.height) {
                continue;
            }
            
            float r = 100/(i * 1.0);
            int index = (i - 30)/5;
            
            // STEP 3.2: Detect edge scale_image and matching template
            Mat edge_mat, result;
            
            // STEP 3.2b: check edgeMat in Cache
            if (index < cacheCannyMatArray.size()) {
                edge_mat = cacheCannyMatArray[index];
            } else {
                resize(image_detect, scale_image_detect, cv::Size(width_scale,height_scale));
                Canny(scale_image_detect, edge_mat, 50, 400);
                cacheCannyMatArray.push_back(edge_mat);
            }
            
            
            matchTemplate(edge_mat, templateMat, result, TM_CCOEFF);
            
            // STEP 3.3: Find minMaxLoc
            double minVal; double maxVal; cv::Point minLoc; cv::Point maxLoc;
            minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);
            
            if (minVal == INT_MAX || maxVal == 0) {
                //  printf("\nBreak because minVal: %f, maxVal: %f, minVal + maxVal: %f", minVal,maxVal,minVal + maxVal);
                flagBreak = true;
                break;
            }
            
            // STEP 3.4: Find min max of paramic scene_image
            if (!found || maxVal > maxValGen ){
                found = true;
                maxValGen = maxVal;
                maxLocGen = maxLoc;
                ratio = r;
                sizeTemplatePicked = templateSize;
            }
            
            if (minVal < minValGen) {
                minValGen = minVal;
                minLocGen = minLoc;
            }
        }
        
        if (minValGen == INT_MAX || maxValGen == 0) {
            //  printf("\nBreak because minVal: %f, maxVal: %f, minVal + maxVal: %f", minVal,maxVal,minVal + maxVal);
            flagBreak = true;
            break;
        }
    }
    
    // STEP 4: Check break
    if (minValGen == INT_MAX || maxValGen == 0 || minValGen + maxValGen < _sumMinMaxLimit) {
      //  printf("\nBreak because minVal: %f, maxVal: %f, minVal + maxVal: %f", minValGen,maxValGen,minValGen + maxValGen);
        flagBreak = true;
    }
    
    // STEP 5: draw to result
    if (!flagBreak) {
        string output = format("\n(%d,%d)\t%.4f\t%.2f\t%.2f\t(%d,%d)\t(%d,%d)",tW,tH,ratio,minValGen,maxValGen,minLocGen.x,minLocGen.y,maxLocGen.x,maxLocGen.y);
        
       // printf("%s",output.c_str());
        
        
        
        //# unpack the bookkeeping varaible and compute the (x, y) coordinates
        //# of the bounding box based on the resized ratio
        int oX = int(maxLocGen.x * ratio);
        int oY = int(maxLocGen.y * ratio);
        int oW = int((maxLocGen.x + sizeTemplatePicked.width) * ratio);
        int oH = int((maxLocGen.y + sizeTemplatePicked.height) * ratio);
        
        if (oW > 0.9 * image.cols || oH > 0.9 * image.rows) {
            _lastTimeProcessImage = [NSDate new].timeIntervalSince1970;
            return;
        }
        
        rectangle(image, cv::Point(oX,oY), cv::Point(oW,oH), Scalar(255,0,0) , 3, 8, 0 );
        _lastRectProcessImage = cv::Rect(oX,oY,oW,oH);
    } else {
        _lastRectProcessImage = cv::Rect(0,0,0,0);
    }
    
    _lastTimeProcessImage = [NSDate new].timeIntervalSince1970;
    
    printf("Timer: %.5f\n",[NSDate new].timeIntervalSince1970 - curT );

}

@end





