%% perform backprojection
function B = backprojection(img,obj,bin)

    B = zeros(size(img,1),size(img,2));
    binsize = 256/bin;
    img = img+1; %    
    bin1 = ceil(double(img(:,:,1))/binsize);
    bin2 = ceil(double(img(:,:,2))/binsize);
    bin3 = ceil(double(img(:,:,3))/binsize);
    
    for i=1:size(img,1)
        for j=1:size(img,2)
            B(i,j) = obj(bin1(i,j),bin2(i,j),bin3(i,j));
        end
    end
end