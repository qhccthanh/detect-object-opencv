//
//  Features2D-Homo.cpp
//  LogoDetector
//
//  Created by MACMALL MF840 on 11/3/16.
//  Copyright © 2016 altaibayar tseveenbayar. All rights reserved.
//

#include "Features2D-Homo.hpp"

using namespace std;

vector<Mat> template_image;


vector<KeyPoint> getKeyPoint(Mat mat) {
    int minHessian = 400;
    
    SurfFeatureDetector detector( minHessian );
    std::vector<KeyPoint> keypoints;
    
    detector.detect( mat, keypoints );
    
    return keypoints;
}



Rect_<int> detectFeature2D_TemplateMatch(Mat img_scene_rgb, int& index_template) {
    
    // 1: Tìm keypoint của hình scene nếu keypoint hình scene < 100 coi như không nhận được
    vector<KeyPoint> keypoints = getKeyPoint(img_scene_rgb);
    
    printf("Number of scene keypoints: %lu", keypoints.size());
    
    if (keypoints.size() < 150) {
        return Rect(0,0,0,0);
    }
    
    // 2: Xét ảnh scene với các mẫu ảnh và tính số goodMatch trong mỗi lần so sánh
    vector<int> *good_matchs_with_template = new vector<int>();
    vector<int> *good_matchs_with_template_index = new vector<int>();
    
    for(int i = 0 ; i < template_image.size(); i++) {
        
        int number_good_match = detectFeature2D(template_image[i], img_scene_rgb);
        
        if (number_good_match > 15 && number_good_match < 450) {
            good_matchs_with_template->push_back(number_good_match);
            good_matchs_with_template_index->push_back(i);
        }
        
        printf("****Number of object image index: %d -- good matches: %d \n", i, number_good_match);
        
    }

    // 3: Nếu tổng goodMatch < n còn không coi như detect không được
    int indexMax = -1;
    int max_good_match = 0;
    
    for(int i = 0 ; i < good_matchs_with_template->size(); i++) {
        
        if( (*good_matchs_with_template)[i] > max_good_match) {
            indexMax = i;
            max_good_match = (*good_matchs_with_template)[i];
        }
    }
    
    if (indexMax == -1) {
        printf("\n-----No result----");
        return Rect(0,0,0,0);
    }
    printf("\nThe image has biggest good matches: %d with: %d", (*good_matchs_with_template_index)[indexMax], max_good_match);
    
    // 4: Dùng Matching template cho ảnh mẫu có goodMatch cao nhất và ảnh scene để lấy Rect
    Rect rect = MatchingMethod(img_scene_rgb, template_image[(*good_matchs_with_template_index)[indexMax]], 0);
    index_template = (*good_matchs_with_template_index)[indexMax];
    
    return rect;
}


