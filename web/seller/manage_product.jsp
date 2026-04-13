<%-- 
    Document   : manage_product
    Created on : Apr 15, 2025, 2:53:32 PM
    Author     : Administrator
--%>

<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>My Products</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f2f2f2;
        }
        h2 {
            text-align: center;
            color: #333;
        }
        table {
            width: 90%;
            margin: 30px auto;
            border-collapse: collapse;
            background: #fff;
            box-shadow: 0 0 10px #ccc;
        }
        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: center;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .action-btn {
            padding: 6px 12px;
            margin: 2px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .edit-btn {
            background: #007bff;
            color: white;
        }
        .delete-btn {
            background: #dc3545;
            color: white;
        }
    </style>
</head>
<body>
<h2>My Uploaded Products</h2>

<%
    // Simulate logged-in seller
    int sellerId = 20; // Replace with session.getAttribute("seller_id");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");
        PreparedStatement ps = con.prepareStatement("SELECT * FROM products WHERE seller_id = ?");
        ps.setInt(1, sellerId);
        ResultSet rs = ps.executeQuery();
%>

<table>
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Category</th>
        <th>Description</th>
        <th>Qty</th>
        <th>Price</th>
        <th>Date</th>
         <th>Action</th>
    </tr>

<%
    while(rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("product_id") %></td>
        <td><%= rs.getString("product_name") %></td>
        <td><%= rs.getString("category") %></td>
        <td><%= rs.getString("description") %></td>
        <td><%= rs.getInt("stock_quantity") %></td>
        <td>$<%= rs.getDouble("price") %></td>
        <td><%= rs.getTimestamp("created_at") %></td>
        <td>
            <form action="edit_product.jsp" method="get" style="display:inline;">
                <input type="hidden" name="id" value="<%= rs.getInt("product_id") %>"/>
                <input type="submit" value="Edit" class="action-btn edit-btn"/>
            </form>
            <form action="delete_product.jsp" method="post" style="display:inline;">
                <input type="hidden" name="id" value="<%= rs.getInt("product_id") %>"/>
                <input type="submit" value="Delete" class="action-btn delete-btn" onclick="return confirm('Are you sure?');"/>
            </form>
        </td>
    </tr>
<%
    }
    rs.close();
    ps.close();
    con.close();
} catch(Exception e) {
%>
    <p style="color:red; text-align:center;">Error: <%= e.getMessage() %></p>
<%
}
%>

</table>
</body>
</html>


---

