clear all
%% Definition of Parameters
Z_compute_domain_edge = 200;                   % verticle edge of computation domain
R_max = 5 * 1;                              % horizantal edge of computation domain
delta_z = 0.5;                                  % verticle step
delta_x = 1;                                  % horizantal step

Z_wb_interface = 100;                           % the depth of 
d = 9;
N = 2 * Z_compute_domain_edge / delta_z;            % the number of sample points
Nr = R_max / delta_x;
Z_00 = zeros(N, N);                                % 
Z_01 = zeros(N, N);           
Z_11 = zeros(N, N);                                % 

%
D_p = zeros(N, N);
r = linspace(0, R_max, Nr + 1);                  % location of each sample point on one row

Z_s = 100;                                      % depth of source
Z_r = 100;                                      % depth of receiver
rho_w = 1000;                                      % mass density of water
rho_b = 2000;                                      % mass density of bottom
f = 250; 
c_pw = 1500;                                    % wave speed of water
c_pb = 1590;                                    % wave speed of bottom
beta_b = 0.5;                                   % attenuation coefficient of bottom
%mu_w = rho_w * c_pw^2 ;                          % the shear wave modules
lambda_w = rho_w * c_pw^2;
k0 = 2 * pi * f / c_pw;                           % wave number in water
NZS = (Z_compute_domain_edge + Z_s) / delta_z;                  % frequency of signal
omega = 2 * pi * f;                             % Angular velocity of signal

%% MOM Coefficients no-derivative
Z00_01 = delta_z / 6;                           
Z00_00 = 2 * delta_z / 3;
Z00_10 = delta_z / 6;

%% MOM Coefficients only one-derivative
Z01_01 = -1 / 2;
Z01_00 = 0;
Z01_10 = 1 / 2;

%% MOM Coefficients both-derivative
Z11_01 = -1 / delta_z;
Z11_00 = 2 / delta_z;
Z11_10 = -1 / delta_z;
% set about sample point on one row
%%    Set enviroment
z_max = 2 * Z_compute_domain_edge;          % mirror
H_up = Z_compute_domain_edge / 3 ;          
Thickness_ABL = Z_compute_domain_edge / 3;              % end of the physical domain
Z_b_up = Z_compute_domain_edge - Z_wb_interface;
Z_b_down = Z_compute_domain_edge + Z_wb_interface;
zr = Z_compute_domain_edge + Z_r;
Zs_down = Z_compute_domain_edge + Z_s;
Zs_up = Z_compute_domain_edge - Z_s;
H_down = z_max - H_up;                % end of the physical domain
D = Thickness_ABL / 3;
l = 2 / k0;
 
n2 = linspace(0, 0, N);   % index of refraction
rho = linspace(0, 0, N);     % mass density
Z = linspace(- Z_compute_domain_edge, Z_compute_domain_edge, N);
delta_kz = 2 * pi / N / delta_z;
kz = linspace(- delta_kz * (N / 2 - 1), delta_kz * N / 2, N);
c_p = linspace(0, 0, N);


for nz = 1 :1 : N
        if (nz - 1) * delta_z <= Z_b_up - l / 2
            rho(nz) = rho_b;
        elseif (nz - 1) * delta_z <= Z_b_up +  l / 2
            rho(nz) = density((nz - 1) * delta_z, Z_b_up, l, rho_b, rho_w);
        elseif (nz - 1) * delta_z <= Z_b_down - l / 2
            rho(nz) = rho_w;
        elseif  (nz - 1) * delta_z <= Z_b_down + l / 2 
            rho(nz) = density((nz - 1) * delta_z, Z_b_down, l, rho_w, rho_b); 
        else
            rho(nz) = rho_b;
        end
end


