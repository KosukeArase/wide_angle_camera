//
//  detect.m
//  jidori_cv
//
//  Created by AraseKosuke on 2015/12/21.
//  Copyright © 2015年 AraseKosuke. All rights reserved.
//

//#include <iostream>
//#include "opencv2/opencv.hpp"

#import <Foundation/Foundation.h>
#import "jidori_cv-Bridging-Header.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/stitching.hpp>


@interface Detector()
{
    cv::CascadeClassifier cascade;
}
@end

static cv::Mat var_image, image1, image2, image3, image4;
static std::vector<cv::KeyPoint> keypoint1;
static cv::Mat descriptor1;

@implementation Detector: NSObject

- (bool)recognizeFace1:(UIImage *)image {
    // UIImage -> cv::Mat変換
    // 画像の回転を補正する（内蔵カメラで撮影した画像などでおかしな方向にならないようにする）
    UIImage* correctImage = image;
    UIGraphicsBeginImageContext(correctImage.size);
    [correctImage drawInRect:CGRectMake(0, 0, correctImage.size.width, correctImage.size.height)];
    correctImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cv::Mat img;
    UIImageToMat(correctImage, img);
//    cv::flip(img, img, 0);
    
    cv::Mat mat(img, cv::Rect(0, img.rows-(int)(img.rows/3), img.cols, (int)(img.rows/3)));
    cv::cvtColor(mat , mat , CV_RGBA2RGB);
    
    auto algorithm = cv::AKAZE::create();
    std::vector<cv::KeyPoint> keypoint2;
    algorithm->detect(mat, keypoint2);
    cv::Mat descriptor2;
    
    algorithm->compute(mat, keypoint2, descriptor2);
    
            // マッチング (アルゴリズムにはBruteForceを使用)
            cv::Ptr<cv::DescriptorMatcher> matcher = cv::DescriptorMatcher::create("BruteForce");
            std::vector<cv::DMatch> match, match12, match21, selected;
            matcher->match(descriptor1, descriptor2, match12);
            matcher->match(descriptor2, descriptor1, match21);
            //クロスチェック(1→2と2→1の両方でマッチしたものだけを残して精度を高める)
            int len = 0;
            double dx_sum = 0;
            double dy_sum = 0;
//            double dx_sumv = 0;
//            double dy_sumv = 0;
            cv::Point2f query;
            cv::Point2f train;
            std::vector<float> d_x;
            std::vector<float> d_y;
            cv::DMatch forward;
            cv::DMatch backward;
    
            for (size_t i = 0; i < match12.size(); i++)
            {
                forward = match12[i];
                backward = match21[forward.trainIdx];
                if (backward.trainIdx == forward.queryIdx)
                {
                    query = keypoint1[forward.queryIdx].pt;
                    train = keypoint2[forward.trainIdx].pt;
                    d_x.push_back(query.x - train.x);
                    d_y.push_back(query.y - train.y);
                    dx_sum += d_x.back();
                    dy_sum += d_y.back();
//                    dx_sumv += pow(d_x.back(), 2);
//                    dy_sumv += pow(d_y.back(), 2);
                    match.push_back(forward);
                    len ++;
                }
            }
    
            double dx_ave = dx_sum/len;
            double dy_ave = dy_sum/len;
    double xxx = 0;
    double yyy = 0;
    
            for (size_t i = 0; i < match.size(); i++)
            {
                if (d_x[i] > (dx_ave - 100) && d_x[i] < (dx_ave + 100) && d_y[i] > (dy_ave - 100) && d_y[i] < (dy_ave + 100))
                {
                    selected.push_back(match[i]);
                    xxx += d_x[i];
                    yyy += d_y[i];
                }
            }

//            double dx_v = (dx_sumv - pow(dx_sum, 2)/len)/(len - 1);
//            double dy_v = (dy_sumv - pow(dy_sum, 2)/len)/(len - 1);
//            printf("(x, y) = (%f, %f), dx_s = %f, dy_s = %f, len = %lu, select = %lu\n", (dx_sum/len), (dy_sum/len), sqrt(dx_v), sqrt(dy_v), match.size(), selected.size());
                printf("1 (x, y) = (%f, %f), len = %lu, select = %lu\n", xxx/(int)(selected.size()), yyy/(int)(selected.size()), match.size(), selected.size());
            // マッチング結果の描画
//            cv::Mat dest;
//            cv::drawMatches(var_image, keypoint1, mat, keypoint2, selected, dest);
            //        cv::drawMatches(scene1, keypoint1, frame, keypoint2, match, dest);
//            imshow("sample", dest);
//        }

//    cv::Mat output;
//    cv::drawKeypoints(mat, keyPoints0, output, cv::Scalar::all(-1),cv::DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
    
//    printf("\%d\n", keyPoints.size());

    // cv::Mat -> UIImage変換
//    UIImage *resultImage = MatToUIImage(img);
//        UIImage *resultImage = MatToUIImage(dest);
//    return resultImage;
    
    if (fabs(xxx/(int)(selected.size())) < 20 &&fabs(yyy/(int)(selected.size())) < 50 && (int)(selected.size()) > 20) {
//    if ((int)(selected.size()) > 15) {
        image2 = img;
        return true;
    } else {
        return false;
    }
}

