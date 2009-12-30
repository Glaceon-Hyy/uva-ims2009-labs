%% Brute Force Algorithm:
% widthArea = v1
% heightArea = v2
% hist_obj = histogram(object_to_track)
% bp = backprojection(hist_obj,img_seq[1])
% labels = label(bp)
% best = find_best_obj(labels,hist_obj)
% imshow(img_seq[1])
% imrect(best.box)
% location = [best.box.x + best.box.width/2, best.box.y+best.box.height/2] 
%
% for i=2 to img_seq[end]
%   area = getArea(location,widthArea,heightArea)
%   location = findBestFit(hist_obj,area,img_seq[i])
%   plot(box(location))
% end
function newPosition = BruteForce(TargetModel, img, position, objSize, widthArea, heightArea, sampleStep, bin, kernel, histMethod)
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
			imPartHist = KernelBasedHist(img, bin, pos, objSize, kernel, histMethod);
			temp = HistDistance(TargetModel, imPartHist, 2);
			if temp < distVal
				distVal = temp;
				newPosition = [i, j];
			end
		end
	end
end
