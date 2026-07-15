/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class OrderItem {

    private int orderItemId;
    private int orderId;
    private Product product;     // object Product đầy đủ
    private int quantity;
    private double price;       // giá tại thời điểm đặt hàng
    private String size;        // S, M, L, XL, XXL

    public OrderItem() {
    }

    public int getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(int orderItemId) {
        this.orderItemId = orderItemId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    // Thành tiền
    public double getSubtotal() {
        return price * quantity;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getFormattedPrice() {
        return String.format("$%.2f", price);
    }

    public String getFormattedSubtotal() {
        return String.format("$%.2f", getSubtotal());
    }
}