- (bool)recognizeFace2:(UIImage *)image {
    UIImage* correctImage = image;
    UIGraphicsBeginImageContext(correctImage.size);
    [correctImage drawInRect:CGRectMake(0, 0, correctImage.size.width, correctImage.size.height)];
    correctImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cv::Mat img;
    UIImageToMat(correctImage, img);
    cv::Mat mat(img, cv::Rect(0, 0, (int)(img.cols/3), img.rows));
    cv::cvtColor(mat , mat , CV_RGBA2RGB);
    
    auto algorithm = cv::AKAZE::create();
    std::vector<cv::KeyPoint> keypoint2;
    algorithm->detect(mat, keypoint2);
    cv::Mat descriptor2;
    
    algorithm->compute(mat, keypoint2, descriptor2);
    
    // マッチング (アルゴリズムにはBruteForceを使用)
    cv::Ptr<cv::DescriptorMatcher> matcher = cv::DescriptorMatcher::create("BruteForce");
    std::vector<cv::DMatch> match, match12, match21, selected;
    matcher->match(descriptor1, descriptor2, match12);
    matcher->match(descriptor2, descriptor1, match21);
    //クロスチェック(1→2と2→1の両方でマッチしたものだけを残して精度を高める)
    int len = 0;
    double dx_sum = 0;
    double dy_sum = 0;
    cv::Point2f query;
    cv::Point2f train;
    std::vector<float> d_x;
    std::vector<float> d_y;
    cv::DMatch forward;
    cv::DMatch backward;
    
    for (size_t i = 0; i < match12.size(); i++)
    {
        forward = match12[i];
        backward = match21[forward.trainIdx];
        if (backward.trainIdx == forward.queryIdx)
        {
            query = keypoint1[forward.queryIdx].pt;
            train = keypoint2[forward.trainIdx].pt;
            d_x.push_back(query.x - train.x);
            d_y.push_back(query.y - train.y);
            dx_sum += d_x.back();
            dy_sum += d_y.back();
            match.push_back(forward);
            len ++;
        }
    }
    
    double dx_ave = dx_sum/len;
    double dy_ave = dy_sum/len;
    double xxx = 0;
    double yyy = 0;
    
    for (size_t i = 0; i < match.size(); i++)
    {
        if (d_x[i] > (dx_ave - 100) && d_x[i] < (dx_ave + 100) && d_y[i] > (dy_ave - 100) && d_y[i] < (dy_ave + 100))
        {
            selected.push_back(match[i]);
            xxx += d_x[i];
            yyy += d_y[i];
        }
    }
    printf("2 (x, y) = (%f, %f), len = %lu, select = %lu\n", xxx/(int)(selected.size()), yyy/(int)(selected.size()), match.size(), selected.size());
        if (fabs(xxx/(int)(selected.size())) < 50 &&fabs(yyy/(int)(selected.size())) < 50 && (int)(selected.size()) > 15) {
//    if ((int)(selected.size()) > 25) {
        image3 = img;
        return true;
    } else {
        return false;
    }
}