for nr = 1 : 1 : Nr + 1
    for nz = 1 :1 : N
        if (nz - 1) * delta_z <= Z_b_up - l / 2
            c_p(nz) = c_pb;
        elseif (nz - 1) * delta_z <= Z_b_up +  l / 2
            c_p(nz) = density((nz - 1) * delta_z, Z_b_up, l, c_pb, c_pw);
        elseif (nz - 1) * delta_z <= Z_b_down - l / 2
            c_p(nz) = c_pw;
        elseif  (nz - 1) * delta_z <= Z_b_down + l / 2 
            c_p(nz) = density((nz - 1) * delta_z, Z_b_down, l, c_pw, c_pb); 
        else
            c_p(nz) = c_pb;
        end
    end

   lambda = rho .* c_p.^2 ;                          % the shear wave modules


    for nz = 1 :1 : N
        if (nz - 1) * delta_z <= Thickness_ABL
             n2(nz) = ABL_ATT_bottom(c_pw, c_pb, beta_b, 0 ,(nz - 1) * delta_z, D);
        elseif   (nz - 1) * delta_z <= Z_b_up - l / 2
             n2(nz) = ((c_pw / c_pb)^2 * (1 + 1i * beta_b / 27.29));    % index of refraction in bottom
        elseif   (nz - 1) * delta_z <= Z_b_up + l / 2 
            c = density((nz - 1) * delta_z, Z_b_up, l, c_pb, c_pw);
            n2(nz) =  n_AT_INTERFACE(c_pw, c, k0, rho(nz), rho_b, rho_w, l, (nz - 1) * delta_z, Z_b_up);
        elseif (nz - 1) * delta_z <= Z_b_down - l / 2
            n2(nz) = 1;                 % index of refraction in water
        elseif   (nz - 1) * delta_z <= Z_b_down + l / 2 
            c = density((nz - 1) * delta_z, Z_b_down, l, c_pw, c_pb);
            n2(nz) =  n_AT_INTERFACE(c_pw, c, k0, rho(nz), rho_w, rho_b, l, (nz - 1) * delta_z, Z_b_down);
        elseif   (nz - 1) * delta_z <= H_down
             n2(nz) = ((c_pw / c_pb)^2 * (1 + 1i * beta_b / 27.29));    % index of refraction in bottom
        else
             n2(nz) = ABL_ATT_bottom(c_pw, c_pb, beta_b, (nz - 1) * delta_z, z_max, D);
        end
    end
end


%   information about the signal

%%
        % source
psi = zeros(N, Nr + 1);
TL = zeros(N, Nr + 1);
TL_P = zeros(N, Nr + 1);
TL_tran = zeros(N, Nr + 1);
TL_ref = zeros(N, Nr + 1);
for nz = 1 : 1 : N
    psi(nz, 1) = abs(Gaussian_starter(Zs_down, nz  * delta_z, k0) / sqrt(rho_w) - Gaussian_starter(Zs_up, nz * delta_z, k0) / sqrt(rho_w));
end


w_tran = zeros(N, Nr + 1);
w = zeros(N, Nr + 1);
P = zeros(N, Nr + 1);
p_psi = zeros(N, Nr + 1);
p_w = zeros(N, Nr + 1);

%% DecLre the equations for FFT

for nr = 1 : 1 : Nr
   psi_c(:) = psi(:, nr);
   psi_s = swap(psi_c(:), N/2);
   PSI_S = fft(psi_s(:));
   PSI = swap(PSI_S(:), N/2);
   PSI_T(:) = exp(-1i .* kz(:) .^ 2 * delta_x / 2 / k0 ) .* PSI(:);
   PSI_TS = swap(PSI_T(:), N/2);
   psi_ts = ifft(PSI_TS(:));
   psi_t = swap(psi_ts(:), N/2);
   psi(:, nr + 1) = psi_t(:) .*  exp(1i * k0 .* (n2(:) - 1) * delta_x / 2);
   p_psi(:, nr + 1) = psi(:, nr + 1) * sqrt(2 / pi / k0 / (nr + 1)/ delta_x) * exp(1i * (k0 * (nr + 1) * delta_x - pi / 4) );
end



for nr = 2 : 1 :Nr + 1
    for nz = 1 : 1 : N
        TL(nz, nr) = - 20 * log10(abs(psi(nz, nr) *  sqrt(rho(nz)))./ sqrt((nr - 1) * delta_x)); % abs(psi_5(zs / delta_z)) / sqrt(rho0));
        TL_ref(nz, nr) = - 10 .* log10(conj(p_psi(nz, nr)) .* p_psi(nz, nr) / (nr * delta_x));
    end
end

P(:, 2) = p_psi(:, 2);


%% DecLre the equations for MOM



for m = 1 : 1 : N 
    for n = 1 : 1 : N 
            if m - n == 1
                Z_00(m, n) =  Z00_01;
                Z_01(m, n) =  Z01_01;
                Z_11(m, n) =  Z11_01;
            elseif m - n == 0
                Z_00(m, n) =  Z00_00;
                Z_01(m, n) =  Z01_00;
                Z_11(m, n) =  Z11_00;
            elseif m - n == -1
                Z_00(m, n) =  Z00_10;
                Z_01(m, n) =  Z01_10;
                Z_11(m, n) =  Z11_10;
            else
                Z_00(m, n) = 0;
                Z_01(m, n) = 0;
                Z_11(m, n) = 0;
            end
   end
