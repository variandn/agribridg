package Servlets;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;
import org.bson.types.Binary;

@MultipartConfig(maxFileSize = 16177215) // 16MB max for file upload
public class UploadProductServlet extends HttpServlet {

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
        byte[] imageBytes = null;
        if (filePart != null && filePart.getSize() > 0) {
            InputStream is = filePart.getInputStream();
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            int nRead;
            byte[] data = new byte[16384];
            while ((nRead = is.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, nRead);
            }
            imageBytes = buffer.toByteArray();
        }

        // Get seller ID from session (stored during login as a String)
        HttpSession session = request.getSession(false);
        String sellerId = null;

        if (session != null && session.getAttribute("userId") != null) {
            sellerId = session.getAttribute("userId").toString();
        }

        String message = "";

        if (sellerId == null) {
            message = "Session expired or invalid user ID. Please login again.";
            request.setAttribute("message", message);
            request.getRequestDispatcher("/jsp/product_upload.jsp").forward(request, response);
            return;
        }

        // Insert into MongoDB
        try {
            MongoDatabase db = MongoDBConnection.getDatabase();
            MongoCollection<Document> products = db.getCollection("products");

            Document doc = new Document("product_name", productName)
                    .append("description", productDescription)
                    .append("category", category)
                    .append("price", price)
                    .append("stock_quantity", stockQuantity)
                    .append("seller_id", sellerId)
                    .append("created_at", new java.util.Date());

            if (imageBytes != null) {
                doc.append("image", new Binary(imageBytes));
            }

            products.insertOne(doc);
            message = "Product uploaded successfully!";

        } catch (Exception ex) {
            ex.printStackTrace();
            message = "ERROR: " + ex.getMessage();
        }

        // Send back message to JSP for display
        request.setAttribute("message", message);
        request.getRequestDispatcher("/jsp/product_upload.jsp").forward(request, response);
    }
}
