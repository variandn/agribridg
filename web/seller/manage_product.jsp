<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="auth_check.jsp" %>
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
    try {
        MongoDatabase db = MongoDBConnection.getDatabase();
        MongoCollection<Document> products = db.getCollection("products");

        FindIterable<Document> results = products.find(Filters.eq("seller_id", sellerId));
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
    for (Document doc : results) {
        String productId = doc.getObjectId("_id").toHexString();
%>
    <tr>
        <td><%= HtmlUtils.escape(productId.substring(productId.length() - 6)) %></td>
        <td><%= HtmlUtils.escape(doc.getString("product_name")) %></td>
        <td><%= HtmlUtils.escape(doc.getString("category")) %></td>
        <td><%= HtmlUtils.escape(doc.getString("description")) %></td>
        <td><%= doc.getInteger("stock_quantity", 0) %></td>
        <td>$<%= doc.get("price") %></td>
        <td><%= doc.getDate("created_at") %></td>
        <td>
            <form action="edit_product.jsp" method="get" style="display:inline;">
                <input type="hidden" name="id" value="<%= HtmlUtils.escape(productId) %>"/>
                <input type="submit" value="Edit" class="action-btn edit-btn"/>
            </form>
            <form action="delete_product.jsp" method="post" style="display:inline;">
                <input type="hidden" name="id" value="<%= HtmlUtils.escape(productId) %>"/>
                <input type="submit" value="Delete" class="action-btn delete-btn" onclick="return confirm('Are you sure?');"/>
            </form>
        </td>
    </tr>
<%
    }
} catch(Exception e) {
    e.printStackTrace();
%>
    <p style="color:red; text-align:center;">Error loading products. Please try again later.</p>
<%
}
%>

</table>
</body>
</html>