int detectFeature2D(Mat img_object_rgb, Mat img_scene_rgb) {
    
    Mat img_object, img_scene;
    
    cvtColor(img_object_rgb, img_object, CV_BGR2GRAY);
    cvtColor(img_scene_rgb, img_scene, CV_BGR2GRAY);

    if( !img_object.data || !img_scene.data )
    {
        std::cout<< " --(!) Error reading images " << std::endl;
        return 0;
    }
    
    //-- Step 1: Detect the keypoints using SURF Detector
    std::vector<KeyPoint> keypoints_object, keypoints_scene;
    
    keypoints_object = getKeyPoint(img_object);
    keypoints_scene = getKeyPoint(img_scene);
    
    //-- Step 2: Calculate descriptors (feature vectors)
    SurfDescriptorExtractor extractor;
    
    Mat descriptors_object, descriptors_scene;
    
    extractor.compute( img_object, keypoints_object, descriptors_object );
    extractor.compute( img_scene, keypoints_scene, descriptors_scene );
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    FlannBasedMatcher matcher;
    
    std::vector< DMatch > matches;
    matcher.match( descriptors_object, descriptors_scene, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_object.rows; i++ )
    {
        double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    printf("\n-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i < descriptors_object.rows; i++ )
    {
        
        if( matches[i].distance > 3 * min_dist )
        {
            good_matches.push_back( matches[i]);
        }
    }
    
//    Mat img_matches;
//    drawMatches( img_object, keypoints_object, img_scene, keypoints_scene,
//                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
//                vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    return (int)good_matches.size();
    
    //-- Localize the object
//    std::vector<Point2f> obj;
//    std::vector<Point2f> scene;
    

    
//    for( int i = 0; i < good_matches.size(); i++ )
//    {
//        //-- Get the keypoints from the good matches
//        obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
//        scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
//    }
//    
//    Mat H = findHomography( obj, scene, CV_RANSAC );
//    
//    
//    //-- Get the corners from the image_1 ( the object to be "detected" )
//    std::vector<Point2f> obj_corners(4);
//    obj_corners[0] = cvPoint(0,0); obj_corners[1] = cvPoint( img_object.cols, 0 );
//    obj_corners[2] = cvPoint( img_object.cols, img_object.rows ); obj_corners[3] = cvPoint( 0, img_object.rows );
//    std::vector<Point2f> scene_corners(4);
//    
//    perspectiveTransform( obj_corners, scene_corners, H);
//    
//    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
//    line( img_matches, scene_corners[0] + Point2f( img_object.cols, 0), scene_corners[1] + Point2f( img_object.cols, 0), Scalar(0, 255, 0), 4 );
//    line( img_matches, scene_corners[1] + Point2f( img_object.cols, 0), scene_corners[2] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
//    line( img_matches, scene_corners[2] + Point2f( img_object.cols, 0), scene_corners[3] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
//    line( img_matches, scene_corners[3] + Point2f( img_object.cols, 0), scene_corners[0] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
//    
    //-- Show detected matches
    //imshow( "Good Matches & Object detection", img_matches );
//    return img_matches;
}

Rect MatchingMethod(Mat img, Mat templ, int match_method)
{
    Mat result, img_display;
    /// Source image to display
    img.copyTo( img_display );
    
    cvtColor(img, img, CV_BGR2GRAY);
    cvtColor(templ, templ, CV_BGR2GRAY);
    
    /// Create the result matrix
    int result_cols =  img.cols - templ.cols + 1;
    int result_rows = img.rows - templ.rows + 1;
    
    if (result_cols < 0 || result_rows < 0) {
        return Rect(0,0,0,0);
    }
    
    result.create( result_rows, result_cols, CV_32FC1 );
    
    /// Do the Matching and Normalize
    matchTemplate( img, templ, result, match_method );
    normalize( result, result, 0, 1, NORM_MINMAX, -1, Mat() );
    
    /// Localizing the best match with minMaxLoc
    double minVal; double maxVal; Point minLoc; Point maxLoc;
    Point matchLoc;
    
    minMaxLoc( result, &minVal, &maxVal, &minLoc, &maxLoc, Mat() );
    
    /// For SQDIFF and SQDIFF_NORMED, the best matches are lower values. For all the other methods, the higher the better
    if( match_method  == CV_TM_SQDIFF || match_method == CV_TM_SQDIFF_NORMED )
    { matchLoc = minLoc; }
    else
    { matchLoc = maxLoc; }
    
    /// Show me what you got
   // rectangle( img_display, matchLoc, Point( matchLoc.x + templ.cols , matchLoc.y + templ.rows ), Scalar::all(0), 2, 8, 0 );
    //rectangle( result, matchLoc, Point( matchLoc.x + templ.cols , matchLoc.y + templ.rows ), Scalar::all(0), 2, 8, 0 );
    
    return Rect(matchLoc.x,matchLoc.y,matchLoc.x + templ.cols,matchLoc.y + templ.rows);
}

Mat MatchingMethodWithDraw(Mat img, Mat templ, int match_method) {
    
    Mat imgResult;
    img.copyTo(imgResult);
    
    Rect rect = MatchingMethod(img, templ, match_method);
    
    rectangle(imgResult, rect, Scalar::all(0), 2, 8, 0 );
    
    return imgResult;
}

Mat MatchingTemplateWithMultiScale(Mat img, Mat templ, int match_method, string &output) {
    return MatchingTemplateWithMultiScale(img,templ,match_method,output, false);
}

Mat MatchingTemplateWithMultiScale(Mat img, Mat templ, int match_method, string &output, bool useFeature2D) {
       // printf("\n.................................\n");
    Mat gray,temp;
    Mat tempT;
    
    img.copyTo(temp);
    templ.copyTo(tempT);
    
    cvtColor(img, gray, CV_BGR2GRAY);
    cvtColor(templ, templ, CV_BGR2GRAY);
    
    cvtColor(tempT, tempT, CV_BGR2GRAY);
    
    Canny(templ, templ, 50, 200);
    
    bool found = false;
    
    double maxValGen = 0;
    double minValGen = INT_MAX;
    int min_good_match = 0;
    int max_good_match = 0;
    
    Point maxLocGen,minLocGen;
    
    bool flag = false;
    
    double ratio = 1;
    
    int tH = templ.rows;
    int tW = templ.cols;
   // printf("-----------\nSize template (%d,%d)",tW,tH);
    // scale 30% -> 100%  step 5%
    for (int i = 40; i <= 90; i += 5) {
        
        //# resize the image according to the scale, and keep track
        //# of the ratio of the resizing
        Mat scale_image;
        
        int width_scale = (gray.cols * i * 1.0/100);
        int height_scale = (gray.rows * i * 1.0/100);
        
//        pyrDown(gray, scale_image, Size(width_scale,height_scale));
        resize(gray, scale_image, Size(width_scale,height_scale));
        
        if ( useFeature2D && (i == 40 || i == 90) ) {
            int number_good_match = DetectNumberGoodMatchFLANNMatcher(scale_image,tempT);
            
            if (i == 40) {
                min_good_match = max_good_match = number_good_match;
            } else {
                if (number_good_match > max_good_match) {
                    max_good_match = number_good_match;
                } else {
                    min_good_match = number_good_match;
                }
            }
            
            if (min_good_match == 0 || max_good_match == 0) {
                break;
            }
        }
        
        
        float r = 100/(i * 1.0);
        
      //  printf("\n**********\nScale: (%d,%d) ratio: %f",width_scale,height_scale,r);
        
        //# if the resized image is smaller than the template, then break
        //# from the loop
        if (width_scale < tW || height_scale < tH) {
            continue;
        }
        
        // detect edges in the resized, grayscale image and apply template
        // matching to find the template in the image
        Mat edge_mat, result;
        
        Canny(scale_image, edge_mat, 50, 400);
        matchTemplate(edge_mat, templ, result, TM_CCOEFF);
        
        double minVal; double maxVal; Point minLoc; Point maxLoc;
        minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);
        
        if (minVal == INT_MAX || maxVal == 0 ) {
            printf("\nBreak because minVal: %f, maxVal: %f, minVal + maxVal: %f", minVal,maxVal,minVal + maxVal);
            flag = true;
            break;
        }
        
      //  printf("\nMinVal: %.2f - MaxVal: %.2f\nminLoc: (%d,%d) - maxLoc: (%d,%d)", minVal,maxVal,minLoc.x,minLoc.y,maxLoc.x,maxLoc.y);
        
        // if we have found a new maximum correlation value, then ipdate
        // the bookkeeping variable
        if (!found || maxVal > maxValGen ){
            found = true;
            maxValGen = maxVal;
            maxLocGen = maxLoc;
            ratio = r;
        }
        
        if (minVal < minValGen) {
            minValGen = minVal;
            minLocGen = minLoc;
        }
        
       // printf("\n*********************\n");
    }
    
//    printf("\n----------\nmaxValGen: %.2f, minValGen: %.2f - maxLocGen: (%d,%d) - minLocGen: (%d,%d) - ratio: %.4f -------\n", maxValGen,minValGen,maxLocGen.x,maxLocGen.y,minLocGen.x,minLocGen.y,ratio);
    
    printf("\nminGoodMatch: %d - maxGoodMatch: %d\n",min_good_match,max_good_match);
    
    if (minValGen == INT_MAX || maxValGen == 0 || (minValGen + maxValGen < 2000000 && useFeature2D)) {
        printf("\nBreak because minVal: %f, maxVal: %f, minVal + maxVal: %f", minValGen,maxValGen,minValGen + maxValGen);
         flag = true;
    }
    
    if (!flag) {
        output = format("\n(%d,%d)\t%.4f\t%.2f\t%.2f\t(%d,%d)\t(%d,%d)",tW,tH,ratio,minValGen,maxValGen,minLocGen.x,minLocGen.y,maxLocGen.x,maxLocGen.y);
        
        printf("%s",output.c_str());
        
        
        
        //# unpack the bookkeeping varaible and compute the (x, y) coordinates
        //# of the bounding box based on the resized ratio
        int oX = int(maxLocGen.x * ratio);
        int oY = int(maxLocGen.y * ratio);
        int oW = int((maxLocGen.x + tW) * ratio);
        int oH = int((maxLocGen.y + tH) * ratio);
        
        rectangle(temp, Point(oX,oY), Point(oW,oH), Scalar(255,0,0) , 6, 8, 0 );
    }
    
   // printf("\n.................................\n");
    
    return temp;
}


int DetectNumberGoodMatchFLANNMatcher(Mat scene,Mat object) {
    
    SURF surf = SURF();
    Mat img_object, img_scene, img_matches;
    
//    cvtColor(scene, img_scene, CV_BGR2GRAY);
//    cvtColor(object, img_object, CV_BGR2GRAY);
    
    scene.copyTo(img_scene);
    object.copyTo(img_object);
    
    vector<KeyPoint> object_keypoints, scene_keypoints;
    
    //1: find the keypoints and descriptors with SURF
    surf.detect(img_object, object_keypoints);
    surf.detect(img_scene, scene_keypoints);
    
    SurfDescriptorExtractor extractor;
    Mat descriptors_object,descriptors_scene;
    
    extractor.compute(object, object_keypoints, descriptors_object);
    extractor.compute(scene, scene_keypoints, descriptors_scene);
    
    //2: FLANN parameters
    Ptr<flann::SearchParams> searchParam = new flann::SearchParams(50);
//    Ptr<flann::IndexParams> indexParam = new flann::IndexParams();
//    indexParam->setInt("algorithm", 0);
//    indexParam->setInt("trees", 5);
//    indexParam->setInt("multi_probe_level", 0);
    
    
    FlannBasedMatcher flann = FlannBasedMatcher(new flann::KDTreeIndexParams(5),searchParam);
    vector<vector<DMatch>> matches;
    vector<DMatch> good_matches;
    
    flann.knnMatch(descriptors_scene, descriptors_object, matches, 2);
    
    for (int i =0 ; i < matches.size(); i++) {
        vector<DMatch> match = matches[i];
        
        if (match.size() == 2 && match[0].distance < 0.70 * match[1].distance) {
            good_matches.push_back(match[0]);
        }
    }
    printf("\nGood match count: %lu - object keypoint: %lu, scene keypoint: %lu\n",good_matches.size(),object_keypoints.size(),scene_keypoints.size());
    
//    if (good_matches.size() >= 25 && good_matches.size() <= 90) {
    return (int)good_matches.size();
    /*
    //-- Localize the object
    std::vector<Point2f> objPoint;
    std::vector<Point2f> scenePoint;
    
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        Point2f scene_float = scene_keypoints[ good_matches[i].queryIdx ].pt;
        Point2f object_float = object_keypoints[ good_matches[i].trainIdx ].pt;
        scenePoint.push_back( scene_float );
        objPoint.push_back(object_float);
    }
    
    
    drawMatches( img_scene, scene_keypoints, img_object, object_keypoints,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    Mat H = findHomography(scenePoint, objPoint, RANSAC,5.0);
    
    //-- Get the corners from the image_1 ( the object to be "detected" )
    std::vector<Point2f> obj_corners(4);
    obj_corners[0] = cvPoint(0,0);
    obj_corners[1] = cvPoint( img_object.cols, 0 );
    obj_corners[2] = cvPoint( img_object.cols, img_object.rows );
    obj_corners[3] = cvPoint( 0, img_object.rows );
    std::vector<Point2f> scene_corners(4);
    
    perspectiveTransform( obj_corners, scene_corners, H);
    
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    line( img_matches, scene_corners[0] + Point2f( img_object.cols, 0), scene_corners[1] + Point2f( img_object.cols, 0), Scalar(0, 255, 0), 4 );
    line( img_matches, scene_corners[1] + Point2f( img_object.cols, 0), scene_corners[2] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[2] + Point2f( img_object.cols, 0), scene_corners[3] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[3] + Point2f( img_object.cols, 0), scene_corners[0] + Point2f( img_object.cols, 0), Scalar( 0, 255, 0), 4 );
    
     }

     return false
     */
}





