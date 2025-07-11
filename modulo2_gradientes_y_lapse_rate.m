%% Módulo 2 – Gradientes verticales y lapse rate extendido
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
        dataMatrix(i,1) = str2double(extractBetween(line, 1, 8));     % Time (ms)
        dataMatrix(i,2) = str2double(extractBetween(line, 10, 18));   % Altitude (m)
        dataMatrix(i,3) = str2double(extractBetween(line, 20, 31));   % Pressure (Pa)
        dataMatrix(i,4) = str2double(extractBetween(line, 33, 41));   % Temperature (K)
        dataMatrix(i,5) = str2double(extractBetween(line, 43, 52));   % Density (kg/m^3)
    catch
        continue;
    end
end

dataMatrix = dataMatrix(~all(isnan(dataMatrix), 2), :);
data = array2table(dataMatrix, 'VariableNames', { ...
    'Time_ms', 'Altitude_m', 'Pressure_Pa', 'Temperature_K', 'Density_kgm3' });

% Conversión de unidades
alt_km = data.Altitude_m / 1000;
pres_mbar = data.Pressure_Pa / 100;

% Derivadas
dz = diff(alt_km);                    % km
dT = diff(data.Temperature_K);        % K
dP = diff(pres_mbar);                 % mbar

% Gradiente térmico (K/km)
lapse_rate = -dT ./ dz;
alt_mid = (alt_km(1:end-1) + alt_km(2:end)) / 2;

% Gradiente de presión
dpdz = dP ./ dz;  % mbar/km

%% 🌡️ Visualización 1: Lapse rate con comparación doble
figure;
plot(lapse_rate, alt_mid, 'm', 'LineWidth', 2); hold on;
xline(9.8, '--k', 'Adiabático seco', 'LabelOrientation','horizontal');
xline(6.5, '--b', 'Adiabático húmedo', 'LabelOrientation','horizontal');
xlabel('Lapse Rate (K/km)');
ylabel('Altitud (km)');
title('Lapse Rate vs Altitud en Titán');
legend('Titán','Adiabático seco (Tierra)','Adiabático húmedo (Tierra)', 'Location','best');
grid on;

%% 📉 Visualización 2: Perfil de temperatura comparado con dos modelos
figure;
plot(data.Temperature_K, alt_km, 'r', 'LineWidth', 2); hold on;
T0 = data.Temperature_K(1);
T_dry = T0 - 9.8 .* (alt_km - alt_km(1));
T_wet = T0 - 6.5 .* (alt_km - alt_km(1));
plot(T_dry, alt_km, '--k', 'LineWidth', 1.5);
plot(T_wet, alt_km, '--b', 'LineWidth', 1.5);
xlabel('Temperatura (K)');
ylabel('Altitud (km)');
title('Perfil de Temperatura - Comparación con Modelos Terrestres');
legend('Titán', 'Adiabático seco', 'Adiabático húmedo', 'Location','best');
grid on;

%% 📊 Visualización 3: Gradiente de presión
figure;
plot(dpdz, alt_mid, 'b', 'LineWidth', 2);
xlabel('dP/dz (mbar/km)');
ylabel('Altitud (km)');
title('Gradiente de Presión en la Atmósfera de Titán');
grid on;

%% 🔍 BONUS: Zonas de estabilidad/inestabilidad
zona_inestable = lapse_rate > 9.8;
zona_neutra = abs(lapse_rate - 9.8) < 1;
zona_estable = lapse_rate < 6.5;

fprintf("🟠 Zonas inestables detectadas: %d puntos (%.1f%%)\n", ...
    sum(zona_inestable), 100*sum(zona_inestable)/length(lapse_rate));
fprintf("🟡 Zonas neutras (transición): %d puntos (%.1f%%)\n", ...
    sum(zona_neutra), 100*sum(zona_neutra)/length(lapse_rate));
fprintf("🟢 Zonas estables detectadas: %d puntos (%.1f%%)\n", ...
    sum(zona_estable), 100*sum(zona_estable)/length(lapse_rate));

%% Comparación con modelos adiabáticos de Titán
figure;
plot(data.Temperature_K, alt_km, 'r', 'LineWidth', 2); hold on;

% Perfil adiabático seco (Titán)
T0 = data.Temperature_K(1);  % Temperatura inicial
G_dry_titan = 1.3;           % K/km
T_dry_titan = T0 - G_dry_titan .* (alt_km - alt_km(1));
plot(T_dry_titan, alt_km, '--k', 'LineWidth', 1.5);

% Perfil adiabático húmedo (Titán)
G_wet_titan = 0.6;  % K/km
T_wet_titan = T0 - G_wet_titan .* (alt_km - alt_km(1));
plot(T_wet_titan, alt_km, '--b', 'LineWidth', 1.5);

xlabel('Temperatura (K)');
ylabel('Altitud (km)');
title('Comparación con Perfiles Adiabáticos de Titán');
legend('Titán real', 'Adiabático seco (Titán)', 'Adiabático húmedo (Titán)', 'Location','best');
grid on;
