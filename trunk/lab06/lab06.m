%% Lab 5: Brute-force tracking
% Tracking a given object given a predefined area to search. 


%% Algorithm:
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


%% Main function
function lab05( input_args )
    close all;

    bin = 20;
    widthArea = 20;
    heightArea = 20;
    
    
    directory = '../data/';
    images = dir(directory);
    images = images(3:end-1);


    RGB_img = imread([directory images(1).name]);
% 	RGB_img = imconv(RGB_img,2);

    % take only part of the player to get a good histogram 
    RGB_player = imcrop(RGB_img,[280,250,5,30]);
    RGB_playerSize = size(RGB_player);


    % get the histogram of the player
% 	RGB_player = imconv(im2double(RGB_player),5);
% 	RGB_img = imconv(im2double(RGB_img),5);	
% 	figure;
% 	imshow(RGB_player);
	
% 	figure;
% 	imshow(RGB_img);

	hist_player = histogram(RGB_player,bin);


	
    % backproject player against histogram
    bp = backprojection(RGB_img,hist_player,bin);
% 	figure;
% 	imshow(bp)

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
        img = imread([directory images(i).name]);
% 		img = imconv(im2double(img),2);	
        position = FindBestFit(hist_player, ...
                               RGB_playerSize, img, ...
                               [position(1), position(2)],...
                               widthArea, heightArea, 5, bin);
        
        imshow(img);
        imrect(gca,[position(1) position(2) boxsize(1) boxsize(2)]);
        M(i) = getframe;
    end
    movie(M,1,30);

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
    
    
%     size(RGB_img)
%     imshow(bp)

    
    
%     for i=1:1size(images,1)
%         img = imread([directory images(i).name]);
%         imshow(img);
%         M(i)=getframe;
%     end
%     
%     movie(M,1,30);



%     RGB_img1 = imread('nemo1.jpg');
%     RGB_img2 = imread('nemo2.jpg');
% 
%     bin = 10;
%     
%     RGB_nemo = imcrop(RGB_img1,[260 130 30 30]);
%     H = histogram(RGB_nemo,bin);
%     B = backprojection(RGB_img2,H,bin);
% 
%     labels = labelimage(B);
% 
%     boxes = cat(1,labels.BoundingBox);
% 
%     for i=1:size(boxes,1)
%         imPart = imcrop(RGB_img2,boxes(i,1:4));
%         imPartHist = histogram(imPart,bin); 
%         boxes(i,5)=histdistance(H,imPartHist,3);
%     end
%     boxes = sortrows(boxes,5);
%     imshow(RGB_img2);
%     imrect(gca,boxes(1,1:4));
