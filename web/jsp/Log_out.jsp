<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, Servlets.MongoDBConnection" %>
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
            try {
                MongoDatabase db = MongoDBConnection.getDatabase();
                MongoCollection<Document> sessions = db.getCollection("sessions");

                // Update session to mark as logged out
                sessions.updateOne(
                    Filters.and(
                        Filters.eq("user_id", userId),
                        Filters.eq("session_token", sessionToken)
                    ),
                    Updates.combine(
                        Updates.set("logout_time", new java.util.Date()),
                        Updates.set("is_active", false)
                    )
                );
            } catch (Exception e) {
                e.printStackTrace();
            }

            // Invalidate the session to log out the user
            currentSession.invalidate();
        }
    }

    // Redirect to login page after logout
    response.sendRedirect("Login.jsp");
%>