- (bool)recognizeFace3:(UIImage *)image {
    UIImage* correctImage = image;
    UIGraphicsBeginImageContext(correctImage.size);
    [correctImage drawInRect:CGRectMake(0, 0, correctImage.size.width, correctImage.size.height)];
    correctImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cv::Mat img;
    UIImageToMat(correctImage, img);//cv::Rect(0, img.rows-(int)(img.rows/3), img.cols, (int)(img.rows/3)))
    cv::Mat mat(img, cv::Rect(0, 0, img.cols, (int)(img.rows/3)));
    cv::cvtColor(mat , mat , CV_RGBA2RGB);
    
    auto algorithm = cv::AKAZE::create();
    std::vector<cv::KeyPoint> keypoint2;
    algorithm->detect(mat, keypoint2);
    cv::Mat descriptor2;
    
    algorithm->compute(mat, keypoint2, descriptor2);
    
    // マッチング (アルゴリズムにはBruteForceを使用)
    cv::Ptr<cv::DescriptorMatcher> matcher = cv::DescriptorMatcher::create("BruteForce");
    std::vector<cv::DMatch> match, match12, match21, selected;
    matcher->match(descriptor1, descriptor2, match12);
    matcher->match(descriptor2, descriptor1, match21);
    //クロスチェック(1→2と2→1の両方でマッチしたものだけを残して精度を高める)
    int len = 0;
    double dx_sum = 0;
    double dy_sum = 0;
    cv::Point2f query;
    cv::Point2f train;
    std::vector<float> d_x;
    std::vector<float> d_y;
    cv::DMatch forward;
    cv::DMatch backward;
    
    for (size_t i = 0; i < match12.size(); i++)
    {
        forward = match12[i];
        backward = match21[forward.trainIdx];
        if (backward.trainIdx == forward.queryIdx)
        {
            query = keypoint1[forward.queryIdx].pt;
            train = keypoint2[forward.trainIdx].pt;
            d_x.push_back(query.x - train.x);
            d_y.push_back(query.y - train.y);
            dx_sum += d_x.back();
            dy_sum += d_y.back();
            match.push_back(forward);
            len ++;
        }
    }
    
    double dx_ave = dx_sum/len;
    double dy_ave = dy_sum/len;
    double xxx = 0;
    double yyy = 0;
    
    for (size_t i = 0; i < match.size(); i++)
    {
        if (d_x[i] > (dx_ave - 100) && d_x[i] < (dx_ave + 100) && d_y[i] > (dy_ave - 100) && d_y[i] < (dy_ave + 100))
        {
            selected.push_back(match[i]);
            xxx += d_x[i];
            yyy += d_y[i];
        }
    }
    printf("2 (x, y) = (%f, %f), len = %lu, select = %lu\n", xxx/(int)(selected.size()), yyy/(int)(selected.size()), match.size(), selected.size());
    //    if (fabs(xxx/(int)(selected.size())) < 20 &&fabs(yyy/(int)(selected.size())) < 20 && (int)(selected.size()) > 20) {
    if ((int)(selected.size()) > 15) {
        image4 = img;
        return true;
    } else {
        return false;
    }
}



- (void)set_var_image1:(UIImage *)image {
    // UIImage -> cv::Mat変換
    // 画像の回転を補正する（内蔵カメラで撮影した画像などでおかしな方向にならないようにする）
    UIImage* correctImage = image;
    UIGraphicsBeginImageContext(correctImage.size);
    [correctImage drawInRect:CGRectMake(0, 0, correctImage.size.width, correctImage.size.height)];
    correctImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cv::Mat img;
    UIImageToMat(correctImage, img);
//    cv::flip(img, img, 0);
    cv::Mat var(img, cv::Rect(0, 0, img.cols, (int)(img.rows/3)));
    var_image = var;
    cv::cvtColor(var_image, var_image , CV_RGBA2RGB);
    
    auto algorithm = cv::AKAZE::create();
//    std::vector<cv::KeyPoint> keyPoints;
    algorithm->detect(var_image, keypoint1);
    
//    cv::Mat descriptor;
    algorithm->compute(var_image, keypoint1, descriptor1);

//    cv::Mat output;
//    cv::drawKeypoints(mat, keyPoints, output, cv::Scalar::all(-1),cv::DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
    
//    printf("\%d\n", keyPoints.size());
    
    // cv::Mat -> UIImage変換
//    UIImage *resultImage = MatToUIImage(image0);
    image1 = img;
    return;
//    return resultImage;
}

