function H = createLowPassFilter(M, N, type, D0, varargin)
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
        case 'ILPF'
            % Ideal Low-Pass Filter
            % H(u,v) = 1 jika D(u,v) <= D0
            %        = 0 jika D(u,v) > D0
            H = double(D <= D0);
            
        case 'GLPF'
            % Gaussian Low-Pass Filter
            % H(u,v) = exp(-D^2(u,v) / (2*D0^2))
            H = exp(-(D.^2) / (2 * (D0^2)));
            
        case 'BLPF'
            % Butterworth Low-Pass Filter
            % H(u,v) = 1 / (1 + (D(u,v)/D0)^(2n))
            H = 1 ./ (1 + (D ./ D0).^(2*order));
            
        otherwise
            error('Tipe filter tidak dikenali. Gunakan: ILPF, GLPF, atau BLPF');
    end
end