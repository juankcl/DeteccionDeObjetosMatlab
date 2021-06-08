close all;
clc;
clear all;

warning('off', 'images:label2rgb:zerocolorSameAsRegionColor');

% Leer frame
vidObj = VideoReader('Video_1_mini.mp4');

% Sacar fondo
vidObj.CurrentTime = 0.0;
background = readFrame(vidObj);
background = rgb2hsv(background);

% Sensibilidad de la mascara a partir del promedio
sens = 0.35;

[u, v, ch] = size(background);

% Filtrar el fondo para quitar el mayor ruido posible
hFilter = fspecial('disk', 9);
se = strel('disk', 30);

background = imfilter(background(:,:,3), hFilter, 'replicate');

% Calcular el rectangulo para recortar la imagen
% TODO: Cambiar las proporciones del rectangulo si la imagen es vertical
if v > u
    fprintf('Horizontal\n');
    sizeCrop = [u*0.8 v*0.5];
else
    fprintf('Vertical\n');
    sizeCrop = [u*0.5 v*0.8];
end
sizeCrop = ceil(sizeCrop);
cropRectangle = centerCropWindow2d(size(background), sizeCrop);

% Cambiar tiempo
vidObj.CurrentTime = 0.5;

% Variable para erosionar durante el while
erode = strel('diamond', 1);

% Variables de conteo
countArea = [(sizeCrop(2)/2) (sizeCrop(2)/2) + 20];
totalNumObjs = 0;
pastNumObjs = 0;

% Interfaz
% Principal
figure(1)
hAxesMain = [subplot(3,2,1) subplot(3,2,2) subplot(3,2,3) subplot(3,2,4) subplot(3,2,5)];
hImagesMain = [
    imshow(background, 'Parent', hAxesMain(1))
    imshow(zeros(sizeCrop(1), sizeCrop(2)), 'Parent', hAxesMain(2))
    imshow(zeros(sizeCrop(1), sizeCrop(2)), 'Parent', hAxesMain(3))
    imshow(zeros(500,500), 'Parent', hAxesMain(4))
    imshow(zeros(sizeCrop(1), sizeCrop(2)), 'Parent', hAxesMain(5))
];

set(get(hAxesMain(1), 'Title'), 'String', 'Entrada');
set(get(hAxesMain(2), 'Title'), 'String', 'Objetos');
set(get(hAxesMain(3), 'Title'), 'String', 'Salida imagen correlacionada');
set(get(hAxesMain(4), 'Title'), 'String', 'Target');
set(get(hAxesMain(5), 'Title'), 'String', 'Resultado. Total: 0');
set(hAxesMain(5), 'NextPlot', 'add');

% Dedos
figure(2)
hAxesDedos = subplot(1,1,1);
hImageDedos = imshow(imcrop(background, cropRectangle), 'Parent', hAxesDedos);
hTextDedos = text(0,0,'','Color','red','Parent',hAxesDedos);
title('imagen color Dedos');

