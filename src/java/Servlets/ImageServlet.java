package Servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.io.ByteArrayInputStream;
import javax.imageio.ImageIO;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import org.bson.Document;
import org.bson.types.Binary;
import org.bson.types.ObjectId;

public class ImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String productId = request.getParameter("id");

        if (productId == null || productId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing product ID");
            return;
        }
        productId = productId.trim();

        System.out.println("Fetching image for product ID: " + productId);

        // Get image data from MongoDB
        byte[] imageBytes = null;
        try {
            MongoDatabase db = MongoDBConnection.getDatabase();
            MongoCollection<Document> products = db.getCollection("products");

            Document doc = products.find(Filters.eq("_id", new ObjectId(productId))).first();

            if (doc != null && doc.get("image") != null) {
                Object imgObj = doc.get("image");
                if (imgObj instanceof Binary) {
                    imageBytes = ((Binary) imgObj).getData();
                } else if (imgObj instanceof byte[]) {
                    imageBytes = (byte[]) imgObj;
                } else {
                    System.out.println("Unexpected image data type: " + imgObj.getClass().getName());
                }
            }
        } catch (IllegalArgumentException e) {
            // Invalid ObjectId format
            System.out.println("Invalid product ID format: " + productId);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID format");
            return;
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
            return;
        }

        if (imageBytes != null && imageBytes.length > 0) {
            // Determine content type from image bytes
            String contentType = getImageType(imageBytes);
            if (contentType == null) {
                contentType = "image/jpeg"; // default fallback
            }

            response.setContentType(contentType);
            response.setContentLength(imageBytes.length);

            try (OutputStream out = response.getOutputStream()) {
                out.write(imageBytes);
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
        }
    }

    // Helper method to detect image type from byte array
    private String getImageType(byte[] imageBytes) {
        if (imageBytes == null || imageBytes.length < 4) return null;

        // Check magic bytes for common image formats
        if (imageBytes[0] == (byte) 0xFF && imageBytes[1] == (byte) 0xD8) {
            return "image/jpeg";
        } else if (imageBytes[0] == (byte) 0x89 && imageBytes[1] == (byte) 0x50
                && imageBytes[2] == (byte) 0x4E && imageBytes[3] == (byte) 0x47) {
            return "image/png";
        } else if (imageBytes[0] == (byte) 0x47 && imageBytes[1] == (byte) 0x49
                && imageBytes[2] == (byte) 0x46) {
            return "image/gif";
        } else if (imageBytes[0] == (byte) 0x52 && imageBytes[1] == (byte) 0x49
                && imageBytes[2] == (byte) 0x46 && imageBytes[3] == (byte) 0x46) {
            return "image/webp";
        }
        return "image/jpeg"; // default
    }
}
