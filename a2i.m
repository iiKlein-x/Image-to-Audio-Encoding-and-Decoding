function a2i(filename)

    % load the sound file
    [sound, fs] = audioread(filename);

    % S = the strip length = number of samples per chunk
    S = floor(fs / 32 + 0.5); %inverse of the estimated sample rate in i2a,0.5 is for rounding
   

    if size(sound, 2) > 1 
        sound = mean(sound, 2); %If stereo, average channels %FFT processing requires single channel
    end

    % split the sound file into chunks
    N = size(sound, 1);  % N = number of samples in audio = total nb of S = S * nb of chunks = S*M

    % pad the array
    paddedN = S * ceil(N / S);
    paddedSound = padarray(sound, paddedN - N, 0, 'post'); %pad with zeros if S isnt a multiple of N

    % split audio into chunks
    soundChunks = reshape(paddedSound, S, paddedN / S); %paddedN / S = nb of chunks = M
    

    % get the fft of the chunk 5time to freq
    fftStrips = fft(soundChunks); 

   
    % cut the top half off fftStrips
    % keeps only positive frequencies
    % rearranges bins to match image frequency layout
    % (inverse of what we did in i2a)
    n = size(fftStrips, 1);
    half_n = floor((n + 1) / 2);
    fftStrips = fftStrips([ (half_n + 1):n  1 ], :);

    

    % adjust the pixel brightnesses (undo brightness normalization)
    n = size(fftStrips, 1);
    for i = 1:n
        fftStrips(i, :) = fftStrips(i, :) * 2^(-6.5 * (i / n) - 2.75);
    end

    fftStrips = fftStrips ./ sqrt(abs(fftStrips));

    % convert the fft to image data, the result is an "image strip"
    


    % get the magnitude and angle
    mag = abs(fftStrips);
    ang = angle(fftStrips);

    scalingFactor = 1.75;  
    mag = mag * scalingFactor;
%     mag = mag / max(mag(:));

    % set Y, C_R and C_B
    y  = mag;
    cr = cos(ang) .* mag;
    cb = sin(ang) .* mag;

    % map it into RGB colour space
    r = y + 1.5750 * cr     - 0.0001515 * cb;
    g = y - 0.46810 * cr   - 0.1873    * cb;
    b = y + 0.0001057 * cr + 1.856     * cb;

    image = cat(3, r, g, b);

    % save the image
    
    image = real(image);
    image(isnan(image)) = 0;
    image(isinf(image)) = 0;
    
    image = max(min(image, 1), 0);     % clamp
    image = uint16(image * 65535);     % force RGB uint16
    imwrite(image, filename + ".png");



end
