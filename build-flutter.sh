#!/bin/bash

# build-flutter.sh

# Paso 1: Limpiar el directorio de trabajo
echo "Limpiando el directorio de trabajo..."
rm -rf /app && mkdir /app

# Paso 2: Clonar el repositorio
echo "Clonando el repositorio..."
git clone ${REPO_URL} /app && cd /app || { echo "Error al clonar el repositorio"; exit 1; }

# Paso 3: Ejecutar el script para modificar las etiquetas meta
echo "Modificando las etiquetas meta..."

# Definir el archivo de entrada
HTML_FILE="/app/web/index.html"

# Asegurarse de que el archivo exista
if [ ! -f "$HTML_FILE" ]; then
    echo "El archivo $HTML_FILE no se encuentra."
    exit 1
fi

# Cambiar el content de las etiquetas meta
echo "Modificando las etiquetas meta en $HTML_FILE..."

# Usamos sed con expresiones regulares más flexibles para reemplazar las etiquetas meta
# Las expresiones regulares ahora permiten manejar los espacios y comillas

# Cambiar las etiquetas con el atributo 'property'
sed -i -E 's|<meta\s+property=["'\''](.*)["'\'']\s+content=["'\''](.*)["'\'']\s*/?>|<meta property="\1" content="<?php echo htmlspecialchars($\1); ?>">|' $HTML_FILE || { echo "Error al modificar las etiquetas meta con property"; exit 1; }

# Cambiar las etiquetas con el atributo 'name'
sed -i -E 's|<meta\s+name=["'\''](.*)["'\'']\s+content=["'\''](.*)["'\'']\s*/?>|<meta name="\1" content="<?php echo htmlspecialchars($\1); ?>">|' $HTML_FILE || { echo "Error al modificar las etiquetas meta con name"; exit 1; }

# Tratamiento especial para las etiquetas theme-color
echo "Modificando las etiquetas theme-color..."

# Cambiar el valor de content para las etiquetas theme-color en base al atributo media
sed -i -E 's|<meta\s+name=["'\'']theme-color["'\'']\s+media=["'\'']\(prefers-color-scheme: light\)["'\'']\s+content=["'\''](.*)["'\'']\s*/?>|<meta name="theme-color" media="(prefers-color-scheme: light)" content="<?php echo htmlspecialchars($themeColorLight); ?>">|' $HTML_FILE || { echo "Error al modificar la etiqueta theme-color (light)"; exit 1; }

sed -i -E 's|<meta\s+name=["'\'']theme-color["'\'']\s+media=["'\'']\(prefers-color-scheme: dark\)["'\'']\s+content=["'\''](.*)["'\'']\s*/?>|<meta name="theme-color" media="(prefers-color-scheme: dark)" content="<?php echo htmlspecialchars($themeColorDark); ?>">|' $HTML_FILE || { echo "Error al modificar la etiqueta theme-color (dark)"; exit 1; }

echo "Modificación completada."

# Paso 4: Instalar las dependencias de Flutter
echo "Instalando dependencias de Flutter..."
flutter pub get || { echo "Error al instalar dependencias de Flutter"; exit 1; }

# Paso 5: Construir el proyecto para web
echo "Construyendo el proyecto para web..."
flutter build web --release || { echo "Error al construir el proyecto para web"; exit 1; }
