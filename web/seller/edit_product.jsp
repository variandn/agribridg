<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="auth_check.jsp" %>
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
    String id = request.getParameter("id");
    String name = "", category = "", desc = "";
    int qty = 0;
    double price = 0;

    if (request.getMethod().equalsIgnoreCase("post")) {
        // Handle form submission - update product
        name = request.getParameter("product_name");
        category = request.getParameter("category");
        desc = request.getParameter("description");
        qty = Integer.parseInt(request.getParameter("quantity"));
        price = Double.parseDouble(request.getParameter("price"));

        try {
            MongoDatabase db = MongoDBConnection.getDatabase();
            MongoCollection<Document> products = db.getCollection("products");

            // Only update if the product belongs to this seller
            long modified = products.updateOne(
                Filters.and(
                    Filters.eq("_id", new ObjectId(id)),
                    Filters.eq("seller_id", sellerId)
                ),
                Updates.combine(
                    Updates.set("product_name", name),
                    Updates.set("category", category),
                    Updates.set("description", desc),
                    Updates.set("stock_quantity", qty),
                    Updates.set("price", price)
                )
            ).getModifiedCount();

            if (modified > 0) {
%>
            <p style="color:green; text-align:center;">Product updated successfully.</p>
<%
            } else {
%>
            <p style="color:red; text-align:center;">Product not found or you don't have permission to edit it.</p>
<%
            }
        } catch(Exception e) {
            e.printStackTrace();
%>
            <p style="color:red; text-align:center;">Error updating product. Please try again later.</p>
<%
        }
    } else {
        // Load product data for editing — verify ownership
        try {
            MongoDatabase db = MongoDBConnection.getDatabase();
            MongoCollection<Document> products = db.getCollection("products");

            Document doc = products.find(Filters.and(
                Filters.eq("_id", new ObjectId(id)),
                Filters.eq("seller_id", sellerId)
            )).first();

            if (doc != null) {
                name = doc.getString("product_name") != null ? doc.getString("product_name") : "";
                category = doc.getString("category") != null ? doc.getString("category") : "";
                desc = doc.getString("description") != null ? doc.getString("description") : "";
                qty = doc.getInteger("stock_quantity", 0);
                Object priceObj = doc.get("price");
                price = (priceObj != null) ? Double.parseDouble(priceObj.toString()) : 0;
            } else {
%>
            <p style="color:red; text-align:center;">Product not found or you don't have permission to edit it.</p>
<%
            }
        } catch(Exception e) {
            e.printStackTrace();
%>
            <p style="color:red; text-align:center;">Error loading product. Please try again later.</p>
<%
        }
    }
%>

    <form method="post" action="edit_product.jsp?id=<%= HtmlUtils.escape(id) %>">
        <label>Product Name:</label>
        <input type="text" name="product_name" value="<%= HtmlUtils.escape(name) %>" required>

        <label>Category:</label>
        <select name="category" required>
            <option value="Fruits" <%= category.equals("Fruits") ? "selected" : "" %>>Fruits</option>
            <option value="Vegetables" <%= category.equals("Vegetables") ? "selected" : "" %>>Vegetables</option>
            <option value="Grains" <%= category.equals("Grains") ? "selected" : "" %>>Grains</option>
            <option value="Dairy" <%= category.equals("Dairy") ? "selected" : "" %>>Dairy</option>
            <option value="Others" <%= category.equals("Others") ? "selected" : "" %>>Others</option>
        </select>

        <label>Description:</label>
        <textarea name="description" required><%= HtmlUtils.escape(desc) %></textarea>

        <label>Quantity:</label>
        <input type="number" name="quantity" value="<%= qty %>" min="0" required>

        <label>Price:</label>
        <input type="number" step="0.01" name="price" value="<%= price %>" min="0" required>

        <input type="submit" value="Update Product">
    </form>
</div>
</body>
</html>
