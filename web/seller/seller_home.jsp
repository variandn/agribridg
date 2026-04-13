<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String sessionToken = (String) session.getAttribute("sessionToken");
    String userId = (String) session.getAttribute("userId");
    boolean sessionValid = false;

    if (sessionToken != null && userId != null) {
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");
            PreparedStatement ps = conn.prepareStatement("SELECT session_token FROM session WHERE user_id = ? AND is_active = 1");
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String dbSessionToken = rs.getString("session_token");
                if (sessionToken.equals(dbSessionToken)) {
                    sessionValid = true;
                }
            }

            rs.close();
            ps.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    if (!sessionValid) {
%>
    <p style="color:red; text-align:center;">Session expired. Please log in again.</p>
    <script>
        setTimeout(() => {
            window.location.href = "../jsp/Login.jsp";
        }, 2000);
    </script>
<%
        return;
    }

    String userType = (String) session.getAttribute("userType");
    String username = (String) session.getAttribute("username");
    String sellerId = (String) session.getAttribute("seller_id");

    if (!"seller".equalsIgnoreCase(userType)) {
        response.sendRedirect("../jsp/Login.jsp");
        return;
    }

    int totalProducts = 0;
    try {
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");
        PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM products WHERE seller_id = ?");
        ps.setString(1, sellerId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            totalProducts = rs.getInt(1);
        }

        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Seller Dashboard - AgriBridge</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f0f2f5;
            margin: 0;
            padding: 0;
        }
        .header {
            background-color: #2ecc71;
            color: white;
            padding: 15px 0;
            text-align: center;
        }
        .nav-bar {
            background-color: #27ae60;
            display: flex;
            justify-content: center;
            padding: 10px;
        }
        .nav-bar a {
            color: white;
            padding: 12px;
            text-decoration: none;
            margin: 0 15px;
        }
        .nav-bar a:hover {
            background-color: #219150;
            border-radius: 4px;
        }
        .content {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 30px;
        }
        .dashboard-card {
            background-color: white;
            padding: 20px;
            margin: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            width: 280px;
            border-radius: 8px;
            text-align: center;
        }
        .footer {
            background-color: #2ecc71;
            color: white;
            text-align: center;
            padding: 10px;
            margin-top: 30px;
        }
        h3 {
            color: #2c3e50;
        }
    </style>
</head>
<body>

<div class="header">
    <h1>Welcome, <%= username %>!</h1>
    <p>Seller Dashboard (Seller ID: <%= sellerId %>)</p>
</div>

<div class="nav-bar">
    <a href="${pageContext.request.contextPath}/seller/seller_home.jsp">Home</a>
    <a href="${pageContext.request.contextPath}/jsp/product_upload.jsp">Upload Product</a>
    <a href="${pageContext.request.contextPath}#">View Products</a>
    <a href="${pageContext.request.contextPath}/seller/inventory.jsp">Inventory</a>
    <a href="${pageContext.request.contextPath}/seller/chat.jsp">Chat with Clients</a>
    <a href="${pageContext.request.contextPath}/jsp/Log_out.jsp">Logout</a>
   <!-- <a href="seller_home.jsp">Home</a>
    <a href="../jsp/product_upload.jsp">Upload Product</a>
    <a href="view_products.jsp">View Products</a>
    <a href="inventory.jsp">Inventory</a>
    <a href="chat.jsp">Chat with Clients</a>
    <a href="../jsp/Log_out.jsp">Logout</a>-->
</div>

<div class="content">
    <div class="dashboard-card">
        <h3>Total Products</h3>
        <p><%= totalProducts %> products uploaded</p>
    </div>
    <div class="dashboard-card">
        <h3>Inventory</h3>
        <p>Track stock and availability.</p>
        <a href="inventory.jsp">View Inventory</a>
    </div>
    <div class="dashboard-card">
        <h3>Client Chat</h3>
        <p>Communicate with buyers.</p>
        <a href="chat.jsp">Open Chat</a>
    </div>
</div>

<div class="footer">
    <p>&copy; 2025 AgriBridge. All rights reserved.</p>
</div>

</body>
</html>
