function i2a(filename)

    % load the image file
    image = imread(filename);

    ident = 256; %normilze factor


    r = double(image(:,:,1)) / ident;

    if size(image, 3) == 1 %check if image is gryscale
        g = r;
        b = r;
    else
        g = double(image(:,:,2)) / ident;
        b = double(image(:,:,3)) / ident;
    end

    % get (y, cr, cb)
    y  =  .212568 * r + .715236 * g + .072196 * b;
    cr =  .499946 * r - .454155 * g - .045791 * b;
    cb = -.114559 * r - .385338 * g + .499897 * b;

    % adjust (cr, cb) according to the brightness value
    cr = cr ./ y;
    cb = cb ./ y;
    cr(isnan(cr)) = 0; %if y=0
    cb(isnan(cb)) = 0;

    

    mag = y; %magnitude

    % compute angle
    n_c = size(mag, 1); %nb of columns
    ang = zeros(size(mag)); %prepare the matrix
    for index = 1:n_c
        ang(index,:) = angle(cr(index,:) + cb(index,:) * 1i); %compute the angle of each row cr + jcb
        if isempty(ang(index,:))
            disp("ang strip size is zero")
        end
    end

    fftStrips = mag .* exp(ang * 1i); %freq representation of each pixel



    % adjust the pixel brightnesses/magnitude
    fftStrips = fftStrips .* abs(fftStrips);
    n = size(fftStrips, 1);

    %row dependant gain to prevents audio imbalance 
    for i = 1:n
        fftStrips(i, :) = fftStrips(i, :) / 2^(-6.5 * (i / n) - 2.75); %emperical formula, i found and used it as it is :) 
    end

    % put the top half back on
    n_2 = size(fftStrips, 1);
    topHalf = conj(flipud(fftStrips(2:(n_2 - 1), :)));
    fftStrips = [ ...
        fftStrips(n_2, :); ...
        topHalf; ...
        fftStrips(1:(n_2 - 1), :) ...
    ]; %Mirrors the FFT data to ensure the resulting time-domain signal is real


    % get the sound chunks
    soundChunks = ifft(fftStrips); % from frequency to time %sound chunk = matrix %column = chunk; row=samples per chunk


    soundChunksSize = size(soundChunks); %gives nb of rows and columns

    % reduce clicks at sound-chunk boundaries
    %click is a short, sharp noise (a pop or tick) that happens when two audio segments are joined with a sudden jump in amplitude
    %averaging the end of one chunk with the start of the next and relace both by the avg
    for i = 2:soundChunksSize(2)
        soundChunks(1, i) = ...
            (soundChunks(1, i) + soundChunks(soundChunksSize(1), i - 1)) / 2; 
    end


    %Flattens the 2D chunk array into a 1D audio signal and discards any imaginary parts
    sound = reshape(real(soundChunks), ...
                    soundChunksSize(1) * soundChunksSize(2), 1); 

    estSampleRate = soundChunksSize(1) * 32;
    sampleRate = estSampleRate;

    % save the sound file
    sound = sound / max(abs(sound)); % because For standard PCM audio:Valid range: [-1, 1]


    audiowrite(filename + ".wav", sound, sampleRate);






    %  Spectrogram
    figure;
    spectrogram(sound, 256, 250, 256, sampleRate, 'yaxis');
    title('Spectrogram of Reconstructed Audio');
    colormap jet;
    colorbar;

    % save the spectrogram as an image
    h = gcf; % current figure
    spectrogramFile = erase(string(filename), ".png") + "_spectrogram.png";
    saveas(h, spectrogramFile);
    close(h); % close figure to avoid multiple open figures

end
