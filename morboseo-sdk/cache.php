<?php
include_once __DIR__ . '/config.php';

// Carga los datos desde el archivo de caché (config.json)
function loadCacheData()
{
    if (!file_exists(CACHE_FILE)) {
        return [];
    }

    $json = file_get_contents(CACHE_FILE);
    $data = json_decode($json, true);

    return is_array($data) ? $data : [];
}

// Guarda los datos en el archivo de caché
function saveCacheData($data)
{
    file_put_contents(CACHE_FILE, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

// Verifica si la API está disponible, y si no, carga desde el caché
function checkApiOrLoadCache()
{
    $apiData = fetchApiData();

    if ($apiData) {
        // Guardar en caché y devolver los datos de la API
        saveCacheData($apiData);
        return $apiData;
    }

    // Si la API falla, cargar desde la caché
    error_log("La API no está disponible. Cargando datos desde el caché.");
    return loadCacheData();
}
