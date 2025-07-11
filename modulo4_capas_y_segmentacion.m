%% Módulo 4 – Segmentación de capas atmosféricas en Titán
clear; clc;

% Leer archivo de datos
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

% Conversión de unidades
alt_km = data.Altitude_m / 1000;
T = data.Temperature_K;

%% 📐 Cálculo del lapse rate
dz = diff(alt_km);
dT = diff(T);
lapse_rate = -dT ./ dz;
alt_mid = (alt_km(1:end-1) + alt_km(2:end)) / 2;

%% 🌫️ Tropopausa
tropo_idx = find(abs(lapse_rate) < 0.3, 1, 'first');
if isempty(tropo_idx)
    warning("No se detectó tropopausa, usando 40 km como valor aproximado.");
    tropo_alt = 40;
else
    tropo_alt = alt_mid(tropo_idx);
end
fprintf("📍 Tropopausa estimada en: %.2f km\n", tropo_alt);

%% 🧱 Visualización de temperatura por capas
alt_max = max(alt_km);
fprintf("Altitud máxima en el perfil: %.2f km\n", alt_max);

umbral_mesosfera = 90;  % puedes ajustar a 90 si deseas

% Inicializamos handles vacíos para crear la leyenda después
hTro = []; hEst = []; hMes = [];

figure; hold on;

for i = 1:length(alt_km)-1
    alt_seg = mean([alt_km(i), alt_km(i+1)]);

    if alt_seg >= umbral_mesosfera
        capa = "Mesosfera"; c = 'g';
        if isempty(hMes)
            hMes = plot([T(i) T(i+1)], [alt_km(i) alt_km(i+1)], ...
                        'Color', c, 'LineWidth', 2, 'DisplayName', 'Mesosfera');
        else
            plot([T(i) T(i+1)], [alt_km(i) alt_km(i+1)], 'Color', c, 'LineWidth', 2);
        end
    elseif alt_seg >= tropo_alt
        capa = "Estratósfera"; c = 'b';
        if isempty(hEst)
            hEst = plot([T(i) T(i+1)], [alt_km(i) alt_km(i+1)], ...
                        'Color', c, 'LineWidth', 2, 'DisplayName', 'Estratósfera');
        else
            plot([T(i) T(i+1)], [alt_km(i) alt_km(i+1)], 'Color', c, 'LineWidth', 2);
        end
    else
        capa = "Troposfera"; c = 'r';
        if isempty(hTro)
            hTro = plot([T(i) T(i+1)], [alt_km(i) alt_km(i+1)], ...
                        'Color', c, 'LineWidth', 2, 'DisplayName', 'Troposfera');
        else
            plot([T(i) T(i+1)], [alt_km(i) alt_km(i+1)], 'Color', c, 'LineWidth', 2);
        end
    end
end

xlabel('Temperatura (K)');
ylabel('Altitud (km)');
title('Perfil de Temperatura con Capas Atmosféricas');

% Mostrar solo las capas presentes
% Crear leyenda de capas presentes
handles = []; nombres = {};
if ~isempty(hTro)
    handles(end+1) = hTro;
    nombres{end+1} = 'Troposfera';
end
if ~isempty(hEst)
    handles(end+1) = hEst;
    nombres{end+1} = 'Estratósfera';
end
if ~isempty(hMes)
    handles(end+1) = hMes;
    nombres{end+1} = 'Mesosfera';
end

if ~isempty(handles)
    legend(handles, nombres, 'Location', 'best');
end
grid on;

%% 📊 Gráfica 2 – Lapse rate con líneas de referencia y tropopausa
figure;
plot(lapse_rate, alt_mid, 'k', 'LineWidth', 2); hold on;

% Líneas verticales de referencia
xline(1.3, '--r', 'Titán seco', 'LabelOrientation','horizontal');
xline(0.6, '--b', 'Titán húmedo', 'LabelOrientation','horizontal');

% Línea horizontal para tropopausa
yline(tropo_alt, '--m', sprintf('Tropopausa (%.1f km)', tropo_alt), 'LabelHorizontalAlignment', 'left');

xlabel('Lapse Rate (K/km)');
ylabel('Altitud (km)');
title('Gradiente Térmico y Detección de Tropopausa');
grid on;

