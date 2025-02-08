<?php
// Configuración general
define('MORBOSEO_API_URL', 'https://api.morboseo.com/v1/data');
define('CACHE_FILE', __DIR__ . '/../web/config.json');

// Helper para verificar si la respuesta de la API es válida
function isValidApiResponse($response)
{
    $data = json_decode($response, true);
    return is_array($data) && !empty($data);
}
