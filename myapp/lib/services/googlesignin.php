<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->idToken) && !empty($data->email)) {
    // Verify Google ID token (you should implement proper verification)
    // For now, we'll just use the received data
    
    $conn = new mysqli("localhost", "username", "password", "your_database");
    
    // Check if user exists
    $query = "SELECT * FROM users WHERE email = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $data->email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if($result->num_rows === 0) {
        // User doesn't exist, create new account
        $insertQuery = "INSERT INTO users (google_id, name, email, profile_pic) VALUES (?, ?, ?, ?)";
        $insertStmt = $conn->prepare($insertQuery);
        $insertStmt->bind_param("ssss", $data->googleId, $data->name, $data->email, $data->photoUrl);
        $insertStmt->execute();
        $userId = $conn->insert_id;
    } else {
        // User exists, get user data
        $user = $result->fetch_assoc();
        $userId = $user['id'];
    }
    
    // Return user data
    echo json_encode([
        'status' => 'success',
        'user' => [
            'id' => $userId,
            'name' => $data->name,
            'email' => $data->email,
            'profile_pic' => $data->photoUrl
        ]
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid data']);
}
?>