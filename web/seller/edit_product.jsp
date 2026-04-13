<%-- 
    Document   : edit_product
    Created on : Apr 15, 2025, 2:57:52 PM
    Author     : Administrator
--%>

<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Edit Product</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #e6f2ff;
        }
        .container {
            width: 50%;
            margin: 40px auto;
            background: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px #ccc;
        }
        input, textarea, select {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
            border: 1px solid #aaa;
        }
        input[type="submit"] {
            background-color: #007bff;
            color: white;
            font-weight: bold;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #0069d9;
        }
        h2 {
            text-align: center;
            color: #333;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Edit Product</h2>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    String name = "", category = "", desc = "", image = "";
    int qty = 0;
    double price = 0;

    if (request.getMethod().equalsIgnoreCase("post")) {
        name = request.getParameter("product_name");
        category = request.getParameter("category");
        desc = request.getParameter("description");
        qty = Integer.parseInt(request.getParameter("quantity"));
        price = Double.parseDouble(request.getParameter("price"));
        image = request.getParameter("image_url");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_ride", "root", "yourpassword");
            PreparedStatement ps = con.prepareStatement(
                "UPDATE products SET product_name=?, category=?, description=?, quantity=?, price=?, image_url=? WHERE id=?"
            );
            ps.setString(1, name);
            ps.setString(2, category);
            ps.setString(3, desc);
            ps.setInt(4, qty);
            ps.setDouble(5, price);
            ps.setString(6, image);
            ps.setInt(7, id);

            int updated = ps.executeUpdate();
            if (updated > 0) {
%>
                <p style="color:green; text-align:center;">Product updated successfully.</p>
<%
            }
            ps.close();
            con.close();
        } catch(Exception e) {
%>
            <p style="color:red; text-align:center;">Error: <%= e.getMessage() %></p>
<%
        }
    } else {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_ride", "root", "yourpassword");
            PreparedStatement ps = con.prepareStatement("SELECT * FROM products WHERE id=?");
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                name = rs.getString("product_name");
                category = rs.getString("category");
                desc = rs.getString("description");
                qty = rs.getInt("quantity");
                price = rs.getDouble("price");
                image = rs.getString("image_url");
            }

            rs.close();
            ps.close();
            con.close();
        } catch(Exception e) {
%>
            <p style="color:red; text-align:center;">Error: <%= e.getMessage() %></p>
<%
        }
    }
%>

    <form method="post" action="edit_product.jsp?id=<%= id %>">
        <label>Product Name:</label>
        <input type="text" name="product_name" value="<%= name %>" required>

        <label>Category:</label>
        <select name="category" required>
            <option value="Fruits" <%= category.equals("Fruits") ? "selected" : "" %>>Fruits</option>
            <option value="Vegetables" <%= category.equals("Vegetables") ? "selected" : "" %>>Vegetables</option>
            <option value="Grains" <%= category.equals("Grains") ? "selected" : "" %>>Grains</option>
            <option value="Dairy" <%= category.equals("Dairy") ? "selected" : "" %>>Dairy</option>
            <option value="Others" <%= category.equals("Others") ? "selected" : "" %>>Others</option>
        </select>

        <label>Description:</label>
        <textarea name="description" required><%= desc %></textarea>

        <label>Quantity:</label>
        <input type="number" name="quantity" value="<%= qty %>" required>

        <label>Price:</label>
        <input type="number" step="0.01" name="price" value="<%= price %>" required>

        <label>Image URL:</label>
        <input type="text" name="image_url" value="<%= image %>">

        <input type="submit" value="Update Product">
    </form>
</div>
</body>
</html>


