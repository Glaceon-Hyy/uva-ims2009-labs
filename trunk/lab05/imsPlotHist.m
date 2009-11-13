function [ output_args ] = imsPlotHist( input_args )
	I = imread('../data/nemo1.jpg');
	I = im2double(I);
	%% I = rgb2hsv(I);
	%% I = imsRGB2rgb(I);
	I = I * 0.999;
	T = imcrop(I, [245 105  75 70]);

	n = 16;  %% number of bins per color channel
	r = 1.0; %% total bin value-range (set to 256 if not im2double()'ing)

	[H2D, H3D] = imsHist(T, n, r);

	%% normalization constants
	NH2D =     max(max(H2D));
	NH3D = max(max(max(H3D)));

	imsPlotHist2D(H2D, n, r, NH2D);
	imsPlotHist3D(H3D, n, r, NH3D);
end

function imsPlotHist2D(H, n, r, N)
	m = r / n;
	figure(1);

	XV = 1:n;
	YV = 1:n;
	[XM, YM] = meshgrid(XV, YV);
	ZM = H(XV, YV);

	%{
	%% a wireframe mesh is clearer here than the
	%% filled polygon structure produced by surf()
	mesh(XM ./ n, YM ./ n, ZM);
	set(gca, 'DataAspectRatio', [1 1 N]);
	axis([0 r  0 r  0 N]);
	set(gca, 'XTick', [0:m:r]);
	set(gca, 'YTick', [0:m:r]);

	xlabelStr = sprintf('C1 bin values');
	ylabelStr = sprintf('C2 bin values');
	%}

	%%{
	mesh(XM, YM, ZM);
	set(gca, 'PlotBoxAspectRatio', [1 1 1]);
	axis([1 n  1 n  0 N]);
	set(gca, 'XTick', [1:n]);
	set(gca, 'YTick', [1:n]);

	xlabelStr = sprintf('C1 bin indices');
	ylabelStr = sprintf('C2 bin indices');
	%%}

	set(gca, 'XColor', [1 0 0]);
	set(gca, 'YColor', [0 1 0]);
	set(gca, 'ZColor', [0 0 1]);
	set(gca, 'FontSize', 14);

	hold on;
	titleStr1 = sprintf('C1 value-range: [0, %.2f] -- nr. of C1-bins: %d -- width per bin: %.4f', r, n, m);
	titleStr2 = sprintf('C2 value-range: [0, %.2f] -- nr. of C2-bins: %d -- width per bin: %.4f', r, n, m);
	titleStr  = sprintf('%s\n%s\n', titleStr1, titleStr2);
	title(titleStr);
	zlabelStr = sprintf('nr. of pixels (max.: %d)', N);
	xlabel(xlabelStr);
	ylabel(ylabelStr);
	zlabel(zlabelStr);
end

function imsPlotHist3D(H, n, r, N)
	m = r / n;
	[X, Y, Z] = sphere(20);
	X = (X * m * 0.5);
	Y = (Y * m * 0.5);
	Z = (Z * m * 0.5);

	figure(2);

	%{
	s1 = 1.0;
	s2 = m;
	axis([0 r  0 r  0 r]);
	set(gca, 'DataAspectRatio', [1 1 1]);
	set(gca, 'XTick', [0:m:r]);
	set(gca, 'YTick', [0:m:r]);
	set(gca, 'ZTick', [0:m:r]);

	xlabelStr = sprintf('C1 bin values');
	ylabelStr = sprintf('C2 bin values');
	zlabelStr = sprintf('C3 bin values');
	%}

	%%{
	s1 = n;
	s2 = 1.0;
	axis([1 n  1 n  1 n]);
	set(gca, 'DataAspectRatio', [1 1 1]);
	set(gca, 'XTick', [1:n]);
	set(gca, 'YTick', [1:n]);
	set(gca, 'ZTick', [1:n]);
	xlabelStr = sprintf('C1 bin indices');
	ylabelStr = sprintf('C2 bin indices');
	zlabelStr = sprintf('C3 bin indices');
	%%}

	set(gca, 'XGrid', 'on');
	set(gca, 'YGrid', 'on');
	set(gca, 'ZGrid', 'on');
	set(gca, 'XColor', [1 0 0]);
	set(gca, 'YColor', [0 1 0]);
	set(gca, 'ZColor', [0 0 1]);
	set(gca, 'FontSize', 14);

	hold on;
	titleStr1 = sprintf('C1 value-range: [0, %.2f] -- nr. of C1-bins: %d -- width per-bin: %.4f', r, n, m);
	titleStr2 = sprintf('C2 value-range: [0, %.2f] -- nr. of C2-bins: %d -- width per-bin: %.4f', r, n, m);
	titleStr3 = sprintf('C3 value-range: [0, %.2f] -- nr. of C3-bins: %d -- width per-bin: %.4f', r, n, m);
	titleStr  = sprintf('%s\n%s\n%s\n', titleStr1, titleStr2, titleStr3);
	title(titleStr);
	xlabel(xlabelStr);
	ylabel(ylabelStr);
	zlabel(zlabelStr);

	%% non-flat shading makes bin-sizes harder to judge
	%% L1 = light; set(L1, 'Position', [0 0 0]);
	%% L2 = light; set(L2, 'Position', [r r r]);
	%% L3 = light; set(L3, 'Position', [0 r 0]);

	for xbin = 1:n
		for ybin = 1:n
			for zbin = 1:n
				w = H(xbin, ybin, zbin) / N;

				if (w > 0.10)
					%% only draw a sphere surface for this bin if
					%% it contains at least 10% of the max. value
					Xs = (X * s1 + ((xbin - 0.5) * s2)); Rs = (xbin * m) / r;
					Ys = (Y * s1 + ((ybin - 0.5) * s2)); Gs = (ybin * m) / r;
					Zs = (Z * s1 + ((zbin - 0.5) * s2)); Bs = (zbin * m) / r;
					Ss = surf(Xs, Ys, Zs);

					%% draw an RGB color "cube"
					%% set(Ss, 'FaceColor', [Rs, Gs, Bs], 'EdgeColor', [Rs, Gs, Bs]);
					% draw every sphere in the same shade
					%% set(Ss, 'FaceColor', [1, 0, 0], 'EdgeColor', [Rs, Gs, Bs]);
					%% draw each sphere in a shade proportional to the bin contents
					set(Ss, 'FaceColor', [w, 0, 0], 'EdgeColor', [Rs, Gs, Bs]);
					set(Ss, 'FaceAlpha', 1.0, 'EdgeAlpha', 0.0);
					set(Ss, 'FaceLighting', 'phong');
				end
			end
		end
	end
end



function [H2D, H3D] = imsHist(I, n, r)
	m = r / n;
	H2D = zeros(n, n);    %% for nRGB
	H3D = zeros(n, n, n); %% for RGB, HSV

	CC1 = I(:, :, 1); CC1 = CC1(:);
	CC2 = I(:, :, 2); CC2 = CC2(:);
	CC3 = I(:, :, 3); CC3 = CC3(:);

	%% note: if r is 1.0 instead of 256, then
	%% this can generate OOB indices because
	%% (1.0 / m=(1.0 / n)) is equal to <n>
	CC1I = fix(double(CC1) ./ m) + 1; %% R-channel bin-numbers
	CC2I = fix(double(CC2) ./ m) + 1; %% G-channel bin-numbers
	CC3I = fix(double(CC3) ./ m) + 1; %% B-channel bin-numbers

	%% note: should vectorize this
	for i = 1:size(CC1I)
		c1Idx = uint32(CC1I(i));
		c2Idx = uint32(CC2I(i));
		c3Idx = uint32(CC3I(i));
		H2D(c1Idx, c2Idx       ) = H2D(c1Idx, c2Idx       ) + 1;
		H3D(c1Idx, c2Idx, c3Idx) = H3D(c1Idx, c2Idx, c3Idx) + 1;
	end
end



function J = imsRGB2rgb(I)
	C1 = I(:, :, 1);
	C2 = I(:, :, 2);
	C3 = I(:, :, 3);

	C1 = C1 + ones(size(C1, 1), size(C1, 2));
	C2 = C2 + ones(size(C2, 1), size(C2, 2));
	C3 = C3 + ones(size(C3, 1), size(C3, 2));
	S = C1 + C2 + C3;

	J(:, :, 1) = (C1 ./ S);
	J(:, :, 2) = (C2 ./ S);
	J(:, :, 3) = (C3 ./ S);
end
