function [result] = compareCentroids(centroid, compareTo, distance)
	result = 0;
	for index = 1:size(compareTo)
		if compareTo(index,1) == 0 && compareTo(index,1) == 0
			return
		elseif abs(compareTo(index,1) - centroid(1)) > distance
			result = 1;
		end
	end
end