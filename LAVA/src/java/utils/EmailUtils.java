package utils;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.UnsupportedEncodingException;
import java.util.Properties;
import model.Order;
import model.OrderItem;

public class EmailUtils {

    // ── Cấu hình SMTP (giữ nguyên từ AuthService) ─────────────────────────
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String FROM_EMAIL = "hungg8746@gmail.com";   // ← email của bạn
    private static final String FROM_PASS = "drik umhr qkto ewtm"; // ← App Password Gmail
    private static final String FROM_NAME = "LAVA Fashion";

    private static Session buildSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, FROM_PASS);
            }
        });
    }

    // ── Gửi email reset mật khẩu (giữ nguyên) ────────────────────────────
    public static void sendResetEmail(String toEmail, String resetLink)
            throws MessagingException, UnsupportedEncodingException {
        Session session = buildSession();
        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
        msg.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
        msg.setSubject("Reset your LAVA password");
        String body = "<div style='font-family:Arial,sans-serif;max-width:560px;margin:0 auto'>"
                + "<h2 style='color:#111'>Password Reset</h2>"
                + "<p>Click the link below to reset your password. "
                + "This link expires in <strong>30 minutes</strong>.</p>"
                + "<a href='" + resetLink + "' style='display:inline-block;padding:12px 28px;"
                + "background:#111;color:#fff;text-decoration:none;font-weight:bold;'>Reset Password</a>"
                + "<p style='color:#aaa;font-size:12px;margin-top:20px'>If you did not request this, ignore this email.</p>"
                + "</div>";
        msg.setContent(body, "text/html; charset=UTF-8");
        Transport.send(msg);
    }

    // ── Gửi email xác nhận đơn hàng ──────────────────────────────────────
    public static void sendOrderConfirmation(String toEmail, Order order)
            throws MessagingException, UnsupportedEncodingException {

        Session session = buildSession();
        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
        msg.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
        msg.setSubject("Order #" + order.getOrderId() + " Confirmed – LAVA Fashion");

        // Build items table
        StringBuilder itemRows = new StringBuilder();
        if (order.getItems() != null) {
            for (OrderItem item : order.getItems()) {
                String name = item.getProduct() != null
                        ? item.getProduct().getProductName() : "Product";
                String size = item.getSize() != null ? item.getSize() : "";
                double sub = item.getPrice() * item.getQuantity();
                itemRows.append("<tr>")
                        .append("<td style='padding:10px 8px;border-bottom:1px solid #eee'>")
                        .append(name).append(size.isEmpty() ? "" : " <span style='color:#888;font-size:12px'>(").append(size).append(")</span>")
                        .append("</td>")
                        .append("<td style='padding:10px 8px;border-bottom:1px solid #eee;text-align:center'>")
                        .append(item.getQuantity()).append("</td>")
                        .append("<td style='padding:10px 8px;border-bottom:1px solid #eee;text-align:right'>$")
                        .append(String.format("%.2f", item.getPrice())).append("</td>")
                        .append("<td style='padding:10px 8px;border-bottom:1px solid #eee;text-align:right'><strong>$")
                        .append(String.format("%.2f", sub)).append("</strong></td>")
                        .append("</tr>");
            }
        }

        String body = "<div style='font-family:Arial,sans-serif;max-width:600px;margin:0 auto;color:#111'>"
                // Header
                + "<div style='background:#111;padding:24px 32px;text-align:center'>"
                + "<h1 style='color:#fff;margin:0;letter-spacing:4px;font-size:22px'>LAVA</h1>"
                + "<p style='color:#aaa;margin:4px 0 0;font-size:12px'>FASHION</p>"
                + "</div>"
                // Title
                + "<div style='padding:28px 32px 0'>"
                + "<h2 style='margin:0 0 6px'>Order Confirmed! 🎉</h2>"
                + "<p style='color:#555;margin:0'>Hi <strong>" + order.getReceiverName() + "</strong>, "
                + "your order has been placed successfully.</p>"
                + "</div>"
                // Order info box
                + "<div style='margin:20px 32px;background:#f9f9f9;border:1px solid #eee;padding:16px 20px;'>"
                + "<table style='width:100%;font-size:13px'><tbody>"
                + "<tr><td style='color:#888;padding:4px 0'>Order ID</td>"
                + "<td style='text-align:right'><strong>#" + order.getOrderId() + "</strong></td></tr>"
                + "<tr><td style='color:#888;padding:4px 0'>Date</td>"
                + "<td style='text-align:right'>" + order.getFormattedDate() + "</td></tr>"
                + "<tr><td style='color:#888;padding:4px 0'>Payment</td>"
                + "<td style='text-align:right'>" + order.getPaymentMethod() + "</td></tr>"
                + "<tr><td style='color:#888;padding:4px 0'>Ship to</td>"
                + "<td style='text-align:right'>" + order.getShippingAddress() + "</td></tr>"
                + "</tbody></table>"
                + "</div>"
                // Items table
                + "<div style='padding:0 32px'>"
                + "<table style='width:100%;border-collapse:collapse;font-size:13px'>"
                + "<thead><tr style='background:#f0f0f0'>"
                + "<th style='padding:10px 8px;text-align:left;font-size:11px;text-transform:uppercase'>Item</th>"
                + "<th style='padding:10px 8px;text-align:center;font-size:11px;text-transform:uppercase'>Qty</th>"
                + "<th style='padding:10px 8px;text-align:right;font-size:11px;text-transform:uppercase'>Price</th>"
                + "<th style='padding:10px 8px;text-align:right;font-size:11px;text-transform:uppercase'>Subtotal</th>"
                + "</tr></thead><tbody>"
                + itemRows
                + "</tbody></table>"
                + "</div>"
                // Total
                + "<div style='padding:16px 32px;text-align:right;border-top:2px solid #111;margin:0 32px'>"
                + "<span style='font-size:16px'>Total: </span>"
                + "<strong style='font-size:20px'>" + order.getFormattedTotal() + "</strong>"
                + "</div>"
                // Footer
                + "<div style='padding:24px 32px;text-align:center;color:#aaa;font-size:12px;"
                + "border-top:1px solid #eee;margin-top:16px'>"
                + "<p>Thank you for shopping at <strong style='color:#111'>LAVA Fashion</strong></p>"
                + "<p>Questions? Email us at hungg8746@gmail.com</p>"
                + "</div>"
                + "</div>";

        msg.setContent(body, "text/html; charset=UTF-8");
        Transport.send(msg);
    }
}
