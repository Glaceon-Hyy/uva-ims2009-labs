%% Lab 7: Mean-shift tracking using Kernel Based Histograms

%% Main function
function lab07(colorSpace, trackingType, bin)
    close all;

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
		case 6
			img = imconv(img,6)*255; 
	end	
	
	%% interactively select the target model
 	figure; imshow(img);
	TargetObject = imrect(gca,[]);
	api = iptgetapi(TargetObject);

	ObjSpecs = api.getPosition();
	
	ModelSize = [ObjSpecs(3) ObjSpecs(4)];
	ModelPos = [ObjSpecs(1) ObjSpecs(2)];
	
	
	
	normH = [21 21];
	kernel = EpanechnikovKernel(normH(1), normH(2));

	%% create the target model
	TargetModel = KernelBasedHist(img, bin, ModelPos, ModelSize, kernel);


	position = ModelPos;
	position2 = ModelPos;

	for i=1:size(images,1)
		tic;
		img = imread([directory images(i).name]);
		fprintf('Processing %s\n', [directory images(i).name]);
		switch colorSpace
			case 0
				%% keep RGB
			case 1
				%% normalized RGB
				img = imconv(img,1); 
			case 2
				img = imconv(img,2)*255; 
			case 3
				img = imconv(img,3)*255; 
			case 4
				img = imconv(img,4); 
			case 5
				img = imconv(img,5); 
			case 6
				img = imconv(img,6)*255; 
		end
		
		%% display the image
		if colorSpace > 0
			imshow(img, []);
		else
			imshow(img);
		end
		
		if trackingType == 1
			%% perform brute force search
			position = FindBestFit(TargetModel, ...
								   img, ...
								   position, ModelSize, ...
								   widthArea, heightArea, 5, bin, kernel);
			imrect(gca,[position(1) position(2) ModelSize(1) ModelSize(2)]);
		else
			%% perform mean shift search
			position2 = MeanShift(TargetModel, ...
								img, ... 
								position2, ModelSize, ...
								bin, kernel, 1);
			h = imrect(gca,[position2(1) position2(2) ModelSize(1) ModelSize(2)]);
			api = iptgetapi(h);
			api.setColor([1 0 0]);
		end
		
		M(i) = getframe;
		toc;
	end
	movie(M,1,30);
end




%% MeanShift Algorithm
function newPos = MeanShift(TargetModel, img, oldPos, objSize, bin, kernel, iter)
	while 1
		newPos = [0 0];
		TargetCandidate = KernelBasedHist(img, bin, oldPos, objSize, kernel);

		CombinedHist = sqrt( TargetModel ./ TargetCandidate );
		CombinedHist(isnan(CombinedHist)) = 0;
		CombinedHist(isinf(CombinedHist)) = 0;
		imPart = imcrop(img, [oldPos objSize]);
		weights = BackProjection(imPart, CombinedHist, bin);
		center = [oldPos(1)+objSize(1)/2 oldPos(2)+objSize(2)/2];

		u=1;
		v=1;

		for i=oldPos(1): oldPos(1)+objSize(2)
			for j=oldPos(2): oldPos(2)+objSize(1)
				newPos = newPos + (weights(u,v)*[i-center(1) j-center(2)]);
				v=v+1;
			end
			v=1;
			u=u+1;
		end

		newPos = (newPos / sum(weights(:))) + oldPos;
		
		if sum(weights(:)) == 0
			fprintf('zero!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		end

		NewPosTarget = KernelBasedHist(img, bin, newPos, objSize, kernel);

		while HistDistance(TargetModel, NewPosTarget, 4) < HistDistance(TargetModel, TargetCandidate, 4)
			newPos = 0.5 * (oldPos + newPos);
			NewPosTarget = KernelBasedHist(img, bin, newPos, objSize, kernel);	
		end

		if sum(abs(newPos - oldPos)) < 0.01
			break;
		else
			oldPos = newPos;
		end
	end
end



%% FindBestFit
% returns the position of a part of the image which has the closest
% distance in histogram with histObj.
%% Brute Force Algorithm:
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
function newPosition = FindBestFit(TargetModel, img, position, objSize, widthArea, heightArea, sampleStep, bin, kernel)
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
			pos = [i, j];
			imPartHist = KernelBasedHist(img, bin, pos, objSize, kernel);
			temp = HistDistance(TargetModel, imPartHist, 2);
			if temp < distVal
				distVal = temp;
				newPosition = [i, j];
			end
		end
	end
end
    
    
