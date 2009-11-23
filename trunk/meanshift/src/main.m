%% Lab 7: Mean-shift tracking using Kernel Based Histograms

%% Main function
function main(colorSpace, histMethod, bin, trackingType, verbose)
    close all;


    widthArea = 20;						%%
    heightArea = 20;					%%
    directory = '../data/';		%% 

	
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
	
	%% interactively select the target model
 	figure; imshow(img, []);
	TargetObject = imrect(gca,[]);
	api = iptgetapi(TargetObject);

	ObjSpecs = api.getPosition();
	
	ModelSize = round([ObjSpecs(3) ObjSpecs(4)]);
	ModelPos = round([ObjSpecs(1) ObjSpecs(2)]);

	fprintf('ModelSize [%d %d]\n', ModelSize(1), ModelSize(2));
	fprintf('ModelPos [%d %d]\n\n', ModelPos(1), ModelPos(2));
	
	
	normH = [51 51];
	kernel = EpanechnikovKernel(normH(1), normH(2));

% 	[x y] = meshgrid(1:1:normH(1));
% 	figure; mesh(x,y,kernel);
	
	position = ModelPos;
	
	center = ModelPos + ModelSize/2;
	winSize = ModelSize/2;

	
	PSF = fspecial('gaussian', 7, 10);
	img = imfilter(img,PSF,'symmetric','conv');
	
	
	%% create the target model
	[TargetModel TargetModelImg] = KernelBasedHist(img, bin, center, winSize, kernel, histMethod);
	stm = sum(TargetModel(:))

	for i=1:size(images,1)
		img = imread([directory images(i).name]);
		imgOriginal = img;
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
			imrect(gca,[position(1) position(2) ModelSize(1) ModelSize(2)]);
	
		else
			%% perform mean shift search
			center = MeanShiftRec(TargetModel, ...
								img, ... 
								center, winSize, ...
								bin, kernel, histMethod, 1, verbose);
			path(i,:) = center;


% 			subplot(2,3,1); 
			if verbose
				hold on;
				subplot(1,3,1); imshow(imgOriginal);
				h = rectangle('Position', [center - winSize ModelSize]);
				set(h, 'EdgeColor', [1 0 0]);
% 				plot(path(:,1),path(:,2),'g-');
				hold off;
			else
				hold on;
				imshow(imgOriginal);
				h = rectangle('Position', [center - winSize ModelSize]);
				set(h, 'EdgeColor', [1 0 0]);
				plot(path(:,1),path(:,2),'g-');
				hold off;
			end
			drawnow;
% 			subplot(2,3,5); imshow(TargetModelImg);
			
		end
		M(i) = getframe;
	end
	movie(M,1,30);
end







    
    
