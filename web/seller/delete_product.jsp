<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="auth_check.jsp" %>
<html>
<head>
    <title>Delete Product</title>
</head>
<body>
<%
    String id = request.getParameter("id");

    // Only allow POST for deletion (prevent accidental GET deletions)
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect("manage_product.jsp");
        return;
    }

    try {
        MongoDatabase db = MongoDBConnection.getDatabase();
        MongoCollection<Document> products = db.getCollection("products");

        // Delete only if product belongs to the current seller (authorization check)
        long deleted = products.deleteOne(
            Filters.and(
                Filters.eq("_id", new ObjectId(id)),
                Filters.eq("seller_id", sellerId)
            )
        ).getDeletedCount();

        if (deleted > 0) {
            response.sendRedirect("manage_product.jsp");
        } else {
%>
            <p style="color:red; text-align:center;">Product not found or you don't have permission to delete it.</p>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
%>
        <p style="color:red; text-align:center;">Error deleting product. Please try again later.</p>
<%
    }
%>
</body>
</html>
