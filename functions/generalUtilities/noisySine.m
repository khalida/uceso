function ts = noisySine(magnitude, period, noise, nSamples)
% noisySine: Return a column vector with samples of a noisy sine signal

%% INPUT
% magnitude: amplitude of the sinusoidal signal
% period: no. of samples in a period
% noise: magnitude of uniform random noise
% nSamples: no. of samples to output

%% OUTPUT
% ts: [nSamples x 1] column vector of values

ts = magnitude*(sin(2*pi*((1:nSamples)')/period)) + ...
    unifrnd(0, noise, [nSamples, 1]) - noise/2;

end
