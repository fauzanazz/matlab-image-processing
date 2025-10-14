function H = createHighPassFilter(M, N, type, D0, varargin)
    if nargin < 5
        order = 2;
    else
        order = varargin{1};
    end
    
    u = 0:(M-1);
    v = 0:(N-1);
    
    idx = find(u > M/2);
    u(idx) = u(idx) - M;
    idy = find(v > N/2);
    v(idy) = v(idy) - N;
    
    [V, U] = meshgrid(v, u);
    
    D = sqrt(U.^2 + V.^2);
    
    switch upper(type)
        case 'IHPF'
            % Ideal High-Pass Filter
            % H(u,v) = 0 jika D(u,v) <= D0
            %        = 1 jika D(u,v) > D0
            H = double(D > D0);
            
        case 'GHPF'
            % Gaussian High-Pass Filter
            % H(u,v) = 1 - exp(-D^2(u,v) / (2*D0^2))
            H = 1 - exp(-(D.^2) / (2 * (D0^2)));
            
        case 'BHPF'
            % Butterworth High-Pass Filter
            % H(u,v) = 1 / (1 + (D0/D(u,v))^(2n))
            % Handle division by zero at center
            H = zeros(size(D));
            nonzero = D ~= 0;
            H(nonzero) = 1 ./ (1 + (D0 ./ D(nonzero)).^(2*order));
            
        otherwise
            error('Tipe filter tidak dikenali. Gunakan: IHPF, GHPF, atau BHPF');
    end
end