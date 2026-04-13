<%-- 
    Document   : delete_product
    Created on : Apr 15, 2025, 2:59:07 PM
    Author     : Administrator
--%>

<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Delete Product</title>
</head>
<body>
<%
    int id = Integer.parseInt(request.getParameter("id"));

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_ride", "root", "yourpassword");
        PreparedStatement ps = con.prepareStatement("DELETE FROM products WHERE id=?");
        ps.setInt(1, id);

        int deleted = ps.executeUpdate();
        if (deleted > 0) {
            response.sendRedirect("my_products.jsp");
        } else {
%>
            <p style="color:red; text-align:center;">Product not found or could not be deleted.</p>
<%
        }

        ps.close();
        con.close();
    } catch (Exception e) {
%>
        <p style="color:red; text-align:center;">Error: <%= e.getMessage() %></p>
<%
    }
%>
</body>
</html>
