<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Upload Car Photo</title>
</head>
<body>
    <h1>Upload Car Photo</h1>
    <form action="upload" method="post" enctype="multipart/form-data">
        <label for="model">Car Model:</label>
        <input type="text" name="model" required><br><br>
        
        <label for="fuel_type">Fuel Type:</label>
        <input type="text" name="fuel_type" required><br><br>
        
        <label for="photo">Upload Photo:</label>
        <input type="file" name="photo" accept="image/*" required><br><br>
        
        <input type="submit" value="Upload">
    </form>
</body>
</html>
