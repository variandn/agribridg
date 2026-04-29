<%--
    Auth guard for seller pages.
    Include at the top of any page that requires seller authentication.
    After inclusion, these variables are available:
      - sellerId  (String)
      - username  (String)
--%>
<%
    // Redirect to login if session is missing or user is not a seller
    if (session == null
            || session.getAttribute("userId") == null
            || session.getAttribute("sessionToken") == null
            || !"seller".equalsIgnoreCase((String) session.getAttribute("userType"))) {
        response.sendRedirect(request.getContextPath() + "/jsp/Login.jsp");
        return;
    }

    String sellerId = (String) session.getAttribute("seller_id");
    if (sellerId == null) sellerId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
%>
