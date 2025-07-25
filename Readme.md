# 💫 Análisis Atmosférico de Titán con MATLAB 🌬️🪐

¡Hola, ser curioso del cosmos! 🌌  
Este repositorio contiene un análisis detallado, práctico y científicamente riguroso de los datos reales del descenso de la sonda **Huygens** en la atmósfera de **Titán**, realizado en **MATLAB** por **Guillermo Adrián Chin Canché**.  
Todo está diseñado para enseñanza, investigación o puro amor por la ciencia planetaria 💻🚀

---

## 📦 Archivos de Datos Utilizados

Los datos provienen del repositorio oficial del **Planetary Data System (PDS4)** de la NASA/ESA:

### 🧪 HASI – Huygens Atmospheric Structure Instrument
- `HASI_L4_ATMO_PROFILE_DESCEN.TAB`: perfil vertical de:
  - Altitud (m)
  - Presión (Pa)
  - Temperatura (K)
  - Densidad (kg/m³)
  - Tiempo (ms)
- `HASI_L4_ATMO_PROFILE_DESCEN.LBL.txt`: etiqueta que describe el contenido

🌐 Fuente:  
https://atmos.nmsu.edu/PDS/data/PDS4/Huygens/hphasi_bundle/DATA/PROFILES/

---

### 💨 ZONALWIND – Doppler Wind Experiment (DWE)
- `ZONALWIND.TAB`: contiene:
  - Altitud (km)
  - Viento zonal (m/s)
  - Error estimado del viento (m/s)
- `ZONALWIND.LBL.txt`: etiqueta que describe el contenido

🌐 Fuente:  
https://atmos.nmsu.edu/PDS/data/PDS4/Huygens/hpdwe_bundle/DATA/

---

## 🧠 Física Aplicada

Este curso utiliza principios clásicos de la física atmosférica y termodinámica aplicados al entorno exótico de Titán:

### 🌡️ Lapse rate y capas atmosféricas
- Gradiente térmico vertical \( \Gamma = -\frac{dT}{dz} \)
- Identificación de troposfera, estratósfera y mesosfera
- Comparación con gradientes adiabáticos (seco y húmedo, para Titán y la Tierra)

### 🔥 Estabilidad estática: Brunt–Väisälä
\[
N^2 = \frac{g}{T} \left( \frac{dT}{dz} + \frac{g}{c_p} \right)
\]
- Diagnóstico de convección estática

### 🌪️ Estabilidad dinámica: número de Richardson
\[
Ri = \frac{N^2}{\left( \frac{du}{dz} \right)^2}
\]
- Identificación de regiones turbulentas por cizalla del viento

### 📈 Otras variables calculadas
- Temperatura potencial \( \theta \)
- Escala de altura local \( H(z) \)
- Velocidad vertical estimada \( w \)
- Masa integrada de la columna atmosférica
- Gradiente adiabático seco \( \Gamma_d = g / c_p \)

---

## 📊 Módulos del Curso

1. **Lectura y perfil térmico**
2. **Lapse rate y tropopausa**
3. **Comparación con perfiles adiabáticos**
4. **Segmentación de capas atmosféricas**
5. **Estabilidad con Brunt–Väisälä**
6. **Cálculo de variables atmosféricas derivadas**
7. **Estabilidad dinámica con número de Richardson**

---

## ✍️ Créditos

Este material fue desarrollado por **Guillermo Adrián Chin Canché**.  
Si utilizas estos scripts, ideas o adaptaciones para docencia, divulgación o publicaciones, **por favor dale el debido crédito como autor del contenido** 🙏✨

---

## 📫 Contacto

- 📧 Correo: **guillermochin.scj@gmail.com**  
- 🌐 Linktree: [https://linktr.ee/guille_chin] (https://linktr.ee/guille_chin)

---

## 📎 Requisitos

- MATLAB (se recomienda R2021b o superior)
- Archivos `.TAB` y `.LBL.txt` mencionados arriba
- Curiosidad científica y amor por el Sistema Solar 🌞🪐

---

## 🚀 ¡Explora, aprende, comparte!

Este curso demuestra cómo podemos extraer conocimiento profundo de datos reales, desde el análisis térmico hasta la dinámica atmosférica de una luna lejana.  
¡Hazlo tuyo, expande el análisis y sigue explorando nuevos mundos!

