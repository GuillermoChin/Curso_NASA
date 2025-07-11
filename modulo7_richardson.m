%% Módulo 7 – Estabilidad dinámica: número de Richardson en Titán (lectura robusta)
clear; clc;

%% 🔹 Parte 1: Leer datos de HASI
filename_hasi = 'HASI_L4_ATMO_PROFILE_DESCEN.TAB';
lines_hasi = readlines(filename_hasi);
lines_hasi = lines_hasi(strlength(lines_hasi) >= 52);
n_hasi = numel(lines_hasi);
data_hasi = nan(n_hasi, 5);  % Time, Altitude, Pressure, Temp, Density

for i = 1:n_hasi
    line = lines_hasi(i);
    try
        data_hasi(i,1) = str2double(extractBetween(line, 1, 8));     % Time (ms)
        data_hasi(i,2) = str2double(extractBetween(line, 10, 18));   % Altitude (m)
        data_hasi(i,3) = str2double(extractBetween(line, 20, 31));   % Pressure (Pa)
        data_hasi(i,4) = str2double(extractBetween(line, 33, 41));   % Temperature (K)
        data_hasi(i,5) = str2double(extractBetween(line, 43, 52));   % Density (kg/m^3)
    catch
        continue;
    end
end

data_hasi = data_hasi(~any(isnan(data_hasi),2), :);
alt_km = data_hasi(:,2) / 1000;
T = data_hasi(:,4);

% Constantes físicas
g = 1.35;      % m/s² (Titán)
cp = 1040;     % J/(kg·K)

% Derivadas de temperatura
dz = diff(alt_km * 1000);  % en m
dT = diff(T);
dTdz = dT ./ dz;
alt_mid = (alt_km(1:end-1) + alt_km(2:end)) / 2;
T_mid = (T(1:end-1) + T(2:end)) / 2;

% Calcular N²
N2 = (g ./ T_mid) .* (dTdz + g / cp);

%% 🔹 Parte 2: Leer viento zonal (usando strsplit)
filename_wind = 'ZONALWIND.TAB';
lines_wind = readlines(filename_wind);
lines_wind = lines_wind(strlength(lines_wind) > 0);  % Todas las filas no vacías

n_wind = numel(lines_wind);
wind_data = nan(n_wind, 2);  % Alt_km, u

for i = 1:n_wind
    line = strtrim(lines_wind(i));
    cols = strsplit(line);
    if numel(cols) >= 3
        wind_data(i,1) = str2double(cols{2});  % Altitude (km)
        wind_data(i,2) = str2double(cols{3});  % Wind speed (m/s)
    end
end

wind_data = wind_data(~any(isnan(wind_data),2), :);
alt_wind = wind_data(:,1);
u_wind = wind_data(:,2);
% Eliminar altitudes duplicadas
[alt_wind, idx_unique] = unique(alt_wind);
u_wind = u_wind(idx_unique);


%% 🔹 Parte 3: Interpolar viento a altitudes de N²
u_interp = interp1(alt_wind, u_wind, alt_mid, 'linear', 'extrap');

% Derivada du/dz
du = diff(u_interp);
dz_mid = diff(alt_mid * 1000);  % en m
dudz = du ./ dz_mid;

% Ajustar tamaño de N2 para Ri
N2_mid = (N2(1:end-1) + N2(2:end)) / 2;

% Richardson
Ri = N2_mid ./ (dudz.^2);

% Clasificación
zona_estable = Ri > 1;
zona_transicion = Ri > 0.25 & Ri <= 1;
zona_inestable = Ri <= 0.25;

fprintf("🟢 Zonas estables (Ri > 1): %d\n", sum(zona_estable));
fprintf("🟡 Zonas transición (0.25 < Ri <= 1): %d\n", sum(zona_transicion));
fprintf("🔴 Zonas inestables (Ri <= 0.25): %d\n", sum(zona_inestable));

%% 📈 Gráfica 1 – Número de Richardson vs altitud
figure;
alt_ri = (alt_mid(1:end-1) + alt_mid(2:end)) / 2;
plot(Ri, alt_ri, 'k', 'LineWidth', 2);
xlim([-1 3]);  % o ajusta a [0 2], [0 10], etc.
hold on;
xline(1, '--g', 'Ri = 1');
xline(0.25, '--r', 'Ri = 0.25');
xlabel('Richardson number (Ri)');
ylabel('Altitud (km)');
title('Número de Richardson - Estabilidad Dinámica en Titán');
grid on;

%% 📊 Gráfica 2 – Zonas coloreadas por tipo de estabilidad
figure; hold on;
for i = 1:length(Ri)
    if Ri(i) < 0.25
        plot(Ri(i), alt_ri(i), 'ro', 'MarkerFaceColor', 'r');
    elseif Ri(i) <= 1
        plot(Ri(i), alt_ri(i), 'yo', 'MarkerFaceColor', 'y');
    else
        plot(Ri(i), alt_ri(i), 'go', 'MarkerFaceColor', 'g');
    end
end
xlim([-1 3]);  % o ajusta a [0 2], [0 10], etc.
xlabel('Richardson number (Ri)');
ylabel('Altitud (km)');
title('Zonas Dinámicas: Estables (verde), Transición (amarillo), Inestables (rojo)');
grid on;

