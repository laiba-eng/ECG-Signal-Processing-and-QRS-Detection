%% Helper Function: MIT-BIH 212 Format Loader
function [sig_mV, Fs, t, leadNames] = load_mitdb_212(record)
    % Reads MIT-BIH record in 212 format without WFDB toolbox
    % Input: record - string, record number (e.g., '100')
    % Output: sig_mV - signal in mV, Fs - sampling rate, t - time vector, leadNames - channel names
    
    try
        % Read header file
        hea = fileread([record '.hea']);
        lines = regexp(hea, '\r?\n', 'split');
        header = strtrim(lines{1});
        
        % Parse first line: <record> <nsig> <Fs> <Nsamples> ...
        toks = regexp(header, '^\S+\s+(\d+)\s+(\d+)', 'tokens', 'once');
        if isempty(toks)
            error('Invalid header format in %s.hea', record);
        end
        
        nsig = str2double(toks{1});
        Fs   = str2double(toks{2});
        
        % Parse signal information lines
        gain = zeros(1, nsig);
        zerov = zeros(1, nsig);
        leadNames = cell(1, nsig);
        
        for k = 1:nsig
            L = strtrim(lines{1+k});
            % Parse: <file> <fmt> <gain> <bitres> <zero> ... <description>
            tok = regexp(L, '^\S+\s+212\s+([\d\.Ee+-]+)\s+\d+\s+(-?\d+).*?\s([A-Za-z0-9/+-]+)\s*$', 'tokens', 'once');
            if isempty(tok)
                error('Unexpected .hea line format: %s', L);
            end
            gain(k)     = str2double(tok{1});   % ADU per mV
            zerov(k)    = str2double(tok{2});   % ADC zero value
            leadNames{k} = tok{3};              % Lead name
        end
        
        % Read binary data file
        fid = fopen([record '.dat'], 'r');
        if fid == -1
            error('Cannot open %s.dat', record);
        end
        bytes = uint8(fread(fid, inf, 'uint8=>uint8'));
        fclose(fid);
        
        % Ensure complete triplets (212 format uses 3 bytes per 2 samples)
        if mod(numel(bytes), 3) ~= 0
            bytes = bytes(1:3*floor(numel(bytes)/3));
        end
        bytes = reshape(bytes, 3, []).';   % [N x 3]
        
        % Unpack 212 format: two 12-bit samples in 3 bytes
        lo1 = double(bytes(:,1));
        hi  = double(bytes(:,2));
        lo2 = double(bytes(:,3));
        
        s1 = lo1 + 256*bitand(hi, 15);          % First sample
        s2 = lo2 + 256*bitshift(hi, -4);        % Second sample
        
        % Convert 12-bit two's complement to signed integers
        s1(s1 >= 2048) = s1(s1 >= 2048) - 4096;
        s2(s2 >= 2048) = s2(s2 >= 2048) - 4096;
        
        % Interleave samples for multiple channels
        allSamples = [s1 s2].';                 % 2 x Npairs
        allSamples = allSamples(:);             % Vectorize
        
        % Reshape to [nsamples x nsig]
        nsamples = floor(numel(allSamples)/nsig);
        allSamples = allSamples(1:nsamples*nsig);
        adc = reshape(allSamples, nsig, nsamples).';   % [N x nsig]
        
        % Convert ADC values to mV using gain and zero offset
        sig_mV = zeros(size(adc));
        for k = 1:nsig
            sig_mV(:,k) = (adc(:,k) - zerov(k)) ./ gain(k);  % Convert to mV
        end
        
        % Generate time vector
        t = (0:size(sig_mV,1)-1).' / Fs;
        
    catch ME
        error('Error loading MIT-BIH record %s: %s', record, ME.message);
    end
end
