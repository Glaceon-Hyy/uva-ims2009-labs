function bool = insideImage( image, center, winSize )

if center(2)-winSize(2) > 0 && center(1)-winSize(1) > 0 && ...
    center(2)+winSize(2) < size(image,1) && center(1)+winSize(1) < size(image,2) 
        bool = 1;
else
    bool = 0;
end
