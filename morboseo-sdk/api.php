<?php
include_once __DIR__ . '/config.php';

function fetchApiData()
{
    $curl = curl_init();
    
    curl_setopt_array($curl, [
        CURLOPT_URL => MORBOSEO_API_URL,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 5,
        CURLOPT_FOLLOWLOCATION => true,
    ]);

    $response = curl_exec($curl);
    $error = curl_error($curl);
    curl_close($curl);

    if ($error) {
        error_log("Error al conectarse a la API: $error");
        return false;
    }

    if (isValidApiResponse($response)) {
        return json_decode($response, true);
    }

    return false;
}
