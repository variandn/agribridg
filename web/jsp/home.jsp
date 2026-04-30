<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Fetch data from MongoDB
    List<Document> featuredProducts = new ArrayList<>();
    List<Document> dealProducts = new ArrayList<>();
    List<String> categories = new ArrayList<>();
    Map<String, Integer> categoryCounts = new LinkedHashMap<>();
    String query = request.getParameter("query");
    String filterCategory = request.getParameter("category");

    try {
        MongoDatabase db = MongoDBConnection.getDatabase();
        MongoCollection<Document> products = db.getCollection("products");

        // Get distinct categories with counts
        for (Document doc : products.find()) {
            String cat = doc.getString("category");
            if (cat != null && !cat.trim().isEmpty()) {
                categoryCounts.put(cat, categoryCounts.getOrDefault(cat, 0) + 1);
            }
        }
        categories.addAll(categoryCounts.keySet());

        // Featured products (search or filter or all)
        FindIterable<Document> results;
        if (query != null && !query.trim().isEmpty()) {
            results = products.find(Filters.or(
                Filters.regex("product_name", query, "i"),
                Filters.regex("category", query, "i")
            ));
        } else if (filterCategory != null && !filterCategory.trim().isEmpty()) {
            results = products.find(Filters.regex("category", filterCategory, "i"));
        } else {
            results = products.find();
        }
        results.sort(new Document("created_at", -1));
        for (Document doc : results) {
            featuredProducts.add(doc);
        }

        // Deal of the week - take last 4 products
        FindIterable<Document> deals = products.find().sort(new Document("created_at", 1)).limit(4);
        for (Document doc : deals) {
            dealProducts.add(doc);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    // Category emoji mapping
    Map<String, String> catIcons = new HashMap<>();
    catIcons.put("vegetables", "🥬");
    catIcons.put("fruits", "🍎");
    catIcons.put("grains", "🌾");
    catIcons.put("dairy", "🥛");
    catIcons.put("livestock", "🐄");
    catIcons.put("coffee", "☕");
    catIcons.put("beverages", "🧃");
    catIcons.put("spices", "🌶️");
    catIcons.put("seeds", "🌱");
    catIcons.put("poultry", "🐔");
    catIcons.put("fish", "🐟");

    String contextPath = request.getContextPath();

    // Check if user is logged in
    String userId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    boolean loggedIn = (userId != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="description" content="AgriBridge - Connecting farmers, buyers, and sellers. Buy and sell fresh agricultural products online."/>
    <title>AgriBridge | Farm Fresh Agricultural Marketplace</title>
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
                <a href="<%= contextPath %>/jsp/Login.jsp">My Account</a>
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
            <select name="category" id="search-category">
                <option value="">All Categories</option>
                <% for (String cat : categories) { %>
                    <option value="<%= HtmlUtils.escape(cat) %>" <%= (filterCategory != null && filterCategory.equalsIgnoreCase(cat)) ? "selected" : "" %>><%= HtmlUtils.escape(cat) %></option>
                <% } %>
            </select>
            <input type="text" name="query" placeholder="Search for products..." value="<%= (query != null) ? HtmlUtils.escape(query) : "" %>" />
            <button type="submit">🔍</button>
        </form>
        <div class="header-actions">
            <% if (loggedIn) { %>
                <a href="<%= contextPath %>/jsp/Log_out.jsp">
                    <span class="icon">👤</span>
                    <span><%= HtmlUtils.escape(username) %></span>
                </a>
            <% } else { %>
                <a href="<%= contextPath %>/jsp/Login.jsp">
                    <span class="icon">👤</span>
                    <span>Account</span>
                </a>
            <% } %>
        </div>
    </div>
</header>

<!-- NAV BAR -->
<nav class="nav-bar">
    <div class="container">
        <button class="mobile-menu-btn" onclick="document.querySelector('.nav-links').classList.toggle('active')">☰</button>
        <div class="nav-links">
            <a href="<%= contextPath %>/jsp/home.jsp" class="active">Home</a>
            <a href="<%= contextPath %>/jsp/home.jsp">All Products</a>
            <% if (loggedIn) { %>
                <a href="<%= contextPath %>/jsp/Log_out.jsp">Logout</a>
            <% } else { %>
                <a href="<%= contextPath %>/jsp/Login.jsp">Login</a>
                <a href="<%= contextPath %>/jsp/register.jsp">Register</a>
            <% } %>
        </div>
    </div>
</nav>

<% if (query == null && filterCategory == null) { %>
<!-- HERO SECTION -->
<section class="hero-section">
    <div class="container">
        <div class="hero-content">
            <span class="hero-badge">🌿 GET UPTO 20% OFF</span>
            <h1>Farm Fresh Organic <span class="highlight">Vegetables.</span></h1>
            <p>AgriBridge connects farmers, buyers, and sellers across the world. Browse fresh agricultural products directly from trusted sellers.</p>
            <a href="#products" class="btn-primary">Shop Collection →</a>
        </div>
        <div class="hero-image">
            <img src="<%= contextPath %>/assets/images/hero_banner.png" alt="Fresh organic vegetables and fruits" />
        </div>
    </div>
</section>

<!-- FEATURE BADGES -->
<section class="feature-badges">
    <div class="container">
        <div class="badge-card">
            <img src="<%= contextPath %>/assets/images/hero_banner.png" alt="Fresh produce" class="badge-icon"/>
            <div>
                <span class="badge-label">Fresh & Healthy</span>
                <h3>VEGETABLES</h3>
                <span class="badge-cta">Shop Now →</span>
            </div>
        </div>
        <div class="badge-card">
            <img src="<%= contextPath %>/assets/images/promo_organic.png" alt="Organic products" class="badge-icon"/>
            <div>
                <span class="badge-label">Farm Direct</span>
                <h3>ORGANIC PRODUCE</h3>
                <span class="badge-cta">Shop Now →</span>
            </div>
        </div>
        <div class="badge-card">
            <img src="<%= contextPath %>/assets/images/promo_vegetables.png" alt="Fresh fruits" class="badge-icon"/>
            <div>
                <span class="badge-label">Seasonal Pick</span>
                <h3>FRESH FRUITS</h3>
                <span class="badge-cta">Shop Now →</span>
            </div>
        </div>
    </div>
</section>

<!-- TOP CATEGORIES -->
<section class="top-categories">
    <div class="container">
        <div class="section-header">
            <h2>Top Categories</h2>
            <div class="section-nav">
                <button onclick="document.querySelector('.categories-grid').scrollBy({left:-160,behavior:'smooth'})">‹</button>
                <button onclick="document.querySelector('.categories-grid').scrollBy({left:160,behavior:'smooth'})">›</button>
            </div>
        </div>
        <div class="categories-grid">
            <% for (String cat : categories) {
                String icon = "🌿";
                for (Map.Entry<String, String> entry : catIcons.entrySet()) {
                    if (cat.toLowerCase().contains(entry.getKey())) {
                        icon = entry.getValue();
                        break;
                    }
                }
                int count = categoryCounts.getOrDefault(cat, 0);
            %>
            <a href="<%= contextPath %>/jsp/home.jsp?category=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>" class="category-card">
                <div class="category-icon"><%= icon %></div>
                <h4><%= HtmlUtils.escape(cat) %></h4>
                <span class="count"><%= count %> items</span>
            </a>
            <% } %>
        </div>
    </div>
</section>
<% } %>

<!-- FEATURED PRODUCTS -->
<section class="featured-products" id="products">
    <div class="container">
        <!-- Sidebar -->
        <aside class="sidebar">
            <span class="sidebar-label">Categories</span>
            <h3><%= (query != null) ? "Search Results" : "Featured Products" %></h3>
            <ul>
                <li><a href="<%= contextPath %>/jsp/home.jsp">All Products</a></li>
                <% for (String cat : categories) { %>
                <li><a href="<%= contextPath %>/jsp/home.jsp?category=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>"><%= HtmlUtils.escape(cat) %></a></li>
                <% } %>
            </ul>
        </aside>

        <!-- Products Main -->
        <div class="products-main">
            <div class="products-header">
                <h2>
                    <% if (query != null && !query.trim().isEmpty()) { %>
                        Search: "<%= HtmlUtils.escape(query) %>"
                    <% } else if (filterCategory != null && !filterCategory.trim().isEmpty()) { %>
                        <%= HtmlUtils.escape(filterCategory) %>
                    <% } else { %>
                        Featured Products
                    <% } %>
                </h2>
                <div class="tab-filters">
                    <button class="active">All</button>
                    <% int tabCount = 0;
                       for (String cat : categories) {
                           if (tabCount >= 3) break; %>
                        <a href="<%= contextPath %>/jsp/home.jsp?category=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>">
                            <button><%= HtmlUtils.escape(cat) %></button>
                        </a>
                    <% tabCount++; } %>
                </div>
            </div>

            <div class="products-grid">
                <% if (featuredProducts.isEmpty()) { %>
                    <p style="grid-column: 1/-1; text-align: center; color: #999; padding: 40px;">No products found. Check back later!</p>
                <% } %>
                <% for (Document doc : featuredProducts) {
                    String name = doc.getString("product_name");
                    Object priceObj = doc.get("price");
                    String price = (priceObj != null) ? priceObj.toString() : "0";
                    String productId = doc.getObjectId("_id").toHexString();
                    String category = doc.getString("category");
                    Object stockObj = doc.get("stock_quantity");
                    int stock = 0;
                    if (stockObj instanceof Number) stock = ((Number)stockObj).intValue();
                    String stockClass = stock > 10 ? "in-stock" : (stock > 0 ? "low-stock" : "");
                    String stockText = stock > 10 ? "In Stock" : (stock > 0 ? "Only " + stock + " left" : "Out of Stock");
                %>
                <div class="product-card">
                    <div class="product-img-wrapper">
                        <img src="<%= contextPath %>/getImage?id=<%= HtmlUtils.escape(productId) %>"
                             alt="<%= HtmlUtils.escape(name) %>" class="product-img"
                             onerror="this.onerror=null; this.src='<%= contextPath %>/assets/images/hero_banner.png';" />
                        <% if (category != null) { %>
                        <span class="category-tag"><%= HtmlUtils.escape(category) %></span>
                        <% } %>
                    </div>
                    <div class="card-body">
                        <h3 title="<%= HtmlUtils.escape(name) %>"><%= HtmlUtils.escape(name) %></h3>
                        <div class="product-price">
                            <span class="current">UGX <%= HtmlUtils.escape(price) %></span>
                        </div>
                        <div class="stock-info <%= stockClass %>"><%= stockText %></div>
                        <form action="<%= contextPath %>/jsp/details.jsp" method="get" style="margin:0;">
                            <input type="hidden" name="productId" value="<%= HtmlUtils.escape(productId) %>"/>
                            <button type="submit" class="btn-shop">Shop Now →</button>
                        </form>
                        <a href="<%= contextPath %>/jsp/product_sellers.jsp?productName=<%= java.net.URLEncoder.encode(name, "UTF-8") %>" class="btn-sellers">View All Sellers</a>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</section>

<% if (query == null && filterCategory == null) { %>
<!-- PROMO BANNERS -->
<section class="promo-banners">
    <div class="container">
        <div class="promo-card">
            <img src="<%= contextPath %>/assets/images/promo_vegetables.png" alt="Fresh vegetables promo"/>
            <div class="promo-overlay">
                <span class="promo-label">Enjoy a 10% discount</span>
                <h3>Fresh Vegetable</h3>
                <a href="<%= contextPath %>/jsp/home.jsp#products" class="btn-promo">Shop Now →</a>
            </div>
        </div>
        <div class="promo-card">
            <img src="<%= contextPath %>/assets/images/promo_organic.png" alt="Organic products promo"/>
            <div class="promo-overlay">
                <span class="promo-label">Save up to 15% off</span>
                <h3>All Tasted Organic &amp; Fresh Products</h3>
                <a href="<%= contextPath %>/jsp/home.jsp#products" class="btn-promo">Shop Now →</a>
            </div>
        </div>
    </div>
</section>

<!-- DEAL OF THE WEEK -->
<section class="deal-section">
    <div class="container">
        <div class="section-header">
            <span class="deal-label">Best Deal</span>
            <h2>Deal Of The Week</h2>
        </div>
        <div class="deal-grid">
            <% for (Document doc : dealProducts) {
                String name = doc.getString("product_name");
                Object priceObj = doc.get("price");
                String price = (priceObj != null) ? priceObj.toString() : "0";
                String productId = doc.getObjectId("_id").toHexString();
            %>
            <div class="deal-card">
                <img src="<%= contextPath %>/getImage?id=<%= HtmlUtils.escape(productId) %>"
                     alt="<%= HtmlUtils.escape(name) %>" class="deal-img"
                     onerror="this.onerror=null; this.src='<%= contextPath %>/assets/images/hero_banner.png';" />
                <h4><%= HtmlUtils.escape(name) %></h4>
                <div class="deal-price">
                    <span class="current" style="font-weight:700;color:#1e8449;">UGX <%= HtmlUtils.escape(price) %></span>
                </div>
                <form action="<%= contextPath %>/jsp/details.jsp" method="get">
                    <input type="hidden" name="productId" value="<%= HtmlUtils.escape(productId) %>"/>
                    <button type="submit" class="btn-shop" style="width:auto;padding:8px 24px;">Shop Now →</button>
                </form>
            </div>
            <% } %>
        </div>
    </div>
</section>
<% } %>

<!-- FOOTER -->
<footer class="site-footer">
    <div class="container">
        <div class="footer-col">
            <h4>AgriBridge</h4>
            <p>Connecting farmers, buyers, and sellers across the world. Fresh agricultural products at your fingertips.</p>
        </div>
        <div class="footer-col">
            <h4>Quick Links</h4>
            <ul>
                <li><a href="<%= contextPath %>/jsp/home.jsp">Home</a></li>
                <li><a href="<%= contextPath %>/jsp/home.jsp#products">All Products</a></li>
                <li><a href="<%= contextPath %>/jsp/Login.jsp">Login</a></li>
                <li><a href="<%= contextPath %>/jsp/register.jsp">Register</a></li>
            </ul>
        </div>
        <div class="footer-col">
            <h4>Categories</h4>
            <ul>
                <% int footCatCount = 0;
                   for (String cat : categories) {
                       if (footCatCount >= 5) break; %>
                <li><a href="<%= contextPath %>/jsp/home.jsp?category=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>"><%= HtmlUtils.escape(cat) %></a></li>
                <% footCatCount++; } %>
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