%% labelimage
% returns a struct containing several features extracted from the image
% (Area, Centroid, BoundingBox)
function labels = LabelImage(img,disksize)
    disk = strel('disk',disksize);
    background = imopen(img,disk);
    img2 = imsubtract(img,background);    
    img3 = imadjust(img2);
    
    level = graythresh(img3);
    bw = im2bw(img3,level);   
    bw = imclose(bw,disk);

    [labeled, numObjects] = bwlabel(bw,4);
    numObjects
    
    pseudo_color = label2rgb(labeled,@spring,'c','shuffle');
    
    labels = regionprops(labeled,'basic');
    
%     imshow(pseudo_color)
end