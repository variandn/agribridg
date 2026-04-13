<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="jakarta.servlet.*" %>
<%@ page import="jakarta.servlet.http.*" %>
<%@ page session="true" %>

<%
    // Safely get session — session="true" ensures it's already available
   // HttpSession session = request.getSession();

    // Fetch parameters from URL
    String supplierId = request.getParameter("id");
    String productId = request.getParameter("productId");

    // Get user ID from session
    Object userId = session.getAttribute("userId");

    if (userId == null) {
        // Not logged in — store redirect path and go to login
        session.setAttribute("redirectAfterLogin", "chat.jsp?id=" + supplierId + "&productId=" + productId);
        response.sendRedirect("Login.jsp?message=Please login to contact the supplier");
    } else {
        // Logged in — go to chat page
        response.sendRedirect("chat.jsp?id=" + supplierId + "&productId=" + productId);
    }
%>
