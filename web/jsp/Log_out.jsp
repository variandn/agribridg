<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Prevent browser from caching this page
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Get the current session without creating a new one if none exists
    HttpSession currentSession = request.getSession(false);

    if (currentSession != null) {
        String userId = (String) currentSession.getAttribute("userId");
        String sessionToken = (String) currentSession.getAttribute("sessionToken");

        if (userId != null && sessionToken != null) {
            Connection conn = null;
            PreparedStatement pst = null;

            try {
                // Load MySQL JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver");

                // Connect to the database
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");

                // Update session table to mark this session as logged out
                String sql = "UPDATE session SET logout_time = CURRENT_TIMESTAMP, is_active = FALSE WHERE user_id = ? AND session_token = ?";
                pst = conn.prepareStatement(sql);
                pst.setString(1, userId);
                pst.setString(2, sessionToken);
                pst.executeUpdate();

            } catch (Exception e) {
                e.printStackTrace(); // Log error
            } finally {
                try {
                    if (pst != null) pst.close();
                    if (conn != null) conn.close();
                } catch (Exception e) {
                    e.printStackTrace(); // Log closing error
                }
            }

            // Invalidate the session to log out the user
            currentSession.invalidate();
        }
    }

    // Redirect to login page after logout
    response.sendRedirect("Login.jsp");
%>
