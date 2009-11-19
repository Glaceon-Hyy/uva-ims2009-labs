function out = imconv(I, method)
    out=0;
    switch method
        case 1
            out=RGB2rgb(I);
        case 2
            out=RGB2OCS_KOEN(I);
        case 3
            out=RBG2HSV_WIKI(I);
        case 4
            out=RGB2HSI_THEO(I);
        case 5
            out=RBG2HSV_MATLAB(I);
		case 6
			out = RGB2OCS(I);
    end

end


function J = RGB2rgb(I)
	I = im2double(I);
	
	R = I(:, :, 1);
	G = I(:, :, 2);
	B = I(:, :, 3);

	%% prevent NaN's and Inf's
	R = R + ones(size(R, 1), size(R, 2));
	G = G + ones(size(G, 1), size(G, 2));
	B = B + ones(size(B, 1), size(B, 2));
	S = R + G + B;

	J(:, :, 1) = (R ./ S);
	J(:, :, 2) = (G ./ S);
	J(:, :, 3) = (B ./ S);
end

function J = RGB2OCS(I)
	R = I(:, :, 1);
	G = I(:, :, 2);
	B = I(:, :, 3);

	RG = R - G;
%	YB = (B * 2) - R - G;
	YB = (B * 2) - RG;
	IN = R + G + B;

	J(:, :, 1) = RG;
	J(:, :, 2) = YB;
	J(:, :, 3) = IN;
	J = (J+abs(min(J(:))))/(max(J(:))+abs(min(J(:))));
end

%% RGB2OCS_KOEN
% converts RGB to the Opponent Color Space using conversion steps as
% described by Koen in the paper Evaluating Color Descriptors
% - added normalization
function J = RGB2OCS_KOEN(I)
	R = I(:, :, 1);
	G = I(:, :, 2);
	B = I(:, :, 3);

	J(:, :, 1) = (R - G) / sqrt(2.0);
	J(:, :, 2) = ((R + G) - (B * 2)) / sqrt(6.0);
	J(:, :, 3) = (R + G + B) / sqrt(3.0);
	
	J = (J+abs(min(J(:))))/(max(J(:))+abs(min(J(:))));
% 	min(J(:))
% 	max(J(:))
end

function J = RGB2HSI_THEO(I)
	I = im2double(I);
	D = size(I);
	R = I(:, :, 1); R = R(:);
	G = I(:, :, 2); G = G(:);
	B = I(:, :, 3); B = B(:);

	MinRG  = min(R, G);
	MinGB  = min(G, B);
	MinRGB = min(MinRG, MinGB);

	HU = atan((sqrt(3.0) * (G - B)) ./ ((R - G) + (R - B)));
	SA = 1.0 - (3.0 * MinRGB);
	IN = (R + G + B) * (1/3);
%	IN = sum(I, 3) * 0.333333;

	HU = reshape(HU, D(1:2));
	SA = reshape(SA, D(1:2));
	IN = reshape(IN, D(1:2));

	J = cat(3, HU, SA, IN);

	J = (J+abs(min(J(:))))/(max(J(:))+abs(min(J(:))));

	J(isnan(J)) = 0;
% 	min(J(:))
% 	max(J(:))	
end



%%	RGB2HSV per-pixel conversion (according to WP)
%%			  0                                              if max = min
%%			(60 * ((g - b) / (max - min)) + 360)  mod 360    if max = r
%%		h = (60 * ((b - r) / (max - min)) + 120)             if max = g
%%			(60 * ((r - g) / (max - min)) + 240)             if max = b
%%
%%		s = 0                                                if max = 0
%%			1 - (min / max)                                  otherwise
%%
%%		v = max
function J = RBG2HSV_WIKI(I)
	D = size(I);
	R = I(:, :, 1); R = R(:);
	G = I(:, :, 2); G = G(:);
	B = I(:, :, 3); B = B(:);

	MaxRG  = max(R, G);
	MaxGB  = max(G, B);
	MaxRGB = max(MaxRG, MaxGB);

	MinRG  = min(R, G);
	MinGB  = min(G, B);
	MinRGB = min(MinRG, MinGB);

	%% mask-vectors
	M0 = (MaxRGB >  0.0001);
	M1 = (MaxRGB == MinRGB);
	M2 = (MaxRGB == R);
	M3 = (MaxRGB == G);
	M4 = (MaxRGB == B);

	H2 = (60.0 * ((G(M2) - B(M2)) ./ (MaxRGB(M2) - MinRGB(M2))) + 360.0) ./ 360.0;
	H3 = (60.0 * ((B(M3) - R(M3)) ./ (MaxRGB(M3) - MinRGB(M3))) + 120.0) ./ 360.0;
	H4 = (60.0 * ((R(M4) - G(M4)) ./ (MaxRGB(M4) - MinRGB(M4))) + 240.0) ./ 360.0;

	%% handle angular wrap-around
	H2(H2 > 1.0) = H2(H2 > 1.0) - 1.0;

	H(M1) = 0.0;
	H(M2) = H2;
	H(M3) = H3;
	H(M4) = H4;

	S( M0) = 1.0 - (MinRGB(M0) ./ MaxRGB(M0));
	S(~M0) = 0.0;
	S = S';
	V = MaxRGB;

	H = reshape(H, D(1:2));
	S = reshape(S, D(1:2));
	V = reshape(V, D(1:2));

	J = cat(3, H, S, V);
	J(isnan(J)) = 0;
	
% 	min(J(:))
% 	max(J(:))
	
end



function J = RBG2HSV_MATLAB(I)
	I = im2double(I);
	J = zeros(size(I,1),size(I,2));

	R = I(:, :, 1);
	G = I(:, :, 2);
	B = I(:, :, 3);

	r = R(:);
	g = G(:);
	b = B(:);
	v = max(max(r, g), b);
	h = zeros(size(v));
	s = (v - min(min(r, g), b));

	z = ~s;
	s = s + z;

	k = find(r == v);
	h(k) = (g(k) - b(k))./s(k);

	k = find(g == v);
	h(k) = 2 + (b(k) - r(k))./s(k);

	k = find(b == v);
	h(k) = 4 + (r(k) - g(k))./s(k);

	h = h / 6;


	k = find(h < 0);
	h(k) = h(k) + 1;
	h = (~z) .* h;


	k = find(v);
	s(k) = (~z(k)) .* s(k) ./ v(k);
	s(~v) = 0;

	h = reshape(h, size(J));
	s = reshape(s, size(J));
	v = reshape(v, size(J));
	J = cat(3, h, s, v);
	J = (J+abs(min(J(:))))/(max(J(:))+abs(min(J(:))));
	min(J(:))
	max(J(:))
end
