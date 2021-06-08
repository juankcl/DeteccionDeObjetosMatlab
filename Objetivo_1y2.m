close all;
clc;
clear all;

warning('off', 'images:label2rgb:zerocolorSameAsRegionColor');

% Leer frame
vidObj = VideoReader('vid1.mp4');

% Sacar fondo
vidObj.CurrentTime = 0.0;
background = readFrame(vidObj);
background = rgb2hsv(background);

% Sensibilidad de la mascara a partir del promedio
sens = 0.35;

[u, v, ch] = size(background);

% Filtrar el fondo para quitar el mayor ruido posible
hFilter = fspecial('disk', 5);
se = strel('disk', 30);

background = imfilter(background(:,:,3), hFilter, 'replicate');

% Calcular el rectangulo para recortar la imagen
% TODO: Cambiar las proporciones del rectangulo si la imagen es vertical
if v > u
    fprintf('Horizontal\n');
sizeCrop = [u*0.75 v*0.3];
else
    fprintf('Vertical\n');
    sizeCrop = [u*0.3 v*0.75];
end
cropRectangle = centerCropWindow2d(size(background), sizeCrop);

% Cambiar tiempo
vidObj.CurrentTime = 8.0;

% Variable para erosionar durante el while
erode = strel('diamond', 1);

% Variables de conteo
totalNumObjs = 0;
pastNumObjs = 0;

while hasFrame(vidObj)
    
    vidFrame = readFrame(vidObj);
    original = imcrop(vidFrame, cropRectangle);
    
    tic;
    vidFrame = rgb2hsv(vidFrame);
    frameRGB = imcrop(rgb2gray(vidFrame), cropRectangle);

    % Sacar objetos de la imagen, restando el fondo
    objetos = vidFrame(:,:,3) - background;
    objetos = imadjust(objetos);
    
    % Recortar la imagen
    objetos = imcrop(objetos, cropRectangle);
    
    % Sacar la imagen binaria, con la sensibilidad calculada al inicio
    imgMask = zeros(sizeCrop(1), sizeCrop(2), 1, 'logical');
    imgMask(objetos > sens) = 1;
    
    imgMask = imdilate(imgMask, erode);
    imgMask = imerode(imgMask, erode);
    imgMask = imfill(imgMask, 'holes');
    imgMask = bwareafilt(imgMask, [650 5000]);
    
    
    % Sacar cuadros de interes
    pf = regionprops(imgMask);
    
    numObjs = length(pf);
    restaObjs = numObjs - pastNumObjs;
    if restaObjs > 0
        totalNumObjs = totalNumObjs + restaObjs;
    end
    pastNumObjs = numObjs;
    
    % Mostrar resultados
    figure(1);
    subplot(3,2,1)
    imshow(imgMask)
    title('Resultado')
    
    subplot(3,2,2)
    imshow(vidFrame(:,:,3))
    title('Entrada')
   
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
%     h = imcrop(imgMask, pf.BoundingBox);
    subplot(3,2,3)
    imshow(h)
    title('target')
    
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

    subplot(3,2,4)
    imshow(single(imFsp), [0, max(max(imFsp))]) 
    title('Salida de imagen correlacionada')

   imcr = imFsp > max (max(imFsp))*0.9999;
   time = toc
   subplot(3,2,5)
   imshow(imcr) 
   title('Correlacion final')
    
    subplot(3,2,6)
    imshow(original)
    title('Imagen color. Total: ' + string(totalNumObjs))
    hold on;
    %Condiciones de asignacion de target
    if size(pf) > 0 
        if size(pf) <2
            rectangle('Position', pf.BoundingBox,'EdgeColor','r','Curvature',0.2);
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
                disp('CirculoA');
                %Distancie en X
                distancia = xMax - xMin;
                disp('Distancia en PX');
                disp( distancia);
            else
            %de lo contrario
                originalA = insertShape(original,'circle',[punto1X yMin 5],'LineWidth',2);
                originalD = insertShape(originalA,'circle',[punto1X yMax 5],'LineWidth',2);
                clc;
                disp('CirculoB ');
                distancia = yMax - yMin;
                disp('Distancia en PX');
                disp(distancia);
            end
            %Colocar Bounding Box
            rectangle('Position', pf.BoundingBox,'EdgeColor','r','Curvature',0.2);
            figure(2);
            imshow(originalD)
            title('imagen color Dedos')
            str = {'Distancia  (px): ',distancia};
            colocar = [xMin,yMin+90];
            text(colocar(1),colocar(2),str)
        end
    end
    

end
