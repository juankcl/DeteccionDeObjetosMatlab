% Find the Corners
points1 = detectHarrisFeatures (11); 
points2 = detectHarrisFeatures (12);
% Extract the neighborhood features.
[features1, valid_points1] = extractFeatures (11,points1); 
[features2, valid_points2] = extractFeatures (12,points2);
% Match the features.
indexPairs = matchFeatures (features1, features2);
% Retrieve the locations of the corresponding points for each image
matchedPoints1= valid_points1(indexPairs (:,1),:);
matchedPoints2 = valid_points2(indexPairs (:,2), :);
% Visualize the corresponding points. You can see the effect of translation 
% between the two images despite several erroneous matches.
figure;
showMatchedFeatures(11, 12, matchedPoints1,matchedPoints2);
