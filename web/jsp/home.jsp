<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AgriBridge | Home</title>
    <!--<link rel="stylesheet" href="../css/home.css" />-->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
    

</head>
<body>

<header>
    <div class="logo">AgriBridge</div>
    <form action="<%= request.getContextPath() %>/jsp/home.jsp" method="get" class="search-bar">
        <input type="text" name="query" placeholder="Search for products..." />
        <button type="submit">🔍</button>
    </form>
    <nav>
    <a href="${pageContext.request.contextPath}/jsp/Login.jsp">Login</a>
    <a href="${pageContext.request.contextPath}/jsp/register.jsp">Register</a>
       <!-- <a href="register.jsp">Register</a>
        <a href="Login.jsp">Login</a>-->
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
            Connection conn = null;
            PreparedStatement pst = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");

                String sql = "SELECT * FROM products";
                if (query != null && !query.trim().isEmpty()) {
                    sql += " WHERE product_name LIKE ? OR category LIKE ?";
                    pst = conn.prepareStatement(sql);
                    pst.setString(1, "%" + query + "%");
                    pst.setString(2, "%" + query + "%");
                } else {
                    pst = conn.prepareStatement(sql);
                }

                rs = pst.executeQuery();

                while (rs.next()) {
                    String name = rs.getString("product_name");
                    String price = rs.getString("price");
                    String productId = rs.getString("product_id"); // Unique ID
        %>
       <!-- <div class="product">
            <!-- Image URL Debugging: View the generated image URL -->
            <%--<p>Image URL: <%= request.getContextPath() %>/getImage?id=<%= productId %></p>--%>
           <!-- <img src="<%= request.getContextPath() %>/getImage?id=<%= productId %>"
                 alt="<%= name %>"
                 style="width: 100%; height: 300px; object-fit: cover;"
                 onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/assets/default-product.png';" />
            <h3><%= name %></h3>
            <p>UGX <%= price %></p>-->
                  
    <div class="product-container">
    <div class="product-item">
        <img src="<%= request.getContextPath() %>/getImage?id=<%= productId %>"
             alt="<%= name %>"
             onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/assets/default-product.png';" />
        <h3><%= name %></h3>
        <p>UGX <%= price %></p>
    </div>

    <!--form action="<%= request.getContextPath() %>/jsp/product_details.jsp" method="get"-->
        <form action="<%= request.getContextPath() %>/jsp/details.jsp" method="get">
    <input type="hidden" name="productId" value="<%= productId %>"/>
    <button type="submit">View Details</button>
</form>

        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<p>Error loading products: " + e.getMessage() + "</p>");
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (pst != null) pst.close();
                    if (conn != null) conn.close();
                } catch (Exception ex) {
                    out.println("<p>Cleanup error: " + ex.getMessage() + "</p>");
                }
            }
        %>
    </div>
</section>

<footer>
    <p>&copy; 2025 AgriBridge. All rights reserved.</p>
</footer>

</body>
</html>
