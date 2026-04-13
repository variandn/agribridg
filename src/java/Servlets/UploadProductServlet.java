package Servlets;  // Updated package name

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

@WebServlet("/servlets/UploadProductServlet")
@MultipartConfig(maxFileSize = 16177215) // 16MB max for file upload
public class UploadProductServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/agribridge";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "variandn4";  // <-- Your database password

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Retrieve form fields
        String productName = request.getParameter("productName");
        String productDescription = request.getParameter("productDescription");
        String category = request.getParameter("category");
        double price = Double.parseDouble(request.getParameter("productPrice"));
        int stockQuantity = Integer.parseInt(request.getParameter("productStock"));

        // Retrieve file part
        Part filePart = request.getPart("productImage");
        InputStream imageStream = null;
        if (filePart != null) {
            imageStream = filePart.getInputStream();
        }

        // Get seller ID from session (assuming it's stored during login)
        HttpSession session = request.getSession(false);
        Integer sellerId = null;
        
        // Safely parse userId as Integer if it's a String
        if (session != null && session.getAttribute("userId") != null) {
            try {
                sellerId = Integer.parseInt(session.getAttribute("userId").toString());
            } catch (NumberFormatException e) {
                // Handle the case where the userId is not a valid Integer
                sellerId = null;
            }
        }

        String message = "";

        if (sellerId == null) {
            message = "Session expired or invalid user ID. Please login again.";
            request.setAttribute("message", message);
            request.getRequestDispatcher("/jsp/product_upload.jsp").forward(request, response);
            return;
        }

        // Insert into database
        try {
            DriverManager.registerDriver(new com.mysql.cj.jdbc.Driver());
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "INSERT INTO products (product_name, description, category, price, stock_quantity, image, seller_id) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, productName);
            stmt.setString(2, productDescription);
            stmt.setString(3, category);
            stmt.setDouble(4, price);
            stmt.setInt(5, stockQuantity);

            if (imageStream != null) {
                stmt.setBlob(6, imageStream);
            } else {
                stmt.setNull(6, Types.BLOB);
            }

            stmt.setInt(7, sellerId);

            int row = stmt.executeUpdate();
            if (row > 0) {
                message = "Product uploaded successfully!";
            } else {
                message = "Failed to upload product.";
            }

            stmt.close();
            conn.close();

        } catch (SQLException ex) {
            ex.printStackTrace();
            message = "ERROR: " + ex.getMessage();
        }

        // Send back message to JSP for display
        request.setAttribute("message", message);
        // Forward the user to the JSP page with the message
        request.getRequestDispatcher("/jsp/product_upload.jsp").forward(request, response);
    }
}
