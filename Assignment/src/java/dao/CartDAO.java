/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.CartItem;
import model.Product;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    // ── Lấy cart_id của user, tạo mới nếu chưa có ────────────────────────
    public int getOrCreateCart(int userId) throws SQLException {
        String sel = "SELECT cart_id FROM cart WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sel)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cart_id");
                }
            }
        }
        // Chưa có → tạo mới
        String ins = "INSERT INTO cart (user_id) VALUES (?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : -1;
            }
        }
    }

    // ── Lấy danh sách CartItem (kèm Product) ─────────────────────────────
    public List<CartItem> getCartItems(int cartId) throws SQLException {
        List<CartItem> items = new ArrayList<>();
        String sql
                = "SELECT ci.cart_item_id, ci.cart_id, ci.quantity, ci.size, "
                + "       p.product_id, p.product_name, p.price, p.stock, p.color, "
                + "       c.category_name, b.brand_name, "
                + "       (SELECT TOP 1 image_url FROM product_images "
                + "        WHERE product_id = p.product_id AND is_primary = 1) AS primary_image "
                + "FROM cart_items ci "
                + "JOIN products p  ON ci.product_id = p.product_id "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN brands b    ON p.brand_id = b.brand_id "
                + "WHERE ci.cart_id = ? "
                + "ORDER BY ci.cart_item_id";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getInt("cart_item_id"));
                    item.setCartId(rs.getInt("cart_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setSize(rs.getString("size"));

                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setProductName(rs.getString("product_name"));
                    p.setPrice(rs.getDouble("price"));
                    p.setStock(rs.getInt("stock"));
                    p.setColor(rs.getString("color"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setBrandName(rs.getString("brand_name"));
                    p.setPrimaryImage(rs.getString("primary_image"));
                    item.setProduct(p);

                    items.add(item);
                }
            }
        }
        return items;
    }

    // ── Thêm item vào giỏ (cùng product + size → tăng qty, khác → thêm mới) ──
    public void addItem(int cartId, int productId, String size, int qty) throws SQLException {
        String check = "SELECT cart_item_id, quantity FROM cart_items "
                + "WHERE cart_id = ? AND product_id = ? AND size = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(check)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            ps.setString(3, size);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Đã có → update qty
                    int newQty = rs.getInt("quantity") + qty;
                    int itemId = rs.getInt("cart_item_id");
                    String upd = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";
                    try (Connection c2 = DBConnection.getConnection(); PreparedStatement ps2 = c2.prepareStatement(upd)) {
                        ps2.setInt(1, newQty);
                        ps2.setInt(2, itemId);
                        ps2.executeUpdate();
                    }
                    return;
                }
            }
        }
        // Chưa có → insert mới
        String ins = "INSERT INTO cart_items (cart_id, product_id, size, quantity) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(ins)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            ps.setString(3, size);
            ps.setInt(4, qty);
            ps.executeUpdate();
        }
    }

    // ── Cập nhật số lượng ─────────────────────────────────────────────────
    public void updateItemQty(int cartItemId, int qty) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, qty);
            ps.setInt(2, cartItemId);
            ps.executeUpdate();
        }
    }

    // ── Xóa 1 item ───────────────────────────────────────────────────────
    public void removeItem(int cartItemId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartItemId);
            ps.executeUpdate();
        }
    }

    // ── Xóa toàn bộ items (sau khi checkout) ─────────────────────────────
    public void clearCart(int cartId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.executeUpdate();
        }
    }

    // ── Đếm tổng số items trong giỏ (cho badge icon) ─────────────────────
    public int countItems(int cartId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(quantity), 0) FROM cart_items WHERE cart_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
