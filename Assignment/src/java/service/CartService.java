/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.CartDAO;
import dao.ProductDAO;
import model.CartItem;
import model.Product;
import java.sql.SQLException;
import java.util.List;

public class CartService {

    private final CartDAO cartDAO = new CartDAO();
    private final ProductDAO productDAO = new ProductDAO();

    // ── Lấy danh sách CartItem của user ──────────────────────────────────
    public List<CartItem> getCart(int userId) throws SQLException {
        int cartId = cartDAO.getOrCreateCart(userId);
        return cartDAO.getCartItems(cartId);
    }

    // ── Thêm vào giỏ (kiểm tra tồn kho theo size) ────────────────────────
    public String addToCart(int userId, int productId, String size, int qty) throws SQLException {
        // Kiểm tra size stock
        Product product = productDAO.findById(productId);
        if (product == null) {
            return "Product not found.";
        }

        java.util.LinkedHashMap<String, Integer> sizeStocks = productDAO.getSizeStocks(productId);
        Integer sizeStock = sizeStocks.get(size);
        if (sizeStock == null) {
            return "Invalid size selected.";
        }
        if (sizeStock <= 0) {
            return "Size " + size + " is out of stock.";
        }

        // Kiểm tra tổng qty trong giỏ + qty mới không vượt sizeStock
        int cartId = cartDAO.getOrCreateCart(userId);
        List<CartItem> items = cartDAO.getCartItems(cartId);
        int currentQty = items.stream()
                .filter(i -> i.getProduct().getProductId() == productId
                && size.equals(i.getSize()))
                .mapToInt(CartItem::getQuantity).sum();

        if (currentQty + qty > sizeStock) {
            return "Only " + (sizeStock - currentQty) + " item(s) left for size " + size + ".";
        }

        cartDAO.addItem(cartId, productId, size, qty);
        return null; // null = thành công
    }

    // ── Cập nhật số lượng ─────────────────────────────────────────────────
    public void updateQuantity(int cartItemId, int qty) throws SQLException {
        if (qty <= 0) {
            cartDAO.removeItem(cartItemId);
        } else {
            cartDAO.updateItemQty(cartItemId, qty);
        }
    }

    // ── Xóa 1 item ────────────────────────────────────────────────────────
    public void removeItem(int cartItemId) throws SQLException {
        cartDAO.removeItem(cartItemId);
    }

    // ── Tính tổng tiền ────────────────────────────────────────────────────
    public double calculateTotal(List<CartItem> items) {
        return items.stream().mapToDouble(CartItem::getSubtotal).sum();
    }

    // ── Đếm items (cho badge) ─────────────────────────────────────────────
    public int countItems(int userId) throws SQLException {
        int cartId = cartDAO.getOrCreateCart(userId);
        return cartDAO.countItems(cartId);
    }
}
