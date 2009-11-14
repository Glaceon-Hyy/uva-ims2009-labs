%% histdistance
% calculate distance between 2 histograms
function dist = histdistance(d1,d2,method)
    switch method
        % Euclidean distance
        case 1
            dist = sqrt(sum(sum(sum((d1-d2).^2))));
        % Bhattacharyya distance (reader, page 239)
        case 2
            dist = sqrt(1-sum(sum(sum((d1.*d2).^(0.5)))));
        % Histogram intersection (reader, page 169)
        case 3
            dist = 1 - sum(sum(sum(min(d1,d2))))/sum(sum(sum(d1)));
    end
end