- (void)set_var_image2:(UIImage *)image {
    UIImage* correctImage = image;
    UIGraphicsBeginImageContext(correctImage.size);
    [correctImage drawInRect:CGRectMake(0, 0, correctImage.size.width, correctImage.size.height)];
    correctImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cv::Mat img;
    UIImageToMat(correctImage, img);
    cv::Mat var(img, cv::Rect(img.cols - (int)(img.cols/3), 0, (int)(img.cols/3), img.rows));
    var_image = var;
    cv::cvtColor(var_image, var_image , CV_RGBA2RGB);
    
    auto algorithm = cv::AKAZE::create();
    algorithm->detect(var_image, keypoint1);
    algorithm->compute(var_image, keypoint1, descriptor1);
    return;
}

- (void)set_var_image3:(UIImage *)image {
    UIImage* correctImage = image;
    UIGraphicsBeginImageContext(correctImage.size);
    [correctImage drawInRect:CGRectMake(0, 0, correctImage.size.width, correctImage.size.height)];
    correctImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cv::Mat img;
    UIImageToMat(correctImage, img);
    cv::Mat var(img, cv::Rect(0, img.rows - (int)(img.rows/3), img.cols, (int)(img.rows/3)));
    var_image = var;
    cv::cvtColor(var_image, var_image , CV_RGBA2RGB);
    
    auto algorithm = cv::AKAZE::create();
    algorithm->detect(var_image, keypoint1);
    algorithm->compute(var_image, keypoint1, descriptor1);
    return;
}





- (UIImage *)get_var_image:(int)dummy {
    // cv::Mat -> UIImage変換
            UIImage *resultImage = MatToUIImage(var_image);
    return resultImage;
}

- (UIImage *)get_image1:(int)dummy {
    // cv::Mat -> UIImage変換
    UIImage *resultImage = MatToUIImage(image1);
    return resultImage;
}

- (UIImage *)get_image2:(int)dummy {
    // cv::Mat -> UIImage変換
    UIImage *resultImage = MatToUIImage(image2);
    return resultImage;
}

- (UIImage *)get_image3:(int)dummy {
    // cv::Mat -> UIImage変換
    UIImage *resultImage = MatToUIImage(image3);
    return resultImage;
}

- (UIImage *)get_image4:(int)dummy {
    // cv::Mat -> UIImage変換
    UIImage *resultImage = MatToUIImage(image4);
    return resultImage;
}

