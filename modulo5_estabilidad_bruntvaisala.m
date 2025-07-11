%% Módulo 5 – Estabilidad atmosférica y frecuencia de Brunt–Väisälä
clear; clc;

% Leer el archivo
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

% Conversión a km
alt_km = data.Altitude_m / 1000;
T = data.Temperature_K;

% Constantes físicas de Titán
g = 1.35;             % gravedad (m/s^2)
cp = 1040;            % calor específico (J/kg·K)

% Derivada vertical de T
dz = diff(alt_km * 1000);  % en metros
dT = diff(T);
dTdz = dT ./ dz;           % K/m

% Altitudes medias
alt_mid = (alt_km(1:end-1) + alt_km(2:end)) / 2;
T_mid = (T(1:end-1) + T(2:end)) / 2;

% 🌡️ Brunt–Väisälä (frecuencia al cuadrado)
% N^2 = (g/T) * (dT/dz + g/cp)
N2 = (g ./ T_mid) .* (dTdz + g / cp);  % en s⁻²

% Clasificar zonas
estable = N2 > 0;
inestable = N2 < 0;

fprintf("🟢 Zonas estables: %d puntos\n", sum(estable));
fprintf("🔴 Zonas inestables: %d puntos\n", sum(inestable));

%% 📈 Gráfica 1 – N^2 vs altitud
figure;
plot(N2, alt_mid, 'k', 'LineWidth', 2); hold on;
xline(0, '--r', 'N^2 = 0', 'LabelOrientation','horizontal');
xlabel('N² (s⁻²)');
ylabel('Altitud (km)');
title('Frecuencia de Brunt–Väisälä en la Atmósfera de Titán');
grid on;

%% 📊 Gráfica 2 – Zonas coloreadas por estabilidad
figure; hold on;
for i = 1:length(N2)
    if N2(i) > 0
        plot(N2(i), alt_mid(i), 'go', 'MarkerFaceColor', 'g');
    else
        plot(N2(i), alt_mid(i), 'ro', 'MarkerFaceColor', 'r');
    end
end
xlabel('N² (s⁻²)');
ylabel('Altitud (km)');
title('Zonas Estables (verde) vs Inestables (rojo)');
grid on;

%% 🎨 Gráfica 3 – Mapa vertical de estabilidad con color por zona
figure;

% Mapeamos cada punto a un color
cmap = zeros(length(N2), 3);  % matriz RGB

for i = 1:length(N2)
    if N2(i) > 0
        cmap(i,:) = [0 1 0];  % verde (estable)
    else
        cmap(i,:) = [1 0 0];  % rojo (inestable)
    end
end

% Dibujamos usando fill (columna vertical coloreada)
for i = 1:length(alt_mid)
    fill([-1 1 1 -1], [alt_mid(i)-0.25, alt_mid(i)-0.25, alt_mid(i)+0.25, alt_mid(i)+0.25], ...
         cmap(i,:), 'EdgeColor', 'none'); hold on;
end

xlim([-1 1]);
xlabel('Estabilidad');
ylabel('Altitud (km)');
title('Perfil Vertical de Estabilidad en Titán (Color por Zona)');
set(gca,'xtick',[]);
grid on;
