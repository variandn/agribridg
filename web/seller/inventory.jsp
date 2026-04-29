<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="auth_check.jsp" %>
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
    try {
        MongoDatabase db = MongoDBConnection.getDatabase();
        MongoCollection<Document> products = db.getCollection("products");

        FindIterable<Document> results = products.find(Filters.eq("seller_id", sellerId));
%>

<table>
    <tr>
        <th>Product</th>
        <th>Quantity in Stock</th>
        <th>Status</th>
    </tr>

<%
    for (Document doc : results) {
        String productName = doc.getString("product_name");
        int quantity = doc.getInteger("stock_quantity", 0);
        boolean isLow = quantity < 10;
%>
    <tr>
        <td><%= HtmlUtils.escape(productName) %></td>
        <td><%= quantity %></td>
        <td class="<%= isLow ? "low-stock" : "ok-stock" %>">
            <%= isLow ? "Low Stock" : "In Stock" %>
        </td>
    </tr>
<%
    }
} catch(Exception e) {
    e.printStackTrace();
%>
    <p style="color:red; text-align:center;">Error loading inventory. Please try again later.</p>
<%
}
%>

</table>
</body>
</html>
