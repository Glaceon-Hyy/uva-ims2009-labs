%% Lab 7: Mean-shift tracking using Kernel Based Histograms

%% Main function
function main(colorSpace, trackingType, bin)
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
	
	%% interactively select the target model
 	figure; imshow(img, []);
	TargetObject = imrect(gca,[]);
	api = iptgetapi(TargetObject);

	ObjSpecs = api.getPosition();
	
	ModelSize = round([ObjSpecs(3) ObjSpecs(4)]);
	ModelPos = round([ObjSpecs(1) ObjSpecs(2)]);

% 	ModelSize = [20 30];
% 	ModelPos = [270, 250];


	fprintf('ModelSize [%d %d]\n', ModelSize(1), ModelSize(2));
	fprintf('ModelPos [%d %d]\n\n', ModelPos(1), ModelPos(2));
	
	
	normH = [21 21];
	kernel = EpanechnikovKernel(normH(1), normH(2));

	
	
	position = ModelPos;
	
	center = ModelPos + ModelSize/2;
	winSize = ModelSize/2;
	
	%% create the target model
	[TargetModel TargetModelImg] = KernelBasedHist(img, bin, center, winSize, kernel);
	stm = sum(TargetModel(:))

	for i=1:size(images,1)
		img = imread([directory images(i).name]);
		imgOriginal = img;
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
		
		if trackingType == 1
			%% perform brute force search
			position = BruteForce(TargetModel, ...
								   img, ...
								   position, ModelSize, ...
								   widthArea, heightArea, 5, bin, kernel);
			imrect(gca,[position(1) position(2) ModelSize(1) ModelSize(2)]);
	
		else
			%% perform mean shift search
			center = MeanShiftRec(TargetModel, ...
								img, ... 
								center, winSize, ...
								bin, kernel, 1);
% 			if colorSpace > 0
% 				subplot(2,3,1); imshow(img, []);
% 			else
% 				subplot(2,3,1); imshow(img);
% 			end
			subplot(2,3,1); imshow(imgOriginal);
% 			h = imrect(gca,[center - winSize ModelSize]);
% 			api = iptgetapi(h);
% 			api.setColor([1 0 0]);
			h = rectangle('Position', [center - winSize ModelSize]);
			set(h, 'EdgeColor', [1 0 0]);
			subplot(2,3,5); imshow(TargetModelImg);
			
		end
		M(i) = getframe;
	end
	movie(M,1,30);
end




%% MeanShift Algorithm Recursive
function newCenter = MeanShiftRec(TargetModel, img, oldCenter, winSize, bin, kernel, iter)
	
	oldCenter = round(oldCenter);

	[TargetCanHist0 TargetCanImg0] = KernelBasedHist(img, bin, oldCenter, winSize, kernel);
	
	y0Dist = HistDistance(TargetModel, TargetCanHist0, 4);
	
	subplot(2,3,2); imshow(TargetCanImg0);

% 	sum(TargetCanHist0(:))

	CombHist = sqrt(TargetModel ./ TargetCanHist0);
	CombHist(isnan(CombHist)) = 0;
	CombHist(isinf(CombHist)) = 0;	
	
	weights = BackProjection(TargetCanImg0, CombHist, bin);
	subplot(2,3,3); imshow(weights)

	newCenter = [0 0];
	
	sizeWeights = size(weights);
	searchWindow = ([size(weights,1)/2,size(weights,2)/2]);
	
	for i=1 : sizeWeights(1)
		for j=2 : sizeWeights(2)
% 			newCenter = newCenter + (([center(1)-i center(2)-j]) * weights(i,j));
			pos = [j-searchWindow(2) i-searchWindow(1)];
			newCenter = newCenter + (pos.*weights(i,j));
		end
	end
	
	
	newCenter = round((newCenter / sum(weights(:))) + oldCenter);
	fprintf('Iter: %d, newCenter: [%d %d]\n', iter, newCenter(1), newCenter(2));


	if ~insideImage(img, newCenter, winSize)
		newCenter = oldCenter;
	end
	
	
	[TargetCanHist1 TargetCanImg1] = KernelBasedHist(img, bin, newCenter, winSize, kernel);
	y1Dist = HistDistance(TargetModel, TargetCanHist1, 4);

	subplot(2,3,4); imshow(TargetCanImg1);
	
