% Match features
clear all;
clc;
close all;
root_im= '00';
%root_im = '../equisRGB/00';

tail_im = '.ppm';
lv = 2; 
    im1= imread('0074.ppm');
    imr1 = imcrop(im1, [190, 3, 380, 470]);
    imG1 = rgb2gray(imr1); 
    [ul, v1] = size (imG1);
    imr2 = imr1;
    
for i= 74:74
    imr1 = imr2;
    imG1 = rgb2gray(imr1);
    [ul, v1] = size (imG1);

    im2 = imread(strcat(root_im, sprintf('%d', i), tail_im)); 
    imr2 = imcrop(im2, [190, 3, 380, 470]);
    imG2 = rgb2gray(imr2); 
    [u2, v2] = size(imG2);

    lst1= detectHarrisFeatures(imG1); 
    lst2 = detectHarrisFeatures(imG2);
    figure (1)
    imshow(imr1);
    title('Imagen 1 color')
    hold on;
    plot(lst1.selectStrongest(150));

    [feat1, valid_pts1] = extractFeatures(imG1, lst1);
    [feat2, valid_pts2] = extractFeatures (imG2, lst2);

    idxPairs = matchFeatures (feat1, feat2);

    matchPt1 = valid_pts1(idxPairs(:,1), :);

    matchPt2 = valid_pts2(idxPairs (:,2), :);

    figure (2)
    showMatchedFeatures (imr1, imr2, matchPt1, matchPt2); 
    title('Aqui encontre feat im1!!!!!')
end

