package Servlets;

/**
 * HTML escaping utility to prevent XSS attacks.
 * Use HtmlUtils.escape() in JSP scriptlets instead of raw <%= %> output.
 */
public class HtmlUtils {

    /**
     * Escape HTML special characters in user-controlled strings.
     * Returns empty string for null input.
     */
    public static String escape(String input) {
        if (input == null) return "";
        StringBuilder sb = new StringBuilder(input.length());
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '&':  sb.append("&amp;"); break;
                case '<':  sb.append("&lt;"); break;
                case '>':  sb.append("&gt;"); break;
                case '"':  sb.append("&quot;"); break;
                case '\'': sb.append("&#39;"); break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }
}
