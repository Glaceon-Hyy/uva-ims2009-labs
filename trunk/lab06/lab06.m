%% Lab 6: Brute-force tracking using Kernel Based Histograms
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
function lab06( colorSpace )
    close all;

    bin = 20;
    widthArea = 20;
    heightArea = 20;
    
    directory = '../data/';
    images = dir(directory);
    images = images(3:end-1);

    img = imread([directory images(1).name]);


	switch colorSpace
		case 0
			%% keep RGB
		case 1
			%% normalized RGB
			img = imconv(img,1)*255; 
		case 2
			img = imconv(img,2)*255; 
		case 3
			img = imconv(img,3)*255; 
		case 4
			img = imconv(img,4)*255; 
		case 5
			img = imconv(img,5)*255; 
	end	

    % take only part of the player to get a good histogram 
    RGB_player = imcrop(img,[280,250,5,30]);
	
% 	figure; imshow(img);

	ModelSize = [5 30];
	ModelPos = [280 250];
	
	normH = [21 21];
	kernel = EpanechnikovKernel(normH(1), normH(2));
	
	TargetModel = KernelBasedHist(RGB_player, bin, ModelPos, ModelSize, kernel);
	
    % backproject player against histogram
    bp = BackProjection(img, TargetModel, bin);

	%% get labels 
	labels = LabelImage(bp,3);
	boxes = cat(1,labels.BoundingBox);

	%% find starting position for tracking using labels
	for i=1:size(boxes, 1)
		CandidatePos = boxes(i,1:2);
		CandidateSize = boxes(i, 3:4);
		imPart = imcrop(img,boxes(i, 1:4));
		TargetCandidateHist = KernelBasedHist(imPart, bin, ... 
									CandidatePos, ...
									CandidateSize, ...
									kernel);
		boxes(i,5) = HistDistance(TargetModel, TargetCandidateHist, 2);
	end
	
    boxes = sortrows(boxes,5);
    imshow(img);
    imrect(gca,boxes(1,1:4));
    
    position = boxes(1,1:2);
    boxsize = boxes(1,3:4);
    
    for i=1:size(images,1)
        img = imread([directory images(i).name]);
		switch colorSpace
			case 0
				%% keep RGB
			case 1
				%% normalized RGB
				img = imconv(img,1)*255; 
			case 2
				img = imconv(img,2)*255; 
			case 3
				img = imconv(img,3)*255; 
			case 4
				img = imconv(img,4)*255; 
			case 5
				img = imconv(img,5)*255; 
		end	
        position = FindBestFit(TargetModel, ...
                               img, ...
                               position, ModelSize, ...
                               widthArea, heightArea, 5, bin, kernel);
		if colorSpace > 0
			imshow(img/255);
		else
			imshow(img);
		end
        imrect(gca,[position(1) position(2) boxsize(1) boxsize(2)]);
        M(i) = getframe;
    end
    movie(M,1,30);

end


%% FindBestFit
% returns the position of a part of the image which has the closest
% distance in histogram with histObj.
function newPosition = FindBestFit(histObj, img, position, objSize, widthArea, heightArea, sampleStep, bin, kernel)
	newPosition = position;

	startValX = position(1)-widthArea;
	endValX = position(1)+widthArea;
	startValY = position(2)-heightArea;
	endValY = position(2)+heightArea;

	distVal = 100000;

	%% looping over the area defined by a starting position is difficult to
	%% improve.
	for i = startValX : sampleStep : endValX
		for j = startValY : sampleStep : endValY
			imPart = imcrop(img,[i,j, objSize(2), objSize(1)]);
			pos = [i, j];
			imPartHist = KernelBasedHist(imPart, bin, pos, objSize, kernel);
			temp = HistDistance(histObj,imPartHist,2);
			if temp < distVal
				distVal = temp;
				newPosition = [i, j];
			end
		end
	end
end
    
    
