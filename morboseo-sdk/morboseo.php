<?php
// Bloquear acceso directo al archivo
if (basename(__FILE__) == basename($_SERVER['PHP_SELF'])) {
    http_response_code(403);
    die('Acceso prohibido.');
}

include_once __DIR__ . '/config.php';
include_once __DIR__ . '/api.php';
include_once __DIR__ . '/cache.php';

// Verificamos si la API está disponible
$morboseo_data = checkApiOrLoadCache();

