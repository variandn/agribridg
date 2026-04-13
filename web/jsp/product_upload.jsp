<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Upload Product</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f7f8;
            padding: 20px;
        }

        .container {
            max-width: 500px;
            margin: 0 auto;
            background: #ffffff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        h2 {
            text-align: center;
            color: #333333;
        }

        form {
            display: flex;
            flex-direction: column;
        }

        label {
            margin-top: 10px;
            margin-bottom: 5px;
            color: #555555;
        }

        input[type="text"],
        input[type="number"],
        select,
        textarea,
        input[type="file"] {
            padding: 10px;
            border: 1px solid #cccccc;
            border-radius: 4px;
            width: 100%;
            box-sizing: border-box;
            margin-bottom: 15px;
        }

        textarea {
            resize: vertical;
        }

        button {
            background-color: #28a745;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 10px;
        }

        button:hover {
            background-color: #218838;
        }

        /* Success message styles */
        .message.success {
            text-align: center;
            color: white;
            background-color: #28a745; /* Green */
            padding: 10px;
            border-radius: 5px;
        }

        /* Error message styles */
        .message.error {
            text-align: center;
            color: white;
            background-color: #dc3545; /* Red */
            padding: 10px;
            border-radius: 5px;
        }
    </style>
</head>
<body>

<div class="container">

    <h2>Upload New Product</h2>

    <% 
        // Show message based on the result from the servlet
        String message = (String) request.getAttribute("message");
        if (message != null) {
            String messageClass = message.contains("success") ? "success" : "error";
    %>
        <div class="message <%= messageClass %>">
            <%= message %>
        </div>
    <% } %>

    <form action="<%= request.getContextPath() %>/Servlets/UploadProductServlet" method="post" enctype="multipart/form-data">

        <label for="productName">Product Name:</label>
        <input type="text" name="productName" id="productName" required>

        <label for="productDescription">Description:</label>
        <textarea name="productDescription" id="productDescription" rows="4" required></textarea>

        <label for="category">Category:</label>
        <select name="category" id="category" required>
            <option value="">Select</option>
            <option value="Fruits">Fruits</option>
            <option value="Vegetables">Vegetables</option>
            <option value="Grains">Grains</option>
        </select>

        <label for="productPrice">Price (UGX):</label>
        <input type="number" name="productPrice" id="productPrice" required>

        <label for="productStock">Stock Quantity (kg):</label>
        <input type="number" name="productStock" id="productStock" required>

        <label for="productImage">Product Image:</label>
        <input type="file" name="productImage" id="productImage" accept="image/png, image/jpeg" required>

        <button type="submit">Upload Product</button>

    </form>

</div>

</body>
</html>
