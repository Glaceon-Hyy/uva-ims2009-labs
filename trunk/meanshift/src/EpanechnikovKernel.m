function kernel = EpanechnikovKernel(normHx, normHy)
	%% Create a mask of the kernel. Origin is in the center during creation, 
	%% and translated to image coordinates.
	%% The mask will be used to directly assign weights to the pixels in
	%% maskedObj when creating the histogram.

	kernel = zeros(normHx, normHy);
	
	stepSizeX = 2.0/normHx; 
	stepSizeY = 2.0/normHy;
	
	U = -1:stepSizeX:1;
	V = -1:stepSizeY:1;
	
	%% denominator of normalization factor C
	Cden = 0;
	%% create the kernel for the target model
	for u=1:size(U,2)
		for v=1:size(V,2)
% 			x = normPos(i,j)/(normHx*2);
			x = normPos(U(u),V(v));

			kernel(u,v) = Ek(x^2);
			Cden = Cden + kernel(u,v);
		end
	end
	%% normalize kernel imposing the condition sum(histogram) = 1
	kernel = kernel * (1/Cden);
	
end
%{
function kernel = kernel( xSteps,ySteps,kernelTF )

    if kernelTF
        d =2;
        cd = pi;

        xStepSize = 2.0/xSteps;
        yStepSize = 2.0/ySteps;

        x = -1:xStepSize:1;
        y = -1:yStepSize:1;
        kernel = zeros(size(x,2),size(y,2));

        for u=1:size(x,2)
            for v=1:size(y,2)
                normXY = sqrt(x(u)^2+y(v)^2)^2;
                if normXY<1
                    kernel(u,v) = 0.5*(cd^-1)*(d+2)*(1-normXY);
                else
                    kernel(u,v) = 0;
                end
            end
        end
    else
        kernel= ones(xSteps,ySteps);
    end
end

%}

function n = normPos(u,v)
	u = double(u);
	v = double(v);
	n = sqrt(u^2+v^2);
end

%% Epanechnikov Kernel: 
%%   0.5 * Cd^(-1) * (d + 2) * (1 - |x|^2) if |x| =< 1,
%%   0 otherwise.
function y = Ek(x)
	%% given
	Cd = pi; 
	d = 2;
	
	Kx = 0.5*Cd^(-1)*(d + 2)*(1-abs(x)^2);
	if x < 1
		y = Kx;
	else
		y = 0;
	end
end