end

Z_01_inv = Tridiagonal_Matrix_inverse(N, Z_01);
ZA = Z_01_inv * (Z_11 - omega^2 * Z_00 .* rho ./ lambda);
Z_inv = inv(ZA);
ZB = Z_00 * Z_inv + Z_01;
ZC = inv(ZB);
Y = ZC * omega^2 * Z_00 * Z_inv .* rho ./ lambda;
[V,D]=eig(Y,'nobalance');
B = diag(D);
V_inv = pinv(V);
   
for k = 1 : 1 : N
    if D(k, k) > 10^(-8)
        D_p(k, k) = 1i * sqrt(D(k, k));
    elseif D(k, k) < - 10^(-8)
        D_p(k, k) = - sqrt(abs(D(k, k)));
    else
        D_p(k, k) = 0;
    end
end
DP = expm( D_p *  delta_x);
DP_dia = diag(DP);
w(:, 2) = - Z_00 / (Z_00 * Z_inv + Z_01) ./ lambda * P(:, 2);
for nr = 3 : 1 : Nr + 1
    w_tran(:, nr - 1) = V_inv * w(:, nr - 1);
    w_tran(:, nr) = DP * w_tran(:, nr - 1);
%    ux(:, nr) = V * exp( D_sqrt * delta_x) / V *  ux(:, nr - 1);
    w(:, nr) = V *  w_tran(:, nr);
    P(:, nr) =  -1 * (Z_00 * Z_inv + Z_01) \ Z_00 .* lambda * w(:, nr);
end
ux = Z_inv * w;


for nr = 2 : 1 :Nr + 1
    for nz = 1 : 1 : N
        TL_P(nz, nr) = - 10 .* log10(conj(P(nz, nr)) .* P(nz, nr) / (conj(P(NZS, nr)) .* P(NZS, nr)) / (nr * delta_x)); % abs(psi_5(zs / delta_z)) / sqrt(rho0));
    end
end
%}
%% Define reference transmission loss, it will use to compare our calculated result.

%%  error at receiver (nz = 199) at 7000m 

%% Show the result

figure
Fig1 = pcolor(r, Z, TL);
hold on 
set(Fig1,'edgecolor','none');
set(gca,'fontsize', 32,'ydir','reverse');
xlabel('Range (m)');  
ylabel('Depth (m)');
caxis([0 160]);
h=colorbar;
set(get(h,'title'),'string','dB');
colormap jet;

figure
Fig2 = pcolor(r, Z,TL_P);
hold on 
set(Fig2,'edgecolor','none');
set(gca,'fontsize', 32,'ydir','reverse');
xlabel('Range(m)');  
ylabel('Depth(m)');
caxis([0 160]);
h=colorbar;
set(get(h,'title'),'string','dB');
colormap jet;
%{
figure
Fig3 = pcolor(r, Z,TL_ref);
hold on 
set(Fig3,'edgecolor','none');
set(gca,'fontsize', 32,'ydir','reverse');
xlabel('Range(m)');  
ylabel('Depth(m)');
caxis([0 160]);
h=colorbar;
set(get(h,'title'),'string','dB');
colormap jet;


figure
Fig3 = pcolor(r, Z,log10(abs(ux)));
hold on 
set(Fig3,'edgecolor','none');
set(gca,'fontsize', 32,'ydir','reverse');
xlabel('Range(m)');  
ylabel('Depth(m)');
%caxis([-4 4]);
h=colorbar;
%set(get(h,'title'),'string','dB');
colormap jet;

%}
%{
figure
plot(Z, real(p_psi(:, 3)),'b', Z, real(p_w(:, 3)),'r');
hold on 
set(gca,'fontsize', 32);
xlabel('depth(m)');  
ylabel('Pressure(kg/m^2)');

figure
plot(Z, imag(p_psi(:, 3)),'--b', Z, imag(p_w(:, 3)),'--r');
hold on 
set(gca,'fontsize', 32);
xlabel('depth(m)');  
ylabel('Pressure(kg/m^2)');

figure
plot(Z, real(p_psi(:, 100)),'b', Z, real(p_w(:, 100)),'r');
hold on 
set(gca,'fontsize', 32);
xlabel('depth(m)');  
ylabel('Pressure(kg/m^2)');


figure
plot( Z, imag(p_psi(:, 100)),'--b', Z, imag(p_w(:, 100)),'--r');
hold on 
set(gca,'fontsize', 32);
xlabel('depth(m)');  
ylabel('Pressure(kg/m^2)');


figure
plot(real(P),'k');
hold on 
plot(imag(P),'--k');
set(gca,'fontsize', 32);
xlabel('k');  
ylabel('d(k)');
%}


