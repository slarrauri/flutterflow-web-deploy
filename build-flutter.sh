#!/bin/bash

# build-flutter.sh

# Paso 1: Limpiar el directorio de trabajo
echo "Limpiando el directorio de trabajo..."
rm -rf /app && mkdir /app

# Paso 2: Clonar el repositorio
echo "Clonando el repositorio..."
git clone ${REPO_URL} /app && cd /app || { echo "Error al clonar el repositorio"; exit 1; }

# Paso 3: Modificar las etiquetas meta y title
echo "Modificando las etiquetas meta y title..."

# Definir el archivo de entrada y salida
HTML_FILE="/app/web/index.html"
TEMP_FILE="/app/web/index_temp.html"
CONFIG_FILE="/app/web/config.json"  # Archivo donde guardaremos las variables

# Verificar que el archivo de entrada exista
if [ ! -f "$HTML_FILE" ]; then
    echo "El archivo $HTML_FILE no se encuentra."
    exit 1
fi

# Paso 3: Copiar el directorio morboseo-sdk y todo su contenido al directorio /app/web/
echo "Copiando el directorio morboseo-sdk al directorio /app/web/..."
cp -r /deploy/morboseo-sdk /app/web/ || { echo "Error al copiar el directorio morboseo-sdk"; exit 1; }


# Crear un objeto JSON para almacenar las variables
json_data="{"

# Procesar el archivo línea por línea
while IFS= read -r line; do
    # Buscar etiquetas <meta> para theme-color (light)
    if echo "$line" | grep -qE '<meta\s+name=["'\'']theme-color["'\'']\s+media=["'\'']\(prefers-color-scheme: light\)["'\'']\s+content=["'\'']([^"'\'']+)["'\'']\s*/?>'; then
        content=$(echo "$line" | sed -E 's|.*content=["'\'']([^"'\'']+)["'\''].*|\1|')
        new_line="<meta name=\"theme-color\" media=\"(prefers-color-scheme: light)\" content=\"<?php echo htmlspecialchars(\$morboseo_data['theme-color-light']); ?>\">"
        echo "Reemplazando: $line"
        echo "Por: $new_line"
        echo "$new_line" >> "$TEMP_FILE"
        json_data+="\"theme-color-light\":\"$content\","
    
    # Buscar etiquetas <meta> para theme-color (dark)
    elif echo "$line" | grep -qE '<meta\s+name=["'\'']theme-color["'\'']\s+media=["'\'']\(prefers-color-scheme: dark\)["'\'']\s+content=["'\'']([^"'\'']+)["'\'']\s*/?>'; then
        content=$(echo "$line" | sed -E 's|.*content=["'\'']([^"'\'']+)["'\''].*|\1|')
        new_line="<meta name=\"theme-color\" media=\"(prefers-color-scheme: dark)\" content=\"<?php echo htmlspecialchars(\$morboseo_data['theme-color-dark']); ?>\">"
        echo "Reemplazando: $line"
        echo "Por: $new_line"
        echo "$new_line" >> "$TEMP_FILE"
        json_data+="\"theme-color-dark\":\"$content\","
    
    # Buscar la etiqueta <meta> general (con property o name)
    elif echo "$line" | grep -qE '<meta\s+(property|name)=["'\'']([^"'\'']+)["'\'']\s+content=["'\'']([^"'\'']+)["'\'']\s*/?>'; then
        attribute=$(echo "$line" | sed -E 's/.*(property|name)=["'\'']([^"'\'']+)["'\''].*/\1/')
        name=$(echo "$line" | sed -E 's/.*(property|name)=["'\'']([^"'\'']+)["'\'']\s+content=["'\'']([^"'\'']+)["'\''].*/\2/')
        content=$(echo "$line" | sed -E 's/.*content=["'\'']([^"'\'']+)["'\''].*/\1/')
        clean_name=$(echo "$name" | tr ':' '-')  # Reemplazar ':' por '-'
        new_line="<meta ${attribute}=\"$name\" content=\"<?php echo htmlspecialchars(\$morboseo_data['$clean_name']); ?>\">"
        echo "Reemplazando: $line"
        echo "Por: $new_line"
        echo "$new_line" >> "$TEMP_FILE"
        json_data+="\"$clean_name\":\"$content\","
    
    # Buscar la etiqueta <title>
    elif echo "$line" | grep -qE '<title>([^<]+)</title>'; then
        title=$(echo "$line" | sed -E 's|<title>([^<]+)</title>|\1|')
        new_line="<title><?php echo htmlspecialchars(\$morboseo_data['title']); ?></title>"
        echo "Reemplazando: $line"
        echo "Por: $new_line"
        echo "$new_line" >> "$TEMP_FILE"
        json_data+="\"title\":\"$title\","
    
    else
        # Si no es una etiqueta reconocida, escribirla tal cual está
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$HTML_FILE"

# Cerrar el objeto JSON eliminando la última coma y agregando el cierre del objeto
json_data="${json_data%,}}"

# Escribir el archivo de configuración JSON
echo "$json_data" > "$CONFIG_FILE"

# Reemplazar el archivo original con el modificado
mv "$TEMP_FILE" "$HTML_FILE"

echo "Modificación completada."

# Agregar al archivo index.html el código para incluir el SDK
echo "Agregando el código PHP para incluir el SDK en index.html..."
index_file="/app/web/index.html"
if [ -f "$index_file" ]; then
    # Insertar el código PHP correctamente al inicio del archivo index.html sin borrar su contenido
    sed -i '1s/^/<?php\n\/\/ Incluir el SDK\ninclude "morboseo-sdk\/morboseo.php";\n?>\n\n/' "$index_file"
else
    echo "El archivo index.html no se encuentra."
    exit 1
fi



# Paso 4: Instalar las dependencias de Flutter
echo "Instalando dependencias de Flutter..."
flutter pub get || { echo "Error al instalar dependencias de Flutter"; exit 1; }

# Paso 5: Construir el proyecto para web
echo "Construyendo el proyecto para web..."
flutter build web --release || { echo "Error al construir el proyecto para web"; exit 1; }

# Paso adicional: Renombrar el archivo index.html a index.php
echo "Renombrando index.html a index.php..."
mv /app/build/web/index.html /app/build/web/index.php || { echo "Error al renombrar el archivo"; exit 1; }

echo "Renombrado completado."
