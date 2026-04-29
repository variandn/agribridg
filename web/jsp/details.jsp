<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AgriBridge | Product Details</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
</head>
<body>
    
    <!-- Navigation Bar -->
    <nav>
        <ul>
            <li><a href="home.jsp">Home</a></li>
            <li><a href="cart.jsp">Cart</a></li>
            <li><a href="about.jsp">About Us</a></li>
            <li><a href="contact.jsp">Contact Us</a></li>
            <% if (session.getAttribute("userId") == null) { %>
                <li><a href="<%= request.getContextPath() %>/jsp/Login.jsp">Login</a></li>
            <% } else { %>
                <li><a href="<%= request.getContextPath() %>/jsp/Log_out.jsp">Logout</a></li>
            <% } %>
        </ul>
    </nav>

<section class="products">
    <div class="product-grid">
        <%
            String id = request.getParameter("productId");

            try {
                MongoDatabase db = MongoDBConnection.getDatabase();
                MongoCollection<Document> products = db.getCollection("products");

                Document doc = null;
                if (id != null && !id.isEmpty()) {
                    doc = products.find(Filters.eq("_id", new ObjectId(id))).first();
                }

                if (doc != null) {
                    String name = doc.getString("product_name");
                    Object priceObj = doc.get("price");
                    String price = (priceObj != null) ? priceObj.toString() : "0";
                    String productId = doc.getObjectId("_id").toHexString();
                    String description = doc.getString("description");
                    String category = doc.getString("category");
                    Object stockObj = doc.get("stock_quantity");
                    String stockQuantity = (stockObj != null) ? stockObj.toString() : "0";
        %>
        
    <!-- Product Details Section -->
    <div class="product-details">
        <h1><%= HtmlUtils.escape(name) %></h1>
         <img src="<%= request.getContextPath() %>/getImage?id=<%= HtmlUtils.escape(productId) %>"
             alt="<%= HtmlUtils.escape(name) %>"
             onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/assets/default-product.png';" />
        <div class="product-info">
            <p><strong>Price:</strong> UGX <%= HtmlUtils.escape(price) %></p>
            <p><strong>Description:</strong> <%= HtmlUtils.escape(description) %></p>
            <p><strong>Category:</strong> <%= HtmlUtils.escape(category) %></p>
             <p><strong>Stock Quantity:</strong> <%= HtmlUtils.escape(stockQuantity) %></p>
        </div>
        
         <!-- Contact Supplier Button -->
<form method="post" action="ContactSupplier.jsp" class="contact-supplier-form">
    <input type="hidden" name="supplierId" value="<%= HtmlUtils.escape(doc.getString("seller_id")) %>" />
    <input type="hidden" name="productId" value="<%= HtmlUtils.escape(productId) %>" />
    <button type="submit">Contact Supplier</button>
</form>
    </div>

        <%
                } else {
                    out.println("<p>Product not found.</p>");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p>Error loading product. Please try again later.</p>");
            }
        %>
    </div>
</section>

<footer>
    <p>&copy; 2025 AgriBridge. All rights reserved.</p>
</footer>

</body>
</html>
