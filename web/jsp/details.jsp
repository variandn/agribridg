<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
    String userIdSess = (String) session.getAttribute("userId");
    String usernameSess = (String) session.getAttribute("username");
    boolean loggedIn = (userIdSess != null);

    List<String> categories = new ArrayList<>();
    try {
        MongoDatabase db0 = MongoDBConnection.getDatabase();
        MongoCollection<Document> prods0 = db0.getCollection("products");
        Set<String> catSet = new LinkedHashSet<>();
        for (Document d : prods0.find()) {
            String c = d.getString("category");
            if (c != null && !c.trim().isEmpty()) catSet.add(c);
        }
        categories.addAll(catSet);
    } catch (Exception ex) { /* ignore */ }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AgriBridge | Product Details</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/home.css">
</head>
<body>

<!-- TOP BAR -->
<div class="top-bar">
    <div class="container">
        <div class="top-bar-left">
            <span>📞 +256 700 000 000</span>
            <span>✉️ info@agribridge.com</span>
        </div>
        <div>
            <% if (loggedIn) { %>
                <a href="<%= contextPath %>/jsp/Log_out.jsp">Logout</a>
            <% } else { %>
                <a href="<%= contextPath %>/jsp/Login.jsp">Login</a>
                <a href="<%= contextPath %>/jsp/register.jsp">Register</a>
            <% } %>
        </div>
    </div>
</div>

<!-- MAIN HEADER -->
<header class="main-header">
    <div class="container">
        <a href="<%= contextPath %>/jsp/home.jsp" class="logo">AGRI<span>BRIDGE</span></a>
        <form action="<%= contextPath %>/jsp/home.jsp" method="get" class="search-container">
            <select name="category">
                <option value="">All Categories</option>
                <% for (String cat : categories) { %>
                    <option value="<%= HtmlUtils.escape(cat) %>"><%= HtmlUtils.escape(cat) %></option>
                <% } %>
            </select>
            <input type="text" name="query" placeholder="Search for products..." />
            <button type="submit">🔍</button>
        </form>
        <div class="header-actions">
            <% if (loggedIn) { %>
                <a href="<%= contextPath %>/jsp/Log_out.jsp"><span class="icon">👤</span><span><%= HtmlUtils.escape(usernameSess) %></span></a>
            <% } else { %>
                <a href="<%= contextPath %>/jsp/Login.jsp"><span class="icon">👤</span><span>Account</span></a>
            <% } %>
        </div>
    </div>
</header>

<!-- NAV BAR -->
<nav class="nav-bar">
    <div class="container">
        <button class="mobile-menu-btn" onclick="document.querySelector('.nav-links').classList.toggle('active')">☰</button>
        <div class="nav-links">
            <a href="<%= contextPath %>/jsp/home.jsp">Home</a>
            <a href="<%= contextPath %>/jsp/home.jsp#products">All Products</a>
            <% if (loggedIn) { %>
                <a href="<%= contextPath %>/jsp/Log_out.jsp">Logout</a>
            <% } else { %>
                <a href="<%= contextPath %>/jsp/Login.jsp">Login</a>
            <% } %>
        </div>
    </div>
</nav>

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
            String sellerId = doc.getString("seller_id");
%>

<section style="max-width:900px; margin:30px auto; padding:0 20px;">
    <a href="<%= contextPath %>/jsp/home.jsp" style="color: var(--primary); font-weight: 500; display: inline-flex; align-items: center; gap: 6px; margin-bottom: 20px;">← Back to Home</a>

    <div class="product-details">
        <h1><%= HtmlUtils.escape(name) %></h1>
        <img src="<%= contextPath %>/getImage?id=<%= HtmlUtils.escape(productId) %>"
             alt="<%= HtmlUtils.escape(name) %>"
             onerror="this.onerror=null; this.src='<%= contextPath %>/assets/images/hero_banner.png';" />
        <div class="product-info">
            <p><strong>Price:</strong> <span style="color:var(--primary-dark); font-size:1.3rem; font-weight:700;">UGX <%= HtmlUtils.escape(price) %></span></p>
            <p><strong>Description:</strong> <%= HtmlUtils.escape(description) %></p>
            <p><strong>Category:</strong> <%= HtmlUtils.escape(category) %></p>
            <p><strong>Stock Quantity:</strong> <%= HtmlUtils.escape(stockQuantity) %></p>
        </div>

        <div style="display:flex; gap:12px; margin-top:24px; flex-wrap:wrap; justify-content:center;">
            <form method="post" action="ContactSupplier.jsp" class="contact-supplier-form" style="margin:0;">
                <input type="hidden" name="supplierId" value="<%= HtmlUtils.escape(sellerId) %>" />
                <input type="hidden" name="productId" value="<%= HtmlUtils.escape(productId) %>" />
                <button type="submit">Contact Supplier</button>
            </form>
            <a href="<%= contextPath %>/jsp/product_sellers.jsp?productName=<%= java.net.URLEncoder.encode(name, "UTF-8") %>" class="btn-sellers" style="padding:12px 28px;">View All Sellers</a>
        </div>
    </div>
</section>

<%
        } else {
            out.println("<section style='max-width:900px;margin:40px auto;text-align:center;padding:60px 20px;'><p style='font-size:1.2rem;color:#999;'>Product not found.</p><a href='" + contextPath + "/jsp/home.jsp' class='btn-primary' style='display:inline-flex;margin-top:16px;'>Browse Products</a></section>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<section style='max-width:900px;margin:40px auto;text-align:center;padding:60px 20px;'><p style='color:#dc3545;'>Error loading product. Please try again later.</p></section>");
    }
%>

<!-- FOOTER -->
<footer class="site-footer">
    <div class="container">
        <div class="footer-col">
            <h4>AgriBridge</h4>
            <p>Connecting farmers, buyers, and sellers across the world.</p>
        </div>
        <div class="footer-col">
            <h4>Quick Links</h4>
            <ul>
                <li><a href="<%= contextPath %>/jsp/home.jsp">Home</a></li>
                <li><a href="<%= contextPath %>/jsp/Login.jsp">Login</a></li>
                <li><a href="<%= contextPath %>/jsp/register.jsp">Register</a></li>
            </ul>
        </div>
        <div class="footer-col">
            <h4>Categories</h4>
            <ul>
                <% int fc = 0; for (String cat : categories) { if (fc >= 5) break; %>
                <li><a href="<%= contextPath %>/jsp/home.jsp?category=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>"><%= HtmlUtils.escape(cat) %></a></li>
                <% fc++; } %>
            </ul>
        </div>
        <div class="footer-col">
            <h4>Contact Us</h4>
            <ul>
                <li>📞 +256 700 000 000</li>
                <li>✉️ info@agribridge.com</li>
                <li>📍 Kampala, Uganda</li>
            </ul>
        </div>
    </div>
    <div class="footer-bottom">
        <p>&copy; 2025 AgriBridge. All rights reserved.</p>
    </div>
</footer>

</body>
</html>
