<?php

function debug_to_log($message) {
    error_log($message);
}

function send_json_response($status, $data) {
    header('Content-Type: application/json');
    echo json_encode(array_merge(['status' => $status], $data));
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Fetch the URL and quality from the form data
    $url = isset($_POST['url']) ? $_POST['url'] : '';
    $quality = isset($_POST['quality']) ? $_POST['quality'] : '';

    if (empty($url) || empty($quality)) {
        debug_to_log("Invalid input parameters: URL: $url, Quality: $quality");
        send_json_response('error', ['message' => 'Invalid input parameters.']);
    }

    // Define the command to run the downloader script
    $script = '/usr/local/bin/youtube_downloader.sh';
    $command = escapeshellcmd("$script \"$url\" \"$quality\"");

    // Run the command and capture the PID
    $output = [];
    $return_var = 0;
    exec("$command > /dev/null 2>&1 & echo $!", $output, $return_var);

    // Debugging
    debug_to_log("Command: $command, Output: " . print_r($output, true) . ", Return: >

    // Check if the command was successful
    if ($return_var === 0 && !empty($output)) {
        $pid = (int) $output[0];
        send_json_response('processing', ['pid' => $pid, 'file' => 'video.webm']);
    } else {
        send_json_response('error', ['message' => 'Failed to start download']);
    }
    } elseif ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['pid']) && isset($_GET[>
    $pid = (int) $_GET['pid'];
    $file = basename($_GET['file']);
    $download_dir = '/var/www/html/videos';

    // Debugging
    debug_to_log("GET Request - PID: $pid, File: $file");

    // Check if the process is still running
    $is_running = false;
    exec("ps $pid", $output);
    if (count($output) >= 2) {
        $is_running = true;
    }

    // Debugging
    debug_to_log("Process is running: " . ($is_running ? 'true' : 'false'));

    if ($is_running) {
        // Return the current progress
        send_json_response('processing', ['progress' => 50]);
    } else {
        // Check if the file exists
        if (file_exists("$download_dir/$file")) {
            send_json_response('completed', ['url' => "/videos/$file"]);
        } else {
            send_json_response('error', ['message' => 'File not found']);
        }
    }
} else {
    send_json_response('error', ['message' => 'Invalid request']);
}
?>

