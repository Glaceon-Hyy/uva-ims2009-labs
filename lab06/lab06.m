% Lab 6: Kernel based histograms
% Tracking a given object given a predefined area to search with kernel
% based histograms


%% Brute-force trakcing Algorithm:
% width_area = v1
% height_area = v2
% hist_obj = histogram(object_to_track)
% bp = backprojection(hist_obj,img_seq[1])
% labels = label(bp)
% best = find_best_obj(labels,hist_obj)
% imshow(img_seq[1])
% imrect(best.box)
% location = [best.box.x + best.box.width/2, best.box.y+best.box.height/2] 
%
% for i=2 to img_seq[end]
%   area = getArea(location,width_area,height_area)
%   location = findBestFit(hist_obj,area,img_seq[i])
%   plot(box(location))
% end

%% Color spaces
% checking color-space methods:
% 0 - RGB works fine
% 1 - needs mapping to 1-255 values to work, and mapped to 0-1 for display
% 2 - needs mapping to 1-255 values to work, and mapped to 0-1 for display
% (added normalization in the function)
% 3 - needs mapping to 1-255 values to work, and mapped to 0-1 for display
% 4 - returns useless backprojection??
% 5 - needs mapping to 1-255 values to work, and mapped to 0-1 for display

%% Main function
function lab06( input_args )
    close all;

    bin = 20;
    widthArea = 20;
    heightArea = 20;
    
    
    directory = '../data/';
    images = dir(directory);
    images = images(3:end-1);



    % take only part of the player to get a good histogram 

	
	%% use RGB color space
    RGB_img = imread([directory images(1).name]);
    RGB_player = imcrop(RGB_img,[280,250,5,30]);
	
	%% convert to normalized rgb
% 	RGB_player = imconv(im2double(RGB_player),1)*255;
% 	RGB_img = imconv(im2double(RGB_img),1)*255;	
	
	%% convert to opponent color space
% 	RGB_player = imconv(im2double(RGB_player),2)*255;
% 	RGB_img = imconv(im2double(RGB_img),2)*255;	

	%% convert to HSV color space (wikipedia)
% 	RGB_player = imconv(im2double(RGB_player),3)*255;
% 	RGB_img = imconv(im2double(RGB_img),3)*255;	

	%% convert to HSI color space
% 	RGB_player = imconv(im2double(RGB_player),4);
% 	RGB_img = imconv(im2double(RGB_img),4);	

	%% convert to HSV color space (matlab)
	RGB_player = imconv(im2double(RGB_player),5)*255;
	RGB_img = imconv(im2double(RGB_img),5)*255;	

	RGB_playerSize = size(RGB_player);
	
	min(RGB_img(:))
	max(RGB_img(:))	

	
    % get the histogram of the player
	hist_player = histogram(RGB_player,bin);
% 	sum(hist_player(:))
	
	% backproject player against histogram
    bp = backprojection(RGB_img,hist_player,bin);

% 	min(bp(:))
% 	max(bp(:))	
	
	figure;
	imshow(RGB_player);
	figure;
	imshow(RGB_img);
	figure;
	imshow(bp)

	

    labels = labelimage(bp,3);
    boxes = cat(1,labels.BoundingBox);

	for i=1:size(boxes,1)
		imPart = imcrop(RGB_img,boxes(i,1:4));
		imPartHist = histogram(imPart,bin);
		boxes(i,5)=histdistance(hist_player,imPartHist,2);
	end
	boxes = sortrows(boxes,5);

	imshow(RGB_img);
	imrect(gca,boxes(1,1:4));
    
	position = boxes(1,1:2);
	boxsize = boxes(1,3:4);
    
	for i=1:size(images,1)
		%% use RGB color space
		img = imread([directory images(i).name]);

		%% convert to normalized rgb		
% 		img = imconv(im2double(img)	,1)*255;	

		%% convert to opponent color space
% 		img = imconv(im2double(img)	,2)*255;	

		%% convert to HSV color space (wiki)
% 		img = imconv(im2double(img)	,3)*255;	

		%% convert to HSI color space
% 		img = imconv(im2double(img)	,4)*255;	

		%% convert to HSV color space (matlab)
		img = imconv(im2double(img)	,5)*255;	
		imshow(img/255,[]);

		position = FindBestFit(hist_player, ...
								RGB_playerSize, img, ...
								[position(1), position(2)],...
								widthArea, heightArea, 5, bin);
        
		imrect(gca,[position(1) position(2) boxsize(1) boxsize(2)]);
		M(i) = getframe;
		drawnow;
	end
% 	movie(M,1,30);

end


%% FindBestFit
% returns the position of a part of the image which has the closest
% distance in histogram with histObj.
function newPosition = FindBestFit(histObj, histObjSize, img,position, widthArea, heightArea, sampleStep, bin)
    
    newPosition = position;
    
    startValX = position(1)-widthArea;
    endValX = position(1)+widthArea;
    startValY = position(2)-heightArea;
    endValY = position(2)+heightArea;
    
    distVal = 100000;
%     imResult=0;

	%% looping over the area defined by a starting position is difficult to
	%% improve.
    for i = startValX : sampleStep : endValX
        for j = startValY : sampleStep : endValY
            imPart = imcrop(img,[i,j,histObjSize(2),histObjSize(1)]);
            imPartHist = histogram(imPart,bin);
            temp = histdistance(histObj,imPartHist,2);
%             figure;
%             imshow(imPart)
            if temp < distVal
                distVal = temp;
                newPosition = [i, j];
%                 imResult = imPart;
            end
        end
    end
%     figure;
%     imshow(imResult);
end
    