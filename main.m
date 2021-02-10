clear;
clc;
close all;

tic

%% Beamformer main file
% Loads data, beamforms, and then filters and displayes the results.

% Load pre-beamformed data.
X = load("PreRF_ImageB").preBeamformed;


% Get apodization window (Hann window).

apodization_window = hanning(64, 'symmetric');

%apodization_window = ones(1, 64);

% Generate beamformed data.
Y = beamformer(X, apodization_window);



% Create and apply filter.
fc = 13E6;
fs = X.SampleFreq;
[b,a] = butter(2, fc/(fs/2), "high");

Y = filter(b, a, double(Y));

% Get envelop.
IMAGE = abs(hilbert(Y));

% Display image.
figure;
imagesc(IMAGE); colormap(gray);

toc

