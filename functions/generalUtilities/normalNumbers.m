function [ numbers ] = normalNumbers( mu, sigma, dimensions )
%normalNumbers: Generate a 'dimensions' sized matrix with normally
            % distributed random numbers, mean 'mu', std dev 'sigma'

numbers = sigma.*randn(dimensions) + mu;

end

