close all;
clear all;
clc;

root_im = '00';
ext_im ='.ppm';
ru = 380;
rv = 470;

% leer una secuencia de imagenes
% for i= 73:120
% 
% im = imread (strcat(root_im, sprintf('%d', i), ext_im));
% imr imcrop (im, [190, 3, rul rv]);
% 
%     figure (1)
%     imshow(imr);
%     title('Imagenes banda transportadora');
% 
% end

% Lectura de la primera imagen de la secuencia 
im = imread (strcat(root_im, sprintf('%d', 73), ext_im));
imr = imcrop (im, [190, 3, ru, rv]);
imG = rgb2gray(imr);
[u, v] = size(imG);

for i= 74:88

    im1 = imread (strcat(root_im, sprintf('%d', i), ext_im)); 
    imr1= imcrop (im1, [190, 3, ru, rv]); 
    imG1 = rgb2gray(imr1);
    %figure (1) %imshowpair (imr, imr1, 'montage');
    %title('Imagen anterior y siguiente');
    imDiff = imG - imG1; 
    iUmb = zeros(u,v);
    iUmb(abs (imDiff)>20)=1; 
    se = strel('square', 2);
    iUmbF = imerode (iUmb, se);
    figure(2)
    imshowpair (iUmb, iUmbF, 'montage'); 
    title('Izq: resultado resta; Der: imagen filtrada')
    imG= imG1;
    % imr imr1;
end

%% Descriptores de caracteristicas en secuencia
close all;
clear all;
clc;
ru = 380;
rv = 470;
root_im= '00'; 
ext_im= '.ppm';
% Lectura de la primera imagen de la secuencia

im = imread(strcat(root_im, sprintf('%d', 73), ext_im)); 
imr = imcrop(im, [190, 3, ru, rv]);
figure (1) 
imshow(imr);
hold on;

for i= 74:88
    im1= imread(strcat(root_im, sprintf('%d', i), ext_im));
    imr1= imcrop (im1, [190, 3, ru, rv]);
    imG1 = rgb2gray(imr1);
%     cornS = detectSURFFeatures (imG1); 
     cornS = detectHarrisFeatures(imG1);
%     cornS = detectFASTFeatures(imG1);

    figure (1)
%     imshow(imr1);
%     hold on; 
        plot(cornS.selectStrongest(150)); 
    %   title('Puntos de interes Harris'); 
        title('Puntos de interes FAST'); 
    hold on;

end