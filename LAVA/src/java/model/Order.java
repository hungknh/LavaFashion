/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.time.LocalDateTime;
import java.util.List;

public class Order {

    private int orderId;
    private int userId;
    private String username;          // join từ users (hiển thị ở admin)
    private double totalPrice;
    private String status;            // Pending | Processing | Shipped | Delivered | Cancelled
    private String shippingAddress;
    private String receiverName;
    private String receiverPhone;
    private String paymentMethod;     // COD | BankTransfer
    private String paymentStatus;     // unpaid | paid
    private String note;
    private String cancelReason;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private List<OrderItem> items;    // load kèm khi xem chi tiết

    public Order() {
    }

    // ── Getters & Setters ──────────────────────────────────────────────────
    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getReceiverPhone() {
        return receiverPhone;
    }

    public void setReceiverPhone(String receiverPhone) {
        this.receiverPhone = receiverPhone;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String v) {
        this.cancelReason = v;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }

    // ── Helper ────────────────────────────────────────────────────────────
    public boolean isCancellable() {
        return "Pending".equalsIgnoreCase(status) && "unpaid".equalsIgnoreCase(paymentStatus);
    }

    public String getFormattedTotal() {
        return String.format("$%.2f", totalPrice);
    }

    public String getFormattedDate() {
        if (createdAt == null) {
            return "";
        }
        return createdAt.toLocalDate().toString();
    }

    public String getStatusClass() {
        if (status == null) {
            return "";
        }
        return switch (status) {
            case "Pending" -> "status-pending";
            case "Processing" -> "status-processing";
            case "Shipped" -> "status-shipped";
            case "Delivered" -> "status-delivered";
            case "Cancelled" -> "status-cancelled";
            default -> "";
        };
    }
}
