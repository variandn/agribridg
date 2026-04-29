<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AgriBridge | Home</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">

</head>
<body>

<header>
    <div class="logo">AgriBridge</div>
    <form action="<%= request.getContextPath() %>/jsp/home.jsp" method="get" class="search-bar">
        <input type="text" name="query" placeholder="Search for products..." />
        <button type="submit">&#x1F50D;</button>
    </form>
    <nav>
    <a href="${pageContext.request.contextPath}/jsp/Login.jsp">Login</a>
    <a href="${pageContext.request.contextPath}/jsp/register.jsp">Register</a>
    </nav>
</header>

<section class="hero">
    <h1>Buy & Sell Agricultural Products Easily</h1>
    <p>Connecting Farmers, Buyers, and Sellers across the world</p>
</section>

<section class="products">
    <h2><%= request.getParameter("query") != null ? "Search Results" : "Featured Products" %></h2>
    <div class="product-grid">
        <%
            String query = request.getParameter("query");

            try {
                MongoDatabase db = MongoDBConnection.getDatabase();
                MongoCollection<Document> products = db.getCollection("products");

                FindIterable<Document> results;

                if (query != null && !query.trim().isEmpty()) {
                    results = products.find(Filters.or(
                        Filters.regex("product_name", query, "i"),
                        Filters.regex("category", query, "i")
                    ));
                } else {
                    results = products.find();
                }

                for (Document doc : results) {
                    String name = doc.getString("product_name");
                    Object priceObj = doc.get("price");
                    String price = (priceObj != null) ? priceObj.toString() : "0";
                    String productId = doc.getObjectId("_id").toHexString();
        %>

    <div class="product-container">
    <div class="product-item">
        <img src="<%= request.getContextPath() %>/getImage?id=<%= HtmlUtils.escape(productId) %>"
             alt="<%= HtmlUtils.escape(name) %>"
             onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/assets/default-product.png';" />
        <h3><%= HtmlUtils.escape(name) %></h3>
        <p>UGX <%= HtmlUtils.escape(price) %></p>
    </div>

        <form action="<%= request.getContextPath() %>/jsp/details.jsp" method="get">
    <input type="hidden" name="productId" value="<%= HtmlUtils.escape(productId) %>"/>
    <button type="submit">View Details</button>
</form>

        </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p>Error loading products. Please try again later.</p>");
            }
        %>
    </div>
</section>

<footer>
    <p>&copy; 2025 AgriBridge. All rights reserved.</p>
</footer>

</body>
</html>