figure
Fig6 = plot(real(DP_dia),'b');
hold on 
plot(imag(DP_dia),'r--')
set(gca,'fontsize', 32);
xlabel('k element');  
ylabel('magnitude');
%{

figure
Fig7 = pcolor(r, Z,log10(abs(ux_tran)));
hold on 
set(Fig7,'edgecolor','none');
set(gca,'fontsize', 32,'ydir','reverse');
xlabel('Range(m)');  
ylabel('Depth(m)');
%caxis([-4 4]);
h=colorbar;
%set(get(h,'title'),'string','dB');
colormap jet;
%}


%% Sub functions define
function rho = density(z, ZB, L, rho1, rho2)
rho = 0.5 * (rho1 + rho2) + 0.5 * (rho2 - rho1) * tanh((z - ZB) / L) ;
end

function source = Gaussian_starter(ZS, ZR, K0)
source =  sqrt(K0) * exp(- K0 ^ 2 / 2 * (ZR - ZS) ^ 2);
end

function [L_INVERSE] = Tridiagonal_Matrix_inverse(N, L)
L_INVERSE = zeros(N, N);
psi = linspace(0,0,N + 1);
theta = linspace(0,0,N + 1);
psi(N + 1) = 1;
psi(N) = L(N, N);
theta(1) = 1;
theta(2) = L(1, 1);
for conter = 2 + 1 : 1 : N + 1
     theta(conter) =  L(conter - 1, conter - 1) * theta(conter - 1) - L(conter - 2, conter - 1) * L(conter - 1, conter - 2) *  theta(conter - 2);
     psi(N + 2 - conter) = L(N + 2 - conter, N + 2 - conter) * psi(N + 3 - conter) - L(N + 3 - conter, N + 2 - conter) * L(N + 2 - conter, N + 3 - conter) * psi(N + 4 - conter);
end
for k = 1 : 1 : N
    for ell = 1 : 1 : N
        B = 1;
        C = 1;
        if k < ell
             for conter = k : 1 : ell - 1
                 B = B *  L(conter, conter + 1);
             end
            L_INVERSE(k, ell) = (-1)^(k + ell) *  B * theta(k) * psi(ell + 1) / theta(N + 1);
        elseif k == ell
            L_INVERSE(k, ell) = theta(k) * psi(ell + 1) / theta(N + 1);
        elseif k > ell
            for conter = ell : 1 : k - 1
                 C = C *  L(conter + 1, conter);
             end
            L_INVERSE(k, ell) = (-1)^(k + ell) *  C * theta(ell) * psi(k + 1) / theta(N + 1);
        end
    end
end
end


function output = swap(input, half_index)
    for n = 1 : 1 : half_index * 2
        if n < half_index + 1
            output(n) = input(half_index + n);
        else
            output(n) = input(n - half_index);
        end
    end
end

function index_5raction = ABL_ATT_bottom(C0, CB, ATT_B, Depth, ZMAX, DB)
index_5raction = ((C0 / CB)^2 * (1 + 1i * ATT_B / 27.29)  + 1i * 0.01 * exp(-((Depth - ZMAX) / DB)^2));
end

function index_5raction = n_AT_INTERFACE(C0, C, K0, RHO, RHO_UP, RHO_DOWN, L, Depth, Depth_of_interface)
N2 = (C0 / C) ^2;
Partial_RHO = (RHO_DOWN - RHO_UP) / 2 * sech((Depth - Depth_of_interface) / L)^2;
Partial2_RHO = -(RHO_DOWN - RHO_UP) * sech((Depth - Depth_of_interface) / L)^2 * tanh((Depth - Depth_of_interface) / L);
index_5raction =  N2 + (0.5 / K0 ^ 2) *(1 / RHO * Partial2_RHO - 1.5 / RHO ^ 2 * Partial_RHO ^2);
end