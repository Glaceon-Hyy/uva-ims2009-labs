%% Mean-shift Tracking using Kernel Based Histograms
% Authors:
%	Jasper van Turnhout
%	Rik Tobi
%
% Summary: for the course MAIIMS 2009 there was a project to implement a
% mean-shift tracker. This implementation covers two types of trackers:
% brute-force and the mean-shift tracker (an iterative and recursive
% function). 
%
% An example using only the channel hue from the color space HSV can be run
% as follows (assuming the data is in a directory data in the same folder):
% 
% main(5, 1, 16, 2,'data', 0, 0)
%
% An example using the color space HSV can be run as follows (assuming the 
% data is in a directory data in the same folder):
% 
% main(5, 1, 16, 2,'data', 0, 0)
%
% After starting the user will need to select the target model in the
% presented frame (preferably selection starts topleft to bottomright)

%% Main function
function main(colorSpace, histMethod, bin, trackingType, directory, record, verbose)
% colorSpace: 
%		0- RGB
%		1- normalized RGB
%		2- OCS (koen)
%		3- HSV (wikipedia)
%		4- HSI (theo)
%		5- HSV (matlab)
%		6- OCS
% histMethod:
%		number of channels to use (1, 2 or 3)
% bin:
%		number of bins to use for the histograms (20 works fine)
% trackingType:
%		1- brute-force
%		2- mean-shift recursive
%		3- mean-shift iterative
% record:
%		0- do not record to avi 
%		1- record to avi
% verbose:
%		0-display tracking information
%		1-display extra debug information

    close all;

	if record
		mov = avifile('walk2.avi');
	end

			
	%% search area for bruteforce only
    widthArea = 20;
    heightArea = 20;
    %directory = '../data_tennis1/';		%% directory of data

	
	images = dir(directory);
    images = images(4:end-1);

	
    img = imread([directory images(1).name]);

	%% interactively select the target model
 	figure; imshow(img, []);
	TargetObject = imrect(gca,[]);
	api = iptgetapi(TargetObject);

	ObjSpecs = api.getPosition();
	
	ModelSize = round([ObjSpecs(3) ObjSpecs(4)]);
	ModelPos = round([ObjSpecs(1) ObjSpecs(2)]);

	fprintf('ModelSize [%d %d]\n', ModelSize(1), ModelSize(2));
	fprintf('ModelPos [%d %d]\n\n', ModelPos(1), ModelPos(2));

	
	switch colorSpace
		case 0
			%% keep RGB
		case 1
			%% normalized RGB
			img = imconv(img,1); 
		case 2
			%% Opponent Color Space (Koen)
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
	
	
	
	normH = [51 51];
	kernel = EpanechnikovKernel(normH(1), normH(2));

% 	[x y] = meshgrid(1:1:normH(1)+1);
% 	figure; mesh(x,y,kernel);
% 	figure;
	
	position = ModelPos;
	
	center = ModelPos + ModelSize/2;
	winSize = ModelSize/2;

	
	PSF = fspecial('gaussian', 7, 10);
	img = imfilter(img,PSF,'symmetric','conv');
	
	
	%% create the target model
	[TargetModel TargetModelImg] = KernelBasedHist(img, bin, center, winSize, kernel, histMethod);
	stm = sum(TargetModel(:))

	
% 	M = zeros(size(images,1), size(img,1), size(img,2));
% 	path = zeros(size(images,1),2);
	for i=1:size(images,1)
		tic;
		img = imread([directory images(i).name]);
		imgOriginal = img;
		
		%% blur image for 
		img = imfilter(img,PSF,'symmetric','conv');
		
		
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
								   widthArea, heightArea, 5, bin, kernel, histMethod);
			imshow(imgOriginal);
			imrect(gca,[position- winSize ModelSize]);
	
		elseif trackingType == 2
			%% perform mean shift search (recursive version)
			center = MeanShiftRec(TargetModel, ...
								img, ... 
								center, winSize, ...
								bin, kernel, histMethod, 1, verbose);
			path(i,:) = center;


			if verbose
				hold on;
				subplot(1,3,1); imshow(imgOriginal);
				h = rectangle('Position', [center - winSize ModelSize]);
				set(h, 'EdgeColor', [1 0 0]);
% 				plot(path(:,1),path(:,2),'g-');
				hold off;
	 			drawnow;				
			else
				hold on;
				imshow(imgOriginal);
				h = rectangle('Position', [center - winSize ModelSize]);
				set(h, 'EdgeColor', [1 0 0]);
				plot(path(:,1),path(:,2),'g-');
				hold off;
	 			drawnow;
				if record
					F = getframe(gca);
					mov = addframe(mov,F);
				end
			end
		else
			%% perform mean shift (iterative version)
			center = MeanShiftIter(TargetModel, ...
								img, ... 
								center, winSize, ...
								bin, kernel, histMethod, 1, verbose);
			path(i,:) = center;


			if verbose
				hold on;
				subplot(1,3,1); imshow(imgOriginal);
				h = rectangle('Position', [center - winSize ModelSize]);
				set(h, 'EdgeColor', [1 0 0]);
% 				plot(path(:,1),path(:,2),'g-');
				hold off;
	 			drawnow;								
			else
				hold on;
				imshow(imgOriginal);
				h = rectangle('Position', [center - winSize ModelSize]);
				set(h, 'EdgeColor', [1 0 0]);
				plot(path(:,1),path(:,2),'g-');
				hold off;
				drawnow;
				if record
					F = getframe(gca);
					mov = addframe(mov,F);
				end
			end
		end
		toc;
	end

	if record
		mov = close(mov);
	end
end







    
    
