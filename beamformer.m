function Y  = beamformer(X, apodization_window)

%% Load constants and initialize variables
D_z = X.DeadZone;
v = X.SoundVel;
F_s = X.SampleFreq;
e_w = X.ElementWidth;

B_F = zeros(2048,128);
LBF = zeros(2048,64,128);

sample_count = size(X.Signal,1);
channel_count = size(X.Signal, 2);
line_count = size(X.Signal, 3);

delay = zeros(channel_count);


%% For each sample
% We do the following for each sample
for k = 1:sample_count
    
    %% Find delay
    % For each sample count calculate the focal point. Using pythagoras theorem
    % we can find the path difference dL which we convert from meters to
    % samples.
    % Focal point in meters.
    F =  k * v /(2 * F_s) + D_z;
    
    % For each channel calculate the delay neeeded.
    for ch = 1:channel_count
        
        % Distance in elements from the center of the transducer.
        de = abs(ch - channel_count/2) + 0.5;
        
        % Distance in meters.
        L = e_w * de;
        
        % Calculate the path difference.
        h = sqrt(F.^2 + L.^2);
        dL = h - F;
        
        % From path difference get delay in samples.
        delay(ch) = round(dL * F_s / v);
    end
    
    %% Apply delay and sum the channels on each line
    for line = 1:line_count
        for ch = 1:channel_count
            
            if (k + delay(ch) >= sample_count)
                % Index is out of bounds, set to 0.
                LBF(k, ch, line) = 0;
            else
                % Else copy the signal element with the delayed index.
                LBF(k, ch, line) = X.Signal(k + delay(ch), ch, line);
            end
            
        end
    end
    
%% Create line sum
    for line = 1:line_count
        line_sum = 0;
        
        for ch = 1:channel_count
            
            line_sum = LBF(k,ch,line) * apodization_window(ch) + line_sum;
        end
        
        B_F(k, line) = line_sum;
    end
    
end

%% Return the post-beamformed data
Y = B_F;
end
