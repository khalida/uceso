function [ godCast ] = createGodCast( timeSeries, horizonLength )
%createGodCast: create a perfect foresight horizon forecast for each t-step

godCast = zeros(length(timeSeries), horizonLength);

for ii = 1:horizonLength
    godCast(:, ii) = circshift(timeSeries, -[ii-1, 0]);
end

end