pastFrame = background;
while hasFrame(vidObj)
    
    vidFrame = readFrame(vidObj);
    original = imcrop(vidFrame, cropRectangle);
    
    tic;
    vidFrame = rgb2hsv(vidFrame);
    frameRGB = imcrop(rgb2gray(vidFrame), cropRectangle);
    objetos = imfilter(vidFrame(:,:,3), hFilter, 'replicate');

    % Sacar objetos de la imagen, restando el fondo
    objetos = objetos - background;
    
    % Recortar la imagen
    objetos = imcrop(objetos, cropRectangle);
    objetos(objetos < 0.15) = 0.0;
    objetos = imadjust(objetos);
    
    % Sacar la imagen binaria, con la sensibilidad calculada al inicio
    imgMask = zeros(sizeCrop(1), sizeCrop(2), 1, 'logical');
    imgMask(objetos > sens) = 1;
    
    imgMask = imdilate(imgMask, erode);
    imgMask = bwareafilt(imgMask, [400 5000]);
    imgMask = imerode(imgMask, erode);
    imgMask = imfill(imgMask, 'holes');
    
    
    
    
    % Sacar cuadros de interes
    pf = regionprops(imgMask);
    
    numObjs = length(pf);
    restaObjs = numObjs - pastNumObjs;
    if restaObjs > 0
        totalNumObjs = totalNumObjs + restaObjs;
    end
    pastNumObjs = numObjs;
    
   
    [k,t] = size(pf);
    if k>0 && k <2 
        if pf.Area > 500 && pf.Area<2700
            h = imcrop(imgMask, pf.BoundingBox); 
        end
    else 
        h = zeros(1,1);
    end
    [p,q] = size(h);
    aux = p*q;
    if aux > 6000 && p>60 && q > 130
         h = zeros(0,0);
    end
    % Mostrar target
    set(hImagesMain(4), 'CData', h);
    
    [u, v] = size(imgMask);
    % correlacion 
    h(u, v)=0;
    imgMask(u, v)=0;

    
    % Transformada de Fourier
    imrF = fft2(frameRGB);
    imrF= fftshift (imrF);
    hF=fft2(h); 
    hF=fftshift(hF);
     % conjugado de la imagen de Fourter 
    imrFc = conj (imrF);
    imFinal = imrFc.*hF; 
    imFinal=ifftshift (imFinal);
    imFsp = ifft2(imFinal);
    imFsp = real (rot90 (rot90 (imFsp)));

   imcr = imFsp > max (max(imFsp))*0.9999;
    
    set(hImagesMain(1), 'CData', vidFrame(:,:,3));
    set(hImagesMain(2), 'CData', objetos);
    set(hImagesMain(3), 'CData', single(imFsp));
    set(hAxesMain(3), 'CLim', [0, max(max(imFsp)) + 0.1]);
    
    set(hImagesMain(5), 'CData', original);
    set(get(hAxesMain(5), 'Title'), 'String', 'Resultado. Total: ' + string(totalNumObjs));
    
    rect = findall(hAxesMain(5),'Type', 'Rectangle'); 
    delete(rect);
    
    rect = findall(hAxesMain(5),'Type', 'Plot'); 
    delete(rect);
    
    
    %Condiciones de asignacion de target
    if size(pf) > 0 
        for index = 1:size(pf)
            rectangle('Position', pf(index).BoundingBox,'EdgeColor','r','Curvature',0.2, 'Parent', hAxesMain(5));
        end

        if size(pf) < 2
            %coordenadas de target
            xMin = ceil(pf.BoundingBox(1));
            xMax = xMin +pf.BoundingBox(3) - 1;
            yMin = ceil(pf.BoundingBox(2));
            yMax = yMin + pf.BoundingBox(4) - 1;
            %en Y
            punto1Y = yMin + ceil(pf.BoundingBox(4)/2);
            punto2Y = yMax + ceil(pf.BoundingBox(4)/2);
            % en X
            punto1X = xMin + ceil(pf.BoundingBox(3)/2);
            punto2X = xMax + ceil(pf.BoundingBox(3)/2);
            %Si X < que Y
            if pf.BoundingBox(3) < pf.BoundingBox(4)
                originalA = insertShape(original,'circle',[xMin punto1Y 5],'LineWidth',2);
                originalD = insertShape(originalA,'circle',[xMax punto1Y 5],'LineWidth',2);
                clc;
                %Distancia en X
                distancia = xMax - xMin;
                disp( distancia);
            else
            %de lo contrario
                originalA = insertShape(original,'circle',[punto1X yMin 5],'LineWidth',2);
                originalD = insertShape(originalA,'circle',[punto1X yMax 5],'LineWidth',2);
                clc;
                distancia = yMax - yMin;
                disp(distancia);
            end
            str = {'Distancia  (px): ',distancia};
            colocar = [xMin,yMin+90];
            set(hImageDedos,'CData', originalD);
            
            rect = findall(hAxesDedos,'Type', 'Rectangle'); 
            delete(rect); 
            rectangle('Position', pf.BoundingBox,'EdgeColor','r','Curvature',0.2,'Parent', hAxesDedos);
            
            set(hTextDedos,'Position', [colocar(1) colocar(2) 0]);
            set(hTextDedos,'String', str);
            
        end
    end
    
    time = toc
    pause(0.1);
    %pause((1/vidObj.FrameRate) - time);
end