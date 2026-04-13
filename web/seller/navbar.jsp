<%-- 
    Document   : navbar
    Created on : Apr 15, 2025, 3:10:48 PM
    Author     : Administrator
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    .navbar {
        background-color: #2e8b57;
        overflow: hidden;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 14px 30px;
    }
    .navbar a {
        color: white;
        text-decoration: none;
        padding: 14px;
        font-weight: bold;
    }
    .navbar a:hover {
        background-color: #246b45;
        border-radius: 5px;
    }
    .navbar .links {
        display: flex;
        gap: 10px;
    }
    .navbar .brand {
        font-size: 20px;
        color: #f0f0f0;
    }
</style>

<div class="navbar">
    <div class="brand">AgriBridge | Seller Dashboard</div>
    <div class="links">
        <a href="${pageContext.request.contextPath}/jsp/product_upload.jsp">Upload Product</a>
       <!--<a href="product_upload.jsp">Upload Product</a>-->
        <a href="manage_product.jsp">My Products</a>
        <a href="sales.jsp">Sales & Profits</a>
        <a href="inventory.jsp">Inventory</a>
        <a href="chat.jsp">Chat</a>
        <!--<a href="all_products.jsp">All Products</a>-->
        <a href="../jsp/Log_out.jsp">Logout</a>
    </div>
</div>
