package Servlets;

import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
//import java.nio.file.Files;
//import java.nio.file.Paths;
import java.sql.*;
import javax.imageio.ImageIO;
import java.io.ByteArrayInputStream;

//@WebServlet("/getImage")  // Uncomment this line if you are not using annotations in your web.xml
public class ImageServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String productId = request.getParameter("id");

        if (productId == null || productId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing product ID");
            return;
        }

        // Log the product ID to ensure the correct image request
        System.out.println("Fetching image for product ID: " + productId);

        // Get image data and type
        ImageData imageData = getImageFromDatabase(productId);

        if (imageData != null && imageData.data != null) {
            // Set proper content type
            response.setContentType(imageData.contentType);
            response.setContentLength(imageData.data.length);

            try (OutputStream out = response.getOutputStream()) {
                out.write(imageData.data);
            }
        } else {
            // Fallback: Serve a default image if the product image is not found
            // Uncomment below lines if you want to fallback to a static image for testing
            /*
            System.out.println("Image not found for product ID: " + productId);
            byte[] fallbackImage = Files.readAllBytes(Paths.get("path/to/default/image.jpg")); // Provide your fallback image path here
            String fallbackContentType = "image/jpeg"; // Adjust content type based on the fallback image
            response.setContentType(fallbackContentType);
            response.setContentLength(fallbackImage.length);

            try (OutputStream out = response.getOutputStream()) {
                out.write(fallbackImage);
            }
            */
            
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
        }
    }

    private ImageData getImageFromDatabase(String productId) {
        ImageData imageData = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");
                 PreparedStatement ps = conn.prepareStatement("SELECT image FROM products WHERE product_id = ?")) {

                ps.setString(1, productId);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    byte[] imageBytes = rs.getBytes("image");
                    
                    // Determine the image content type based on the image data
                    String imageType = getImageType(imageBytes);

                    if (imageType != null) {
                        imageData = new ImageData(imageBytes, imageType);
                    }
                } else {
                    System.out.println("No image found for product ID: " + productId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return imageData;
    }

    // Helper method to detect image type from byte array
    private String getImageType(byte[] imageBytes) {
        try (ByteArrayInputStream bais = new ByteArrayInputStream(imageBytes)) {
            // Using ImageIO to detect image format (content type)
            String imageType = ImageIO.getImageReadersByFormatName("jpg").hasNext() ? "image/jpeg" :
                               ImageIO.getImageReadersByFormatName("png").hasNext() ? "image/png" :
                               ImageIO.getImageReadersByFormatName("gif").hasNext() ? "image/gif" : null;
            return imageType;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    // Helper class to return image bytes and type
    private static class ImageData {
        byte[] data;
        String contentType;

        public ImageData(byte[] data, String contentType) {
            this.data = data;
            this.contentType = contentType;
        }
    }
}
