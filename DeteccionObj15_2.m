clc;
close all; 
clear all;

%im = imread('../equisRGB/0073.ppm'); 
im = imread('0073.ppm'); 
imr = imcrop(im, [190, 3, 380, 470]);
lv = 2;
figure(1)
imshow(imr);
title('imagen color')

% imG= rgb2gray(imr); 
imG= rgb2gray(imr); 
[u,v] = size (imG);

thr = multithresh(imG, lv);
segIm= imquantize(imG, thr);
figure (2)
imshow(segIm, [])
title('Imagen segmentada multithreshold')

% iMask = zeros(u, v);
iMask = zeros(u,v);
iMask(segIm>lv) = 1;

figure(3)
imshow(iMask);
title('Imagen Binarizada');
%%
f=bwareaopen(logical (iMask), 2000); % elimina los objeto de area menores a 2000 pixeles

figure(4)
imshow (f);
title('Deteccion de la pieza') 
pf = regionprops (f);

h = imcrop(f, pf. BoundingBox); 
[m, n] = size(h);
figure (5)
imshow(h);
title('target')

%correlacion
h(u,v)=0; 

%correlacion extendiendo imagen
%h (u+m, v+n)=0; 
%imG(u+m, v+n) = 0;

% Transformada de Fourier
imrF=fft2(imG);
hF=fft2(h);
imrF=fftshift (imrF);
hF=fftshift (hF);

% conjugado de la imagen de Fourier
imrFc = conj (imrF);

imFinal = imrFc.*hF;
imFinal = ifftshift(imFinal);
imFsp = ifft2(imFinal);
imFsp = real(rot90 (rot90 (imFsp))); 
figure (6)
imshow(single (imFsp),[0,max(max(imFsp))]); 
title('Salida de imagen correlacionada')

imcr = imFsp > max(max(imFsp))*0.90;

figure (7)
imshow(imcr) 
title('Correlacion final');

[inx, iny]=find (imcr==1);

inx = round(sum (inx)/ length (inx));
iny = round(sum (iny)/length(iny));

mm = round (m/2);
nn = round (n/2);
X = [inx+n; inx+n; inx; inx; inx+n]; 
Y = [iny+m; iny; iny; iny+m; iny+m];
figure (8)
imshow(imr);
hold on;

plot (iny+mm+1, inx+nn, 'dr');
plot (iny+mm, inx+nn+1, 'dr');
plot(iny+mm-1, inx+nn, 'dr');
plot (iny+mm, inx+nn-1, 'dr');
plot (Y,X, '-r')

title('imagen color')

%% Secuencia de imagenes
%clc;
close all;
%clear all;

root_im = '00';
% root_im = './palomEquis/00'; 
% root_im = '../equisRGB/00';
% root_im = '../00';
ext_im = '.ppm';
lv = 2;

% tamaño a cortar de la imagen original
ru = 380 ;
rv = 470 ;

for i=74:88
    im = imread (strcat(root_im, sprintf('%d', i), ext_im));
    imr = imcrop(im, [190, 3, ru, rv]);
    imG = rgb2gray(imr);
    thr = multithresh (imG, lv); segIm = imquantize(imG, thr);
    [u, v] = size (imG); iMask = zeros(u, v);
    iMask (segIm>lv) = 1;
    f=bwareaopen (logical(iMask), 2000); % elimina los objeto de area menores a 100 pixeles
    
    %figure(1)
    %imshow (f);
    %title( 'Deteccion de la pieza')
    %h = imcrop (f, [148,3,92,100]);
    %[m, n] = size(h); 
    %figure (2)
    %imshow(h);
    %title('target')

    % correlacion 
    % h(u, v)=0;
    % Transformada de Fourier
    imrF = fft2(imG);
    %hF=fft2(h); 
    imrF=fftshift (imrF);
    %hF=fftshift(hF);

    % conjugado de la imagen de Fourter 
    imrFc = conj (imrF);
    imFinal = imrFc.*hF; 
    imFinal=ifftshift (imFinal);
    imFsp = ifft2(imFinal);
    
    imFsp = real (rot90 (rot90 (imFsp)));

    %figure(6)
    %imshow(single(imFsp), [0, max(max(imFsp))]); 
    %title('Salida de imagen correlacionada')

    imcr = imFsp > max (max(imFsp))*0.9999;
    %figure(3)
    %imshow(imcr) 
    %title('Correlacion final');

    [inx, iny] = find (imcr==1);
    inx = round (sum (inx)/length (inx)); 
    iny = round (sum (iny) / length(iny));

    mm = round (m/2); 
    nn = round (n/2);
    X = [inx+n; inx+n; inx; inx; inx+n]; 
    Y = [iny+m; iny; iny; iny+m; iny+m];

    figure (1) 
    imshow(imr);
    hold on;

    plot (iny+mm+1, inx+nn, 'dr');
    plot (iny+mm, inx+nn+1, 'dr');
    plot(iny+mm-1, inx+nn, 'dr');
    plot (iny+mm, inx+nn-1, 'dr');
    plot (Y,X, '-r')

    title('imagen color')
    pause (0.4)

    posx = inx+nn;
    posy = iny+mm;
    clc;
    disp('posicion en imagen: ')
     i
     posx
     posy

end