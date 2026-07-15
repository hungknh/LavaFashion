package dao;

import model.Order;
import model.OrderItem;
import model.Product;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    // ── Tạo đơn hàng, trả về order_id ────────────────────────────────────
    public int createOrder(Order order) throws SQLException {
        String sql = "INSERT INTO orders "
                + "(user_id, total_price, status, shipping_address, "
                + " receiver_name, receiver_phone, payment_method, payment_status, note) "
                + "VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, order.getUserId());
            ps.setDouble(2, order.getTotalPrice());
            ps.setString(3, "Pending");
            ps.setString(4, order.getShippingAddress());
            ps.setString(5, order.getReceiverName());
            ps.setString(6, order.getReceiverPhone());
            ps.setString(7, order.getPaymentMethod());
            ps.setString(8, "Unpaid");
            ps.setString(9, order.getNote());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : -1;
            }
        }
    }

    // ── Tạo order items ───────────────────────────────────────────────────
    public void createOrderItems(int orderId, List<model.CartItem> cartItems) throws SQLException {
        String sql = "INSERT INTO order_items (order_id, product_id, quantity, price, size) "
                + "VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (model.CartItem item : cartItems) {
                ps.setInt(1, orderId);
                ps.setInt(2, item.getProduct().getProductId());
                ps.setInt(3, item.getQuantity());
                ps.setDouble(4, item.getProduct().getPrice());
                ps.setString(5, item.getSize());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    // ── Lịch sử đơn hàng của user ─────────────────────────────────────────
    public List<Order> getOrdersByUserId(int userId) throws SQLException {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    // ── Chi tiết 1 đơn hàng + items ──────────────────────────────────────
    public Order getOrderDetail(int orderId) throws SQLException {
        String sql = "SELECT o.*, u.username FROM orders o "
                + "JOIN users u ON o.user_id = u.user_id "
                + "WHERE o.order_id = ?";
        Order order = null;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    order = mapRow(rs);
                    order.setUsername(rs.getString("username"));
                }
            }
        }
        if (order != null) {
            order.setItems(getOrderItems(orderId));
        }
        return order;
    }

    // ── Lấy items của 1 order ─────────────────────────────────────────────
    public List<OrderItem> getOrderItems(int orderId) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, p.product_name, p.color, "
                + "(SELECT TOP 1 image_url FROM product_images "
                + " WHERE product_id = p.product_id AND is_primary = 1) AS primary_image "
                + "FROM order_items oi "
                + "JOIN products p ON oi.product_id = p.product_id "
                + "WHERE oi.order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getInt("order_item_id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setPrice(rs.getDouble("price"));
                    item.setSize(rs.getString("size"));

                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setProductName(rs.getString("product_name"));
                    p.setColor(rs.getString("color"));
                    p.setPrimaryImage(rs.getString("primary_image"));
                    item.setProduct(p);
                    items.add(item);
                }
            }
        }
        return items;
    }

    // ── Admin: cập nhật trạng thái ────────────────────────────────────────
    public boolean updateStatus(int orderId, String status) throws SQLException {
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Admin: cập nhật payment status ────────────────────────────────────
    public boolean updatePaymentStatus(int orderId, String paymentStatus) throws SQLException {
        String sql = "UPDATE orders SET payment_status = ? WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Hủy đơn + lưu lý do ──────────────────────────────────────────────
    public boolean cancelWithReason(int orderId, String reason) throws SQLException {
        String sql = "UPDATE orders SET status = 'Cancelled', cancel_reason = ? "
                + "WHERE order_id = ? AND status = 'Pending' AND payment_status = 'Unpaid'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason != null ? reason : "");
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Xóa đơn (chỉ khi Pending + Unpaid) ───────────────────────────────
    public boolean deleteOrder(int orderId) throws SQLException {
        // Xóa order_items trước (FK constraint không có CASCADE)
        String deleteItems = "DELETE FROM order_items WHERE order_id = ?";
        String deleteOrder = "DELETE FROM orders WHERE order_id = ? "
                + "AND status = 'Pending' AND payment_status = 'Unpaid'";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(deleteItems)) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }
                int rows;
                try (PreparedStatement ps = conn.prepareStatement(deleteOrder)) {
                    ps.setInt(1, orderId);
                    rows = ps.executeUpdate();
                }
                conn.commit();
                return rows > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    // ── Admin: tất cả đơn hàng có phân trang ─────────────────────────────
    public List<Order> getAllOrders(int page, int pageSize) throws SQLException {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.username FROM orders o "
                + "JOIN users u ON o.user_id = u.user_id "
                + "ORDER BY o.created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (page - 1) * pageSize);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setUsername(rs.getString("username"));
                    list.add(o);
                }
            }
        }
        return list;
    }

    public int countAllOrders() throws SQLException {
        String sql = "SELECT COUNT(*) FROM orders";
        try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── Helper ────────────────────────────────────────────────────────────
    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));
        o.setUserId(rs.getInt("user_id"));
        o.setTotalPrice(rs.getDouble("total_price"));
        o.setStatus(rs.getString("status"));
        o.setShippingAddress(rs.getString("shipping_address"));
        o.setReceiverName(rs.getString("receiver_name"));
        o.setReceiverPhone(rs.getString("receiver_phone"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setPaymentStatus(rs.getString("payment_status"));
        o.setNote(rs.getString("note"));
        o.setCancelReason(rs.getString("cancel_reason"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            o.setCreatedAt(ts.toLocalDateTime());
        }
        return o;
    }
}