% 	fprintf('Iter: %d, oldCenter: [%d %d], newCenter: [%d %d]\n', iter, oldCenter(1), oldCenter(2), newCenter(1), newCenter(2));
% 	fprintf('Iter: %d, y0Dist: %d, y1Dist: %d\n', iter, y0Dist, y1Dist);
	
	
	while y1Dist < y0Dist
		newCenter = 0.5 * (oldCenter + newCenter);
		
		if ~insideImage(img, newCenter, winSize)
			newCenter = oldCenter;
		end
		
		[TargetCanHist1 TargetCanImg1] = KernelBasedHist(img, bin, newCenter, winSize, kernel);
		subplot(2,3,4); imshow(TargetCanImg1);
		y1Dist = HistDistance(TargetModel, TargetCanHist1, 4);		
% 		fprintf('Iter: %d, oldCenter: [%d %d], newCenter: [%d %d]\n', iter, oldCenter(1), oldCenter(2), newCenter(1), newCenter(2));
% 		fprintf('Iter: %d, y0Dist: %d, y1Dist: %d\n', iter, y0Dist, y1Dist);
	end

	if norm(newCenter - oldCenter) > 0 && iter < 10
		newCenter = MeanShiftRec(TargetModel, img, newCenter, winSize, bin, kernel, iter+1);
	end

end


%% MeanShift Algorithm Iterative
function newCenter = MeanShiftIter(TargetModel, img, oldCenter, winSize, bin, kernel, iter)
	while 1
		oldCenter = round(oldCenter);

		[TargetCanHist0 TargetCanImg0] = KernelBasedHist(img, bin, oldCenter, winSize, kernel);

		y0Dist = HistDistance(TargetModel, TargetCanHist0, 4);

		subplot(2,3,2); imshow(TargetCanImg0);

	% 	sum(TargetCanHist0(:))

		CombHist = sqrt(TargetModel ./ TargetCanHist0);
		CombHist(isnan(CombHist)) = 0;
		CombHist(isinf(CombHist)) = 0;	

		weights = BackProjection(TargetCanImg0, CombHist, bin);
		subplot(2,3,3); imshow(weights)

		newCenter = [0 0];
		for i=1 : size(weights, 1)
			for j=2 : size(weights, 2)
				newCenter = newCenter + (([i j]-oldCenter) * weights(i,j));

			end
		end

		newCenter = round((newCenter / sum(weights(:))) + oldCenter);


		if ~insideImage(img, newCenter, winSize)
			newCenter = oldCenter;
		end


		[TargetCanHist1 TargetCanImg1] = KernelBasedHist(img, bin, newCenter, winSize, kernel);
		y1Dist = HistDistance(TargetModel, TargetCanHist1, 4);

		subplot(2,3,4); imshow(TargetCanImg1);

% 		fprintf('Iter: %d, oldCenter: [%d %d], newCenter: [%d %d]\n', iter, oldCenter(1), oldCenter(2), newCenter(1), newCenter(2));
% 		fprintf('Iter: %d, y0Dist: %d, y1Dist: %d\n', iter, y0Dist, y1Dist);


		while y1Dist < y0Dist
			newCenter = 0.5 * (oldCenter + newCenter);

			if ~insideImage(img, newCenter, winSize)
				newCenter = oldCenter;
			end

			[TargetCanHist1 TargetCanImg1] = KernelBasedHist(img, bin, newCenter, winSize, kernel);
			subplot(2,3,4); imshow(TargetCanImg1);
			y1Dist = HistDistance(TargetModel, TargetCanHist1, 4);		
% 			fprintf('Iter: %d, oldCenter: [%d %d], newCenter: [%d %d]\n', iter, oldCenter(1), oldCenter(2), newCenter(1), newCenter(2));
% 			fprintf('Iter: %d, y0Dist: %d, y1Dist: %d\n', iter, y0Dist, y1Dist);
		end

		if norm(newCenter - oldCenter) > 0.001 && iter < 20
			oldCenter = newCenter;
			iter = iter + 1;
		else 
			break;
		end
	end

end

    
    
