package model;

public class CartItem {

    private int cartItemId;
    private int cartId;
    private Product product;
    private int quantity;
    private String size;       // S, M, L, XL, XXL

    public CartItem() {
    }

    // ── Getters & Setters ─────────────────────────────────────────────────
    public int getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(int v) {
        this.cartItemId = v;
    }

    public int getCartId() {
        return cartId;
    }

    public void setCartId(int v) {
        this.cartId = v;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product v) {
        this.product = v;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int v) {
        this.quantity = v;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String v) {
        this.size = v;
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    public double getSubtotal() {
        return product != null ? product.getPrice() * quantity : 0;
    }

    public String getFormattedSubtotal() {
        return String.format("$%.2f", getSubtotal());
    }
}