- (UIImage *)compose:(int)dummy {
//    cv::Mat homography;
//    
//    std::vector<cv::KeyPoint> kpts1, kpts2;
//    cv::Mat desc1, desc2;
//    cv::Mat img3 = cv::Mat(image2.rows, image2.cols, CV_8UC1);
//    auto akaze = cv::AKAZE::create();
//    using namespace std;
//    using namespace cv;
//
//    akaze->detectAndCompute(image1, cv::noArray(), kpts1, desc1);
//    akaze->detectAndCompute(image2, cv::noArray(), kpts2, desc2);
//    
//    
//    cv::BFMatcher matcher(cv::NORM_HAMMING);
//    vector< vector<DMatch> > nn_matches;
//    matcher.knnMatch(desc1, desc2, nn_matches, 2);
//    puts("Have done match");
//    
//    vector<Point2f> matched1, matched2;
//    vector<Point2f> inliers1, inliers2;
//    
//    const float inlier_threshold = 2.5f; // Distance threshold to identify inliers
//    const float nn_match_ratio = 0.8f;
//    
//    for(size_t i = 0; i < nn_matches.size(); i++) {
//        DMatch first = nn_matches[i][0];
//        float dist1 = nn_matches[i][0].distance;
//        float dist2 = nn_matches[i][1].distance;
//        
//        if(dist1 < nn_match_ratio * dist2) {
//            matched1.push_back(kpts1[first.queryIdx].pt);
//            matched2.push_back(kpts2[first.trainIdx].pt);
//        }
//    }
////    printf("Matches %d %d\n", matched1.size(), matched2.size());
//    
//    homography = findHomography(matched1, matched2, RANSAC);
//    
//    warpPerspective(image1, img3, homography, img3.size());
//    
////#if DEBUG == 1
////    Mat img_matches;
////    drawMatches( img1, kpts1, img2, kpts2, nn_matches, img_matches );
////    imshow("Input4",img_matches);
////#endif
//    
//    for (int i = 0; i < img3.size().height; ++i)
//    {
//        for (int j = 0; j < img3.size().width; ++j)
//        {
//            image2.at<uchar>(i, j) = (image2.at<uchar>(i, j) | img3.at<uchar>(i, j));
//        }
//    }
//    
////#if DEBUG == 1
////    medianBlur(image2, img3, 3);
////#endif
//    
//    //Display input and output
//    //imshow("Input1",img1);
////    imshow("Merged", image2);
////    imshow("Warped", img3);
////    imwrite(final_merged_output_name, img2);
////    imwrite(final_warped_output_name, img3);
////    waitKey(0);
////    
////    return 0;
    
    //アルゴリズムにAKAZEを使用する
    auto algorithm = cv::AKAZE::create();
    
    cv::Mat var_image = image1;
    image1 = image2;
    image2 = image1;

    // 特徴点抽出
    std::vector<cv::KeyPoint> keypoint, keypoint2, keypoint3, keypoint4;
    algorithm->detect(image1, keypoint);
    algorithm->detect(image2, keypoint2);
    algorithm->detect(image3, keypoint3);
    algorithm->detect(image4, keypoint4);
    
    // 特徴記述
    cv::Mat descriptor, descriptor2, descriptor3, descriptor4;
    algorithm->compute(image1, keypoint, descriptor);
    algorithm->compute(image2, keypoint2, descriptor2);
    algorithm->compute(image3, keypoint3, descriptor3);
    algorithm->compute(image4, keypoint4, descriptor4);

    cv::Ptr<cv::DescriptorMatcher> matcher = cv::DescriptorMatcher::create("BruteForce");
    std::vector<cv::DMatch> match, match12, match21, selected;
    matcher->match(descriptor, descriptor2, match12);
    matcher->match(descriptor2, descriptor, match21);
    
    int len = 0;
    double dx_sum = 0;
    double dy_sum = 0;
    cv::Point2f query;
    cv::Point2f train;
    std::vector<float> d_x;
    std::vector<float> d_y;
    cv::DMatch forward;
    cv::DMatch backward;
    
    for (size_t i = 0; i < match12.size(); i++)
    {
        forward = match12[i];
        backward = match21[forward.trainIdx];
        if (backward.trainIdx == forward.queryIdx)
        {
            query = keypoint[forward.queryIdx].pt;
            train = keypoint2[forward.trainIdx].pt;
            d_x.push_back(query.x - train.x);
            d_y.push_back(query.y - train.y);
            dx_sum += d_x.back();
            dy_sum += d_y.back();
            match.push_back(forward);
            len ++;
        }
    }
    
    double dx_ave = dx_sum/len;
    double dy_ave = dy_sum/len;
    
    for (size_t i = 0; i < match.size(); i++)
    {
        if (d_x[i] > (dx_ave - 100) && d_x[i] < (dx_ave + 100) && d_y[i] > (dy_ave - 100) && d_y[i] < (dy_ave + 100))
        {
            selected.push_back(match[i]);
        }
    }
    
   std::vector<cv::Vec2f> points1(selected.size());
   std::vector<cv::Vec2f> points2(selected.size());
//    std::vector<cv::Point2f> points1, points2;
    // cv::Mat points1 = cv::Mat_<double>((int)(selected.size()),2);
    // cv::Mat points2 = cv::Mat_<double>((int)(selected.size()),2);
    
    for( size_t i = 0 ; i < selected.size() ; ++i )
    {
        // points1.at<double>(i,0) = keypoint[selected[i].queryIdx].pt.x;
        // points1.at<double>(i,1) = keypoint[selected[i].queryIdx].pt.y;
       // points1.push_back(keypoint[selected[i].queryIdx].pt);
       // points2.push_back(keypoint[selected[i].trainIdx].pt);
       points1[i][0] = keypoint1[selected[i].trainIdx].pt.x;
       points1[i][1] = keypoint1[selected[i].trainIdx].pt.y;
       points2[i][0] = keypoint2[selected[i].trainIdx].pt.x;
       points2[i][1] = keypoint2[selected[i].trainIdx].pt.y;
        // points2.at<double>(i,0) = keypoint2[selected[i].queryIdx].pt.x;
        // points2.at<double>(i,1) = keypoint2[selected[i].queryIdx].pt.y;
    }

    cv::Mat result;
    
    cv::Mat homo = cv::findHomography(points1, points2, CV_RANSAC);
    cv::warpPerspective(image1, result, homo, cv::Size(static_cast<int>(image1.cols * 1.5), static_cast<int>(image1 .rows * 1.1)));

    for (int y = 0; y < image1.rows; y++){
        for (int x = 0; x < image1.cols; x++){
            result.at<cv::Vec3b>(y, x) = image2.at<cv::Vec3b>(y, x);
        }
    }
    
    std::vector<cv::Mat> imageList;
    cv::Mat panorama;
    imageList.push_back(image1);
    imageList.push_back(image2);
//    imageList.push_back(image3);
//    imageList.push_back(image4);
    
//    cv::Stitcher stitcher = cv::Stitcher::createDefault();
//    stitcher.stitch(imageList, panorama);
    
    auto stitcher = cv::Stitcher::createDefault(false);
    auto status = stitcher.stitch(imageList, panorama);

    
    if (status != cv::Stitcher::OK) {
     std::cout << status << std::endl;
    }
    

    
//    printf("%lf,%lf\n", points1[2][0],points2[2][1]);
    
//     cv::Mat homo, mask;
//     homo = findHomography(points1, points2, cv::RANSAC, 5, mask);
// //        findHomography(cv::Mat(points1), cv::Mat(points2), homo,cv::RANSAC, 3);
    
//     std::cout << image1.size() << std::endl;
//         std::cout << image1.rows << std::endl;
//             std::cout << image1.cols << std::endl;
//             std::cout << homo.type() << std::endl;
//     std::cout << points1.size() << std::endl;
//         std::cout << points2.size() << std::endl;

    
    
//     // ホモグラフィ行列Hを用いてパノラマ合成
//     cv::Mat dst;
    
//     cv::Mat varrr, varr;
// //    image1.convertTo(varrr, CV_32F);
// //        image2.convertTo(varr, CV_32F);
// //    UIImage *varUIImage = MatToUIImage(image1);
// //    UIImageToMat(varUIImage, varrr);

//     cv::warpPerspective(image1, dst, homo, cv::Size(image1.cols*1.4,image1.rows*1.1));
//     for (int y = 0; y < image1.rows; y++){
//         for (int x = 0; x < image1.cols; x++){
//             dst.at<cv::Vec3b>(y, x) = image2.at<cv::Vec3b>(y, x);
//         }
//     }
//
////    
////    
////    
////    
////    
////    
////    
//////    cv::Mat result;
////cv::Mat_< float > homography = cv::findHomography( points1, points2, CV_RANSAC );
////    cv::Mat_< cv::Vec3b > result;
////    cv::warpPerspective( image1, result, homography, cv::Size( ( image1.cols * 1.5 ), image1.rows ) );
////    for( int y = 0 ; y < image2.rows ; ++y )
////    {
////        for( int x = 0 ; x < image2.cols ; ++x )
////        {
////            result.row(y) = image2.row(y);
////            result.col(x) = image2.col(x);
////            
////        }
////    }
//////    cv::warpPerspective(image1, result, homo, cv::Size(static_cast<int>(image1.cols * 1.5), static_cast<int>(image1.rows * 1.1)));
////    for (int y = 0; y < image1.rows; y++){
////        for (int x = 0; x < image1.cols; x++){
////            result.at<cv::Vec3b>(y, x) = image2.at<cv::Vec3b>(y, x);
////        }
////    }
//    
////    cv::Mat matchedImg;
////    cv::drawMatches(image1, keypoint, image2, keypoint2, selected, matchedImg);
////    imshow("draw img", matchedImg);
////    cv::Mat temp;
////    matchedImg.convertTo(temp, CV_8U, 255);
//    
//
//    
//    
//    
//    
    // cv::Mat -> UIImage変換
//    UIImage *resultImage = MatToUIImage(result);
    UIImage *resultImage = MatToUIImage(panorama);
    return resultImage;
}


@end
