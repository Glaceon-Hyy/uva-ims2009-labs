%% Kernel Based Hhistogram
%% building a 3-dimensional histogram consisting of NxNxN bins using
%% weights from kernel. The image patch should be normalized to the size of
%% the kernel.
function [H I] = KernelBasedHist(img, bin, center, winSize, kernel)
	
	img = impart(img, center, winSize);

	I = img;
	
    % initialize the histogram
	H = zeros(bin,bin,bin);
	normHx = size(kernel,1);
	normHy = size(kernel,2);
	
	% define binsize
	binsize = 256/bin;

	img = imresize(img,[normHx, normHy]);
	

	img = (img + abs(min(img(:)))) / (abs(min(img(:))) + max(img(:)));
	img = img*255;
	img = img+1;
	
	%% 
	bin1 = ceil(double(img(:,:,1))/binsize);
	bin2 = ceil(double(img(:,:,2))/binsize);
	bin3 = ceil(double(img(:,:,3))/binsize);
	
	for i=1:size(img,1)
		for j=1:size(img,2)
			H(bin1(i,j),bin2(i,j),bin3(i,j)) = H(bin1(i,j),bin2(i,j),bin3(i,j)) + kernel(i,j);
		end
	end

% 	H = H / (size(img,1)*size(img,2));
end



