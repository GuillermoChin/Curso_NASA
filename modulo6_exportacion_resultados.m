%% Módulo 6 – Cálculo de variables atmosféricas derivadas en Titán
clear; clc;

% Leer archivo
filename = 'HASI_L4_ATMO_PROFILE_DESCEN.TAB';
lines = readlines(filename);
lines = lines(strlength(lines) >= 52);
n = numel(lines);
dataMatrix = nan(n, 5);

for i = 1:n
    line = lines(i);
    try
        dataMatrix(i,1) = str2double(extractBetween(line, 1, 8));     % Tiempo (ms)
        dataMatrix(i,2) = str2double(extractBetween(line, 10, 18));   % Altitud (m)
        dataMatrix(i,3) = str2double(extractBetween(line, 20, 31));   % Presión (Pa)
        dataMatrix(i,4) = str2double(extractBetween(line, 33, 41));   % Temperatura (K)
        dataMatrix(i,5) = str2double(extractBetween(line, 43, 52));   % Densidad (kg/m^3)
    catch
        continue;
    end
end

dataMatrix = dataMatrix(~all(isnan(dataMatrix), 2), :);
data = array2table(dataMatrix, 'VariableNames', { ...
    'Time_ms', 'Altitude_m', 'Pressure_Pa', 'Temperature_K', 'Density_kgm3' });

% Constantes de Titán
g = 1.35;               % m/s²
cp = 1040;              % J/(kg·K)
R = 296.9;              % J/(kg·K) para N₂
P0 = 1e5;               % Presión de referencia (Pa)

% Conversión de unidades
alt_km = data.Altitude_m / 1000;
T = data.Temperature_K;
P = data.Pressure_Pa;
rho = data.Density_kgm3;

%% 1. 🌡️ Temperatura potencial
theta = T .* (P0 ./ P) .^ (R / cp);

%% 2. 💨 Velocidad vertical estimada
dt = diff(data.Time_ms) / 1000;            % segundos
dz = diff(data.Altitude_m);                % metros
w = -dz ./ dt;                             % m/s (negativo por descenso)
time_mid = (data.Time_ms(1:end-1) + data.Time_ms(2:end)) / 2;

%% 3. 📏 Escala de altura local
lnP = log(P);
dlnP = diff(lnP);
H_local = -dz ./ dlnP;                     % metros

%% 4. 🔥 Gradiente adiabático seco (constante para Titán)
gamma_dry = g / cp;  % K/m

%% 5. 📦 Masa integrada de la columna
% Integral discreta por suma acumulada
dz_integracion = [0; diff(data.Altitude_m)];
masa_columna = cumsum(rho .* dz_integracion);  % kg/m²

%% 📊 Gráfica 1 – Temperatura potencial
figure;
plot(theta, alt_km, 'm', 'LineWidth', 2);
xlabel('Temperatura Potencial (K)');
ylabel('Altitud (km)');
title('Perfil de Temperatura Potencial en Titán');
grid on;

%% 📊 Gráfica 2 – Velocidad vertical de descenso
figure;
plot(w, alt_km(2:end), 'c', 'LineWidth', 2);
xlabel('Velocidad vertical (m/s)');
ylabel('Altitud (km)');
title('Velocidad Vertical Estimada del Descenso');
grid on;

%% 📊 Gráfica 3 – Escala de altura local
figure;
plot(H_local, alt_km(2:end), 'g', 'LineWidth', 2);
xlabel('Escala de altura H(z) (m)');
ylabel('Altitud (km)');
title('Escala de Altura Local en Titán');
grid on;

%% 📊 Gráfica 4 – Comparación lapse real vs adiabático
dT = diff(T);
dz_m = diff(data.Altitude_m);
lapse_real = -dT ./ dz_m;  % K/m
alt_mid = (alt_km(1:end-1) + alt_km(2:end)) / 2;

figure;
plot(lapse_real, alt_mid, 'k', 'LineWidth', 2); hold on;
yline(gamma_dry, '--r', 'Lapse Adiabático Seco (Titán)');
xlabel('Lapse Rate (K/m)');
ylabel('Altitud (km)');
title('Gradiente Térmico vs Adiabático en Titán');
grid on;

%% 📊 Gráfica 5 – Masa acumulada de la columna
figure;
plot(masa_columna, alt_km, 'b', 'LineWidth', 2);
xlabel('Masa acumulada (kg/m²)');
ylabel('Altitud (km)');
title('Masa Integrada de la Columna Atmosférica');
grid on;

%% 💾 Exportar tabla final
tabla_final = table(data.Altitude_m, P, T, rho, theta, masa_columna, ...
    'VariableNames', {'Altitud_m', 'Presion_Pa', 'Temperatura_K', ...
                      'Densidad_kgm3', 'Temperatura_Potencial_K', 'Masa_Columna_kgm2'});

writetable(tabla_final, 'variables_derivadas_titan.csv');
fprintf('✅ Archivo \"variables_derivadas_titan.csv\" exportado correctamente.\\n');
