#!/bin/bash

# build-flutter.sh

# Paso 1: Limpiar el directorio de trabajo
echo "Limpiando el directorio de trabajo..."
rm -rf /app && mkdir /app

# Paso 2: Clonar el repositorio
echo "Clonando el repositorio..."
git clone ${REPO_URL} /app && cd /app || { echo "Error al clonar el repositorio"; exit 1; }

# Paso 3: Modificar las etiquetas meta
echo "Modificando las etiquetas meta..."

# Definir el archivo de entrada y salida
HTML_FILE="/app/web/index.html"
TEMP_FILE="/app/web/index_temp.html"
CONFIG_FILE="/app/web/config.json"  # Archivo donde guardaremos las variables

# Verificar que el archivo de entrada exista
if [ ! -f "$HTML_FILE" ]; then
    echo "El archivo $HTML_FILE no se encuentra."
    exit 1
fi

# Crear un objeto JSON para almacenar las variables
json_data="{"

# Procesar el archivo línea por línea
while IFS= read -r line; do
    # Buscar etiquetas <meta> con atributo 'property' o 'name'
    if echo "$line" | grep -qE '<meta\s+(property|name)=["'\'']([^"'\'']+)["'\'']\s+content=["'\'']([^"'\'']+)["'\'']\s*/?>'; then
        # Extraer el atributo y el valor del nombre
        attribute=$(echo "$line" | sed -E 's/.*(property|name)=["'\'']([^"'\'']+)["'\''].*/\1/')
        name=$(echo "$line" | sed -E 's/.*(property|name)=["'\'']([^"'\'']+)["'\'']\s+content=["'\'']([^"'\'']+)["'\''].*/\2/')
        content=$(echo "$line" | sed -E 's/.*content=["'\'']([^"'\'']+)["'\''].*/\1/')
        
        # Reemplazar : por - en el nombre de la variable
        clean_name=$(echo "$name" | tr ':' '-')
        
        # Crear la nueva línea con la variable PHP corregida
        new_line="<meta ${attribute}=\"$name\" content=\"<?php echo htmlspecialchars(\$$clean_name); ?>\">"
        echo "Reemplazando: $line"
        echo "Por: $new_line"
        
        # Escribir la nueva línea en el archivo temporal
        echo "$new_line" >> "$TEMP_FILE"
        
        # Guardar las variables en el objeto JSON
        json_data+="\"$clean_name\":\"$content\","
    else
        # Si no es una etiqueta <meta>, escribirla tal cual está
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$HTML_FILE"

# Buscar y capturar las variables theme-color para light y dark
themeColorLight=$(grep -oP '(?<=<meta\s+name="theme-color"\s+media="\(prefers-color-scheme: light\)"\s+content=")[^"]+' "$HTML_FILE")
themeColorDark=$(grep -oP '(?<=<meta\s+name="theme-color"\s+media="\(prefers-color-scheme: dark\)"\s+content=")[^"]+' "$HTML_FILE")

# Agregar las variables themeColorLight y themeColorDark al JSON
json_data+="\"themeColorLight\":\"$themeColorLight\",\"themeColorDark\":\"$themeColorDark\""

# Cerrar el objeto JSON
json_data+="}"

# Escribir el archivo de configuración JSON
echo "$json_data" > "$CONFIG_FILE"

# Reemplazar el archivo original con el modificado
mv "$TEMP_FILE" "$HTML_FILE"

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
