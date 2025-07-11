%% Módulo 3 – Modelado atmosférico en Titán
clear; clc;

% Leer datos desde el archivo fijo
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

% Convertir a unidades más cómodas
alt_km = data.Altitude_m / 1000;
pres_Pa = data.Pressure_Pa;
pres_mbar = pres_Pa / 100;

%% 📏 Estimar escala de altura H a partir del modelo barométrico

% 🌡️ El modelo barométrico describe cómo la presión disminuye con la altitud
% en una atmósfera isoterma. La fórmula es:
%       P(z) = P0 * exp(-(z - z0) / H)
% donde:
%   - P(z) es la presión en la altitud z
%   - P0 es la presión en una altitud de referencia z0
%   - H es la escala de altura, que representa la "distancia vertical" en la que
%     la presión disminuye a 1/e de su valor inicial
% En una atmósfera ideal:
%       H = (R * T) / g
% donde R es la constante específica del gas, T la temperatura y g la gravedad

% Seleccionar zona lineal entre 10 y 60 km (presión decae exponencialmente)
idx = alt_km > 10 & alt_km < 60;
z_fit = alt_km(idx);
P_fit = pres_Pa(idx);

% Linealizamos: ln(P) = ln(P0) - z/H
lnP = log(P_fit);

% Ajuste lineal para obtener la pendiente = -1/H
p = polyfit(z_fit, lnP, 1);
H = -1 / p(1);  % Escala de altura en km
fprintf("🧮 Escala de altura estimada: H = %.2f km\n", H);

% Usamos el modelo para reconstruir la presión esperada
P0 = P_fit(1);
z0 = z_fit(1);
P_model = P0 * exp(-(alt_km - z0) / H);

%% 📈 Comparar presión real vs modelo
figure;
semilogy(alt_km, pres_Pa, 'b', 'LineWidth', 2); hold on;
semilogy(alt_km, P_model, '--k', 'LineWidth', 2);
xlabel('Altitud (km)');
ylabel('Presión (Pa)');
title('Modelo barométrico vs datos reales');
legend('Presión observada','Modelo barométrico','Location','best');
grid on;

%% 🔬 Estimación de R usando la ecuación de estado

% 📘 La ecuación de estado de los gases ideales es:
%       P = ρ * R * T
% donde:
%   - P es la presión
%   - ρ es la densidad
%   - R es la constante específica del gas (propia de la mezcla atmosférica)
%   - T es la temperatura
% Despejando:
%       R = P / (ρ * T)

R_est = pres_Pa ./ (data.Density_kgm3 .* data.Temperature_K);
R_est(~isfinite(R_est)) = NaN;

% Promedio de R observado
R_mean = mean(R_est, 'omitnan');
fprintf("🧪 Valor medio estimado de R: %.2f J/(kg·K)\n", R_mean);

%% 📊 Graficar R estimado vs altitud
figure;
plot(R_est, alt_km, 'm', 'LineWidth', 2);
xlabel('R estimado (J/kg·K)');
ylabel('Altitud (km)');
title('Estimación de R a partir de P = ρRT');
grid on;
