<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
    
    <!-- Navigation Bar -->
    <nav>
        <ul>
            <li><a href="home.jsp">Home</a></li>
            <li><a href="cart.jsp">Cart</a></li>
            <li><a href="about.jsp">About Us</a></li>
            <li><a href="contact.jsp">Contact Us</a></li>
            <c:choose>
                <c:when test="${empty loggedInUser}">
               <li> <a href="${pageContext.request.contextPath}/jsp/Login.jsp">Login</a></li>
                    <!--<li><a href="login.jsp">Login</a></li>-->
                </c:when>
                <c:otherwise>
                    <li><a href="logout.jsp">Logout</a></li>
                </c:otherwise>
            </c:choose>
        </ul>
    </nav>

<section class="products">
    <!--<h2><%= request.getParameter("query") != null ? "Search Results" : "Featured Products" %></h2>-->
    <div class="product-grid">
        <%
            String id = request.getParameter("productId");
            //String query = request.getParameter("query");
            Connection conn = null;
            PreparedStatement pst = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");

                String sql = "SELECT * FROM products WHERE product_id = ?";
                    pst = conn.prepareStatement(sql);
                    pst.setString(1, id);
                  
                rs = pst.executeQuery();

                if (rs.next()) {
                    String name = rs.getString("product_name");
                    String price = rs.getString("price");
                    String productId = rs.getString("product_id"); // Unique ID
                    String description = rs.getString("description");
                    String category = rs.getString("category");
                    String stock_quantity = rs.getString("stock_quantity");
        %>
        
    <!-- Product Details Section -->
    <div class="product-details">
        <h1><%= name %></h1>
         <img src="<%= request.getContextPath() %>/getImage?id=<%= productId %>"
             alt="<%= name %>"
             onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/assets/default-product.png';" />
        <div class="product-info">
            <img src="${pageContext.request.contextPath}/agribridg/getImage?id=${product.id}" alt="${product.name}" />
            
            <p><strong>Price:</strong> UGX <%= price %></p>
            <p><strong>Description:</strong> <%= description %></p>
            <p><strong>Category:</strong> <%= category %></p>
             <p><strong>stock_quantity:</strong> <%= stock_quantity %></p>
        </div>
        
         <!-- Contact Supplier Button -->
<form method="post" action="ContactSupplier.jsp" class="contact-supplier-form">
    <input type="hidden" name="supplierId" value="<%= id %>" />
    <input type="hidden" name="productId" value="<%= productId %>" />
    <button type="submit">Contact Supplier</button>
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
