%% histogram
 % building a 3-dimensional histogram consisting of NxNxN bins
function H = histogram(img,bin)

    % initialize the histogram
    H = zeros(bin,bin,bin);
    
    % define binsize
    binsize = 256/bin;
    img = img+1;
    
    bin1 = ceil(double(img(:,:,1))/binsize);
    bin2 = ceil(double(img(:,:,2))/binsize);
    bin3 = ceil(double(img(:,:,3))/binsize);

    for i=1:size(img,1)
        for j=1:size(img,2)
            H(bin1(i,j),bin2(i,j),bin3(i,j)) = H(bin1(i,j),bin2(i,j),bin3(i,j)) + 1;
        end
    end
    
    H = H / (size(img,1)*size(img,2));
    
end
