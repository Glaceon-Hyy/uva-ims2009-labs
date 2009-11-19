function kernel = EpanechnikovKernel(normHx, normHy)
	%% Create a mask of the kernel. Origin is in the center during creation, 
	%% and translated to image coordinates.
	%% The mask will be used to directly assign weights to the pixels in
	%% maskedObj when creating the histogram.

	U = (normHx-1)/2;
	V = (normHy-1)/2;
	u=1;
	v=1;
	kernel = zeros(normHx, normHy);
	
	
	%% denominator of normalization factor C
	Cden = 0;
	%% create the kernel for the target model
	for i=-U:1:U
		for j=-V:1:V
			x = normPos(i,j)/normHx;

			kernel(u,v) = Ek(x^2);
			Cden = Cden + kernel(u,v);
			v = v + 1;
		end
		v = 1;
		u = u + 1;
	end
	%% normalize kernel imposing the condition sum(histogram) = 1
	kernel = kernel * (1/Cden);
end


function n = normPos(u,v)
	u = double(u);
	v = double(v);
	n = sqrt(u^2+v^2);
end

%% Epanechnikov Kernel: 
%%   0.5 * Cd^(-1) * (d + 2) * (1 - |x|^2) if |x| =< 1,
%%   0 otherwise.
function y = Ek(x)
	%% NOTE: what value to assign for Cd?
	Cd = 2; 
	d = 2; % given
	Kx = 0.5*Cd^(-1)*(d + 2)*(1-abs(x)^2);
	if x <= 1
		y = Kx;
	else
		y = 0;
	end
end
