<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="navbar.jsp" %>
<html>
<head>
    <title>Inventory Management</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #fefefe;
        }
        h2 {
            text-align: center;
            margin-top: 30px;
            color: #2e8b57;
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
            background-color: #2e8b57;
            color: white;
        }
        .low-stock {
            color: red;
            font-weight: bold;
        }
        .ok-stock {
            color: green;
        }
    </style>
</head>
<body>

<h2>Inventory Overview</h2>

<%
    int sellerId = 1; // Replace with session seller ID

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");

        PreparedStatement ps = con.prepareStatement("SELECT product_name, quantity FROM products WHERE seller_id = ?");
        ps.setInt(1, sellerId);
        ResultSet rs = ps.executeQuery();
%>

<table>
    <tr>
        <th>Product</th>
        <th>Quantity in Stock</th>
        <th>Status</th>
    </tr>

<%
    while(rs.next()) {
        String productName = rs.getString("product_name");
        int quantity = rs.getInt("quantity");
        boolean isLow = quantity < 10;
%>
    <tr>
        <td><%= productName %></td>
        <td><%= quantity %></td>
        <td class="<%= isLow ? "low-stock" : "ok-stock" %>">
            <%= isLow ? "Low Stock" : "In Stock" %>
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
