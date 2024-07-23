<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Sanitize user input
    $url = escapeshellarg($_POST['url']);
    $quality = escapeshellarg($_POST['quality']);
    
    // Command to execute the shell script in the background
    $command = "/var/www/html/youtube_downloader.sh $url $quality > /dev/null 2>&1 & echo $!";
    $pid = shell_exec($command);

    // Return the PID to the client
    echo json_encode(['status' => 'processing', 'pid' => $pid]);
} elseif ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['pid'])) {
    // Check the progress of the download
    $pid = intval($_GET['pid']);
    $command = "ps -p $pid -o %cpu,%mem,cmd | tail -n +2";
    $output = shell_exec($command);
    
    if (empty($output)) {
        // Process has finished
        echo json_encode(['status' => 'completed', 'message' => 'Download completed successfully.']);
    } else {
        // Simulate progress (you can implement actual progress tracking here)
        $progress = rand(1, 100);
        echo json_encode(['status' => 'processing', 'progress' => $progress, 'message' => 'Download in progress...']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method or parameters.']);
}
?>

