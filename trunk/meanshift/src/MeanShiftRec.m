%% MeanShift Algorithm Recursive
function newCenter = MeanShiftRec(TargetModel, img, oldCenter, winSize, bin, kernel, iter, verbose)
	
	oldCenter = round(oldCenter);

	[TargetCanHist0 TargetCanImg0] = KernelBasedHist(img, bin, oldCenter, winSize, kernel);
	
	y0Dist = HistDistance(TargetModel, TargetCanHist0, 4);

	CombHist = sqrt(TargetModel ./ TargetCanHist0);
	CombHist(isnan(CombHist)) = 0;
	CombHist(isinf(CombHist)) = 0;	
	
	weights = BackProjection(TargetCanImg0, CombHist, bin);
	
% 	sum(TargetCanHist0(:))
	
	newCenter = [0 0];
	
	sizeWeights = size(weights);
	searchWindow = ([size(weights,1)/2,size(weights,2)/2]);

	%% calculate the new center: 
	for i=1 : sizeWeights(1)
		for j=2 : sizeWeights(2)
			pos = [j-searchWindow(2) i-searchWindow(1)];
% 			pos = [i-searchWindow(1) j-searchWindow(2)];
			newCenter = newCenter + (pos.*weights(i,j));
		end
	end
	

	
	totalWeights = sum(weights(:));
	shift = round((newCenter / totalWeights));
	
	if totalWeights > 0
		newCenter = round((newCenter / totalWeights) + oldCenter);
	else
		newCenter = oldCenter;
	end
		
	if verbose
		subplot(1,3,3); imshow(weights);
		Shift = shift
		C = ginput(1);
	end
	

	fprintf('Iter: %d, newCenter: [%d %d]\n', iter, newCenter(1), newCenter(2));


	if ~insideImage(img, newCenter, winSize)
		newCenter = oldCenter;
	end
	
	
	[TargetCanHist1 TargetCanImg1] = KernelBasedHist(img, bin, newCenter, winSize, kernel);
	y1Dist = HistDistance(TargetModel, TargetCanHist1, 4);

% 	subplot(2,3,4); imshow(TargetCanImg1);
% 	fprintf('Iter: %d, oldCenter: [%d %d], newCenter: [%d %d]\n', iter, oldCenter(1), oldCenter(2), newCenter(1), newCenter(2));
% 	fprintf('Iter: %d, y0Dist: %d, y1Dist: %d\n', iter, y0Dist, y1Dist);
	
	
	while y1Dist < y0Dist
		newCenter = 0.5 * (oldCenter + newCenter);
		
		if ~insideImage(img, newCenter, winSize)
			newCenter = oldCenter;
		end
		
		[TargetCanHist1 TargetCanImg1] = KernelBasedHist(img, bin, newCenter, winSize, kernel);
		y1Dist = HistDistance(TargetModel, TargetCanHist1, 4);		

		if verbose
			subplot(1,3,2); imshow(TargetCanImg1);
		end
		
% 		fprintf('Iter: %d, oldCenter: [%d %d], newCenter: [%d %d]\n', iter, oldCenter(1), oldCenter(2), newCenter(1), newCenter(2));
% 		fprintf('Iter: %d, y0Dist: %d, y1Dist: %d\n', iter, y0Dist, y1Dist);
	end

	if norm(newCenter - oldCenter) > 0.1 && iter < 4
		newCenter = MeanShiftRec(TargetModel, img, newCenter, winSize, bin, kernel, iter+1, verbose);
	end

end
