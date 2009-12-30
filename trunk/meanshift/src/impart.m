%% impart
% cuts out part of the image based on a given center and a windowsize
function part = impart( img, c, ws )
	% img: the image
	% s = distance from center
	% c = center
	c = round(c);
	ws = round(ws);
	
	part = img(c(2)-ws(2) : c(2)+ws(2), c(1)-ws(1) : c(1)+ws(1), :);
end
