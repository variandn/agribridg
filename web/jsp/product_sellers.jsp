<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String productName = request.getParameter("productName");
    String contextPath = request.getContextPath();
    List<Document> sellers = new ArrayList<>();
    String userId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    boolean loggedIn = (userId != null);

    // Fetch all categories for nav
    List<String> categories = new ArrayList<>();
    try {
        MongoDatabase db = MongoDBConnection.getDatabase();
        MongoCollection<Document> products = db.getCollection("products");

        // Get distinct categories
        Set<String> catSet = new LinkedHashSet<>();
        for (Document d : products.find()) {
            String c = d.getString("category");
            if (c != null && !c.trim().isEmpty()) catSet.add(c);
        }
        categories.addAll(catSet);

        // Find all products with this name from different sellers
        if (productName != null && !productName.trim().isEmpty()) {
            FindIterable<Document> results = products.find(
                Filters.regex("product_name", productName, "i")
            );
            for (Document doc : results) {
                // Get seller info
                String sellerId = doc.getString("seller_id");
                if (sellerId != null) {
                    MongoCollection<Document> users = db.getCollection("users");
                    Document seller = null;
                    try {
                        seller = users.find(Filters.eq("_id", new ObjectId(sellerId))).first();
                    } catch (Exception ex) { /* ignore invalid ids */ }
                    if (seller != null) {
                        doc.append("seller_username", seller.getString("user_name"));
                        doc.append("seller_firstname", seller.getString("first_name"));
                        doc.append("seller_lastname", seller.getString("last_name"));
                        doc.append("seller_address", seller.getString("address"));
                        doc.append("seller_country", seller.getString("country"));
                        doc.append("seller_phone", seller.getString("phone"));
                    }
                }
                sellers.add(doc);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="description" content="Compare sellers for <%= (productName != null) ? HtmlUtils.escape(productName) : "agricultural products" %> on AgriBridge"/>
    <title>AgriBridge | Sellers for <%= (productName != null) ? HtmlUtils.escape(productName) : "Product" %></title>
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
                <span>Welcome, <%= HtmlUtils.escape(username) %></span>
            <% } %>
        </div>
    </div>
</div>

<!-- MAIN HEADER -->
<header class="main-header">
    <div class="container">
        <a href="<%= contextPath %>/jsp/home.jsp" class="logo">AGRI<span>BRIDGE</span></a>
        <form action="<%= contextPath %>/jsp/home.jsp" method="get" class="search-container">
            <select name="category" id="search-category">
                <option value="">All Categories</option>
                <% for (String cat : categories) { %>
                    <option value="<%= HtmlUtils.escape(cat) %>"><%= HtmlUtils.escape(cat) %></option>
                <% } %>
            </select>
            <input type="text" name="query" placeholder="Search for products..." />
            <button type="submit">🔍</button>
        </form>
        <div class="header-actions">
            <a href="<%= loggedIn ? contextPath + "/jsp/Log_out.jsp" : contextPath + "/jsp/Login.jsp" %>">
                <span class="icon">👤</span>
            </a>
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

<!-- SELLERS PAGE CONTENT -->
<section class="sellers-page">
    <div class="container">
        <a href="<%= contextPath %>/jsp/home.jsp" style="color: var(--primary); font-weight: 500; display: inline-flex; align-items: center; gap: 6px; margin-bottom: 20px;">← Back to Home</a>
        <h1>Sellers for "<%= (productName != null) ? HtmlUtils.escape(productName) : "Product" %>"</h1>
        <p class="subtitle">Compare prices and stock from different sellers</p>

        <% if (sellers.isEmpty()) { %>
            <div style="text-align:center; padding:60px 20px; color:#999;">
                <p style="font-size:1.2rem; margin-bottom:8px;">No sellers found for this product.</p>
                <a href="<%= contextPath %>/jsp/home.jsp" class="btn-primary" style="display:inline-flex; margin-top:16px;">Browse Products</a>
            </div>
        <% } else { %>
        <div class="sellers-grid">
            <% for (Document doc : sellers) {
                String name = doc.getString("product_name");
                Object priceObj = doc.get("price");
                String price = (priceObj != null) ? priceObj.toString() : "0";
                String productId = doc.getObjectId("_id").toHexString();
                Object stockObj = doc.get("stock_quantity");
                int stock = 0;
                if (stockObj instanceof Number) stock = ((Number)stockObj).intValue();
                String stockText = stock > 10 ? "In Stock (" + stock + ")" : (stock > 0 ? "Low Stock (" + stock + ")" : "Out of Stock");
                String stockColor = stock > 10 ? "var(--primary)" : (stock > 0 ? "var(--accent-orange)" : "#dc3545");

                String sellerName = doc.getString("seller_username");
                String sellerFirst = doc.getString("seller_firstname");
                String sellerLast = doc.getString("seller_lastname");
                String sellerAddr = doc.getString("seller_address");
                String sellerCountry = doc.getString("seller_country");
                String sellerPhone = doc.getString("seller_phone");
                String sellerId = doc.getString("seller_id");

                String displayName = "";
                if (sellerFirst != null) displayName += sellerFirst;
                if (sellerLast != null) displayName += " " + sellerLast;
                if (displayName.trim().isEmpty() && sellerName != null) displayName = sellerName;

                String location = "";
                if (sellerAddr != null) location += sellerAddr;
                if (sellerCountry != null) location += (location.isEmpty() ? "" : ", ") + sellerCountry;
            %>
            <div class="seller-card">
                <img src="<%= contextPath %>/getImage?id=<%= HtmlUtils.escape(productId) %>"
                     alt="<%= HtmlUtils.escape(name) %>" class="seller-product-img"
                     onerror="this.onerror=null; this.src='<%= contextPath %>/assets/images/hero_banner.png';" />
                <div class="seller-body">
                    <div class="seller-name">👤 <%= HtmlUtils.escape(displayName) %></div>
                    <div class="seller-location">📍 <%= location.isEmpty() ? "Location not specified" : HtmlUtils.escape(location) %></div>
                    <% if (sellerPhone != null) { %>
                        <div style="font-size:0.85rem; color: var(--text-muted); margin-bottom:12px;">📞 <%= HtmlUtils.escape(sellerPhone) %></div>
                    <% } %>
                    <div class="seller-details">
                        <span>Price: <strong style="color:var(--primary-dark);">UGX <%= HtmlUtils.escape(price) %></strong></span>
                        <span style="color:<%= stockColor %>;"><%= stockText %></span>
                    </div>
                    <div style="display:flex; gap:8px; flex-wrap:wrap;">
                        <form action="<%= contextPath %>/jsp/details.jsp" method="get" style="flex:1;">
                            <input type="hidden" name="productId" value="<%= HtmlUtils.escape(productId) %>"/>
                            <button type="submit" class="btn-shop">View Details</button>
                        </form>
                        <form action="<%= contextPath %>/jsp/ContactSupplier.jsp" method="post" style="flex:1;">
                            <input type="hidden" name="supplierId" value="<%= HtmlUtils.escape(sellerId) %>" />
                            <input type="hidden" name="productId" value="<%= HtmlUtils.escape(productId) %>" />
                            <button type="submit" class="btn-sellers" style="border-color:var(--primary);color:var(--primary);">Contact Seller</button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</section>

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
