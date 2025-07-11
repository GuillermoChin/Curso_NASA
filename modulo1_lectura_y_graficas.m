%% Módulo 1 – Lectura de datos de HASI y primeras gráficas
clear; clc;

% Paso 1: Leer el archivo línea por línea (formato de columnas fijas)
filename = 'HASI_L4_ATMO_PROFILE_DESCEN.TAB';
lines = readlines(filename);
lines = lines(strlength(lines) >= 52); % Filtrar líneas cortas

% Paso 2: Prealocar matriz para los datos
n = numel(lines);
dataMatrix = nan(n, 5);  % [Time, Altitude, Pressure, Temperature, Density]

% Paso 3: Extraer cada campo por su posición exacta (según el .LBL)
for i = 1:n
    line = lines(i);
    try
        dataMatrix(i,1) = str2double(extractBetween(line, 1, 8));     % Time (ms)
        dataMatrix(i,2) = str2double(extractBetween(line, 10, 18));   % Altitude (m)
        dataMatrix(i,3) = str2double(extractBetween(line, 20, 31));   % Pressure (Pa)
        dataMatrix(i,4) = str2double(extractBetween(line, 33, 41));   % Temperature (K)
        dataMatrix(i,5) = str2double(extractBetween(line, 43, 52));   % Density (kg/m^3)
    catch
        continue;
    end
end

% Paso 4: Eliminar filas vacías (puros NaN)
dataMatrix = dataMatrix(~all(isnan(dataMatrix), 2), :);

% Paso 5: Crear tabla con nombres claros
data = array2table(dataMatrix, 'VariableNames', { ...
    'Time_ms', ...
    'Altitude_m', ...
    'Pressure_Pa', ...
    'Temperature_K', ...
    'Density_kgm3' ...
});

% Paso 6: Mostrar algunas filas para inspección rápida
disp("Primeras filas de datos:");
disp(head(data));

% Paso 7: Conversión de unidades para graficar
alt_km = data.Altitude_m / 1000;     % Altitud en km
pres_mbar = data.Pressure_Pa / 100;  % Presión en mbar

%% Visualización 1: Temperatura vs Altitud
figure;
plot(data.Temperature_K, alt_km, 'r', 'LineWidth', 2);
xlabel('Temperatura (K)');
ylabel('Altitud (km)');
title('Perfil de Temperatura - Descenso de Huygens');
grid on;

%% Visualización 2: Presión vs Altitud (escala log)
figure;
semilogx(pres_mbar, alt_km, 'b', 'LineWidth', 2);
xlabel('Presión (mbar)');
ylabel('Altitud (km)');
title('Perfil de Presión - Descenso de Huygens');
grid on;

%% Visualización 3: Densidad vs Altitud
figure;
plot(data.Density_kgm3, alt_km, 'g', 'LineWidth', 2);
xlabel('Densidad (kg/m³)');
ylabel('Altitud (km)');
title('Perfil de Densidad - Descenso de Huygens');
grid on;

%% Calcular duración total del descenso:
duration_sec = (data.Time_ms(end) - data.Time_ms(1)) / 1000;
fprintf("Duración total del descenso: %.1f minutos\n", duration_sec / 60);

%% Calcular velocidad vertical promedio:
delta_z = data.Altitude_m(1) - data.Altitude_m(end);  % debe ser positiva
w_mean = delta_z / (data.Time_ms(end) - data.Time_ms(1)) * 1000;  % m/s
fprintf("Velocidad vertical promedio: %.2f m/s\n", w_mean);



