package service;

import dao.CartDAO;
import dao.OrderDAO;
import model.CartItem;
import model.Order;
import model.OrderItem;
import utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

public class OrderService {

    private final OrderDAO orderDAO = new OrderDAO();
    private final CartDAO cartDAO = new CartDAO();

    // ── Đặt hàng ─────────────────────────────────────────────────────────
    public int placeOrder(int userId, String receiverName, String receiverPhone,
            String shippingAddress, String paymentMethod, String note)
            throws SQLException {

        int cartId = cartDAO.getOrCreateCart(userId);
        List<CartItem> items = cartDAO.getCartItems(cartId);

        if (items == null || items.isEmpty()) {
            throw new IllegalStateException("Cart is empty.");
        }

        double total = items.stream().mapToDouble(CartItem::getSubtotal).sum();

        Order order = new Order();
        order.setUserId(userId);
        order.setTotalPrice(total);
        order.setReceiverName(receiverName);
        order.setReceiverPhone(receiverPhone);
        order.setShippingAddress(shippingAddress);
        order.setPaymentMethod(paymentMethod != null ? paymentMethod : "COD");
        order.setNote(note);

        int orderId = orderDAO.createOrder(order);
        if (orderId < 0) {
            throw new SQLException("Failed to create order.");
        }

        orderDAO.createOrderItems(orderId, items);
        deductStock(items);
        cartDAO.clearCart(cartId);

        return orderId;
    }

    // ── Hủy đơn hàng + hoàn stock ────────────────────────────────────────
    public void cancelOrder(int orderId, List<OrderItem> items, String reason) throws SQLException {

        orderDAO.cancelWithReason(orderId, reason);

        if (items == null || items.isEmpty()) {
            return;
        }

        String sqlSize = "UPDATE product_sizes SET stock = stock + ? "
                + "WHERE product_id = ? AND size = ?";
        String sqlProd = "UPDATE products SET stock = stock + ? "
                + "WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psSize = conn.prepareStatement(sqlSize); PreparedStatement psProd = conn.prepareStatement(sqlProd)) {

                for (OrderItem item : items) {
                    int pid = item.getProduct().getProductId();
                    int qty = item.getQuantity();

                    psSize.setInt(1, qty);
                    psSize.setInt(2, pid);
                    psSize.setString(3, item.getSize());
                    psSize.addBatch();

                    psProd.setInt(1, qty);
                    psProd.setInt(2, pid);
                    psProd.addBatch();
                }
                psSize.executeBatch();
                psProd.executeBatch();
                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    // ── Trừ tồn kho sau khi đặt hàng ─────────────────────────────────────
    private void deductStock(List<CartItem> items) throws SQLException {
        String sqlSize = "UPDATE product_sizes SET stock = stock - ? "
                + "WHERE product_id = ? AND size = ? AND stock >= ?";
        String sqlProd = "UPDATE products SET stock = stock - ? "
                + "WHERE product_id = ? AND stock >= ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psSize = conn.prepareStatement(sqlSize); PreparedStatement psProd = conn.prepareStatement(sqlProd)) {

                for (CartItem item : items) {
                    int pid = item.getProduct().getProductId();
                    int qty = item.getQuantity();

                    psSize.setInt(1, qty);
                    psSize.setInt(2, pid);
                    psSize.setString(3, item.getSize());
                    psSize.setInt(4, qty);
                    psSize.addBatch();

                    psProd.setInt(1, qty);
                    psProd.setInt(2, pid);
                    psProd.setInt(3, qty);
                    psProd.addBatch();
                }
                psSize.executeBatch();
                psProd.executeBatch();
                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }
}
