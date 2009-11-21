%% perform backprojection
function B = BackProjection(img, obj, bin)
	img = (img + abs(min(img(:)))) / (abs(min(img(:))) + max(img(:)));
	img = img*255;
	img = img+1;

    B = zeros(size(img,1),size(img,2));
    binsize = 256/bin;
    bin1 = ceil(double(img(:,:,1))/binsize);
    bin2 = ceil(double(img(:,:,2))/binsize);
    bin3 = ceil(double(img(:,:,3))/binsize);
    
    for i=1:size(img,1)
        for j=1:size(img,2)
            B(i,j) = obj(bin1(i,j),bin2(i,j),bin3(i,j));
        end
    end
end