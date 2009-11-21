function result = insideImage( image, center, winSize )
%INSIDECHECK check if given window is inside image

if center(2)-winSize(2) > 0 && ...
    center(1)-winSize(1) > 0 && ...
    center(2)+winSize(2) < size(image,1) && ...
    center(1)+winSize(1) < size(image,2) 
        result = 1;
else
    result = 0;
end
