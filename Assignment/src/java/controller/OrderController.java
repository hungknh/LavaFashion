package controller;

import dao.OrderDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.CartItem;
import model.Order;
import model.User;
import service.CartService;
import service.OrderService;
import utils.EmailUtils;

import java.io.IOException;
import java.util.List;

@WebServlet({"/checkout", "/order-success", "/order-history"})
public class OrderController extends HttpServlet {

    private final CartService cartService = new CartService();
    private final OrderService orderService = new OrderService();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            return;
        }

        String uri = req.getServletPath();

        try {
            switch (uri) {

                case "/checkout": {
                    List<CartItem> items = cartService.getCart(user.getUserId());
                    if (items.isEmpty()) {
                        resp.sendRedirect(req.getContextPath() + "/cart");
                        return;
                    }
                    double total = cartService.calculateTotal(items);
                    req.setAttribute("cartItems", items);
                    req.setAttribute("cartTotal", total);
                    // Pre-fill receiver info từ profile
                    req.setAttribute("receiverName", user.getFullName() != null ? user.getFullName() : "");
                    req.setAttribute("receiverPhone", user.getPhone() != null ? user.getPhone() : "");
                    req.getRequestDispatcher("/order/checkout.jsp").forward(req, resp);
                    break;
                }

                case "/order-success": {
                    String idParam = req.getParameter("id");
                    if (idParam == null) {
                        resp.sendRedirect(req.getContextPath() + "/home");
                        return;
                    }
                    int orderId = Integer.parseInt(idParam);
                    Order order = orderDAO.getOrderDetail(orderId);
                    // Security: chỉ xem đơn của chính mình
                    if (order == null || order.getUserId() != user.getUserId()) {
                        resp.sendRedirect(req.getContextPath() + "/home");
                        return;
                    }
                    req.setAttribute("order", order);
                    req.getRequestDispatcher("/order/order-success.jsp").forward(req, resp);
                    break;
                }

                case "/order-history": {
                    List<Order> orders = orderDAO.getOrdersByUserId(user.getUserId());
                    // Load items cho mỗi order
                    for (Order o : orders) {
                        o.setItems(orderDAO.getOrderItems(o.getOrderId()));
                    }
                    req.setAttribute("orders", orders);
                    req.getRequestDispatcher("/order/order-history.jsp").forward(req, resp);
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Something went wrong. Please try again.");
            req.getRequestDispatcher("/order/checkout.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            return;
        }

        String uri = req.getServletPath();

        if ("/checkout".equals(uri)) {
            String receiverName = req.getParameter("receiverName");
            String receiverPhone = req.getParameter("receiverPhone");
            String shippingAddress = req.getParameter("shippingAddress");
            String paymentMethod = req.getParameter("paymentMethod");
            String note = req.getParameter("note");

            // Validate
            if (receiverName == null || receiverName.trim().isEmpty()
                    || receiverPhone == null || receiverPhone.trim().isEmpty()
                    || shippingAddress == null || shippingAddress.trim().isEmpty()) {

                try {
                    List<CartItem> items = cartService.getCart(user.getUserId());
                    req.setAttribute("cartItems", items);
                    req.setAttribute("cartTotal", cartService.calculateTotal(items));
                } catch (Exception ignored) {
                }
                req.setAttribute("error", "Please fill in all required fields.");
                req.setAttribute("receiverName", receiverName);
                req.setAttribute("receiverPhone", receiverPhone);
                req.setAttribute("shippingAddress", shippingAddress);
                req.getRequestDispatcher("/order/checkout.jsp").forward(req, resp);
                return;
            }

            try {
                int orderId = orderService.placeOrder(
                        user.getUserId(),
                        receiverName.trim(),
                        receiverPhone.trim(),
                        shippingAddress.trim(),
                        paymentMethod,
                        note != null ? note.trim() : ""
                );
                // Gửi email xác nhận — chạy async để không block response
                try {
                    Order confirmedOrder = orderDAO.getOrderDetail(orderId);
                    if (confirmedOrder != null && user.getEmail() != null && !user.getEmail().isEmpty()) {
                        final Order emailOrder = confirmedOrder;
                        final String emailAddr = user.getEmail();
                        new Thread(() -> {
                            try {
                                EmailUtils.sendOrderConfirmation(emailAddr, emailOrder);
                            } catch (Exception ex) {
                                System.err.println("Email send failed: " + ex.getMessage());
                            }
                        }).start();
                    }
                } catch (Exception emailEx) {
                    System.err.println("Email prep failed: " + emailEx.getMessage());
                }
                resp.sendRedirect(req.getContextPath() + "/order-success?id=" + orderId);

            } catch (IllegalStateException e) {
                resp.sendRedirect(req.getContextPath() + "/cart");
            } catch (Exception e) {
                e.printStackTrace();
                req.setAttribute("error", "Order failed. Please try again.");
                try {
                    List<CartItem> items = cartService.getCart(user.getUserId());
                    req.setAttribute("cartItems", items);
                    req.setAttribute("cartTotal", cartService.calculateTotal(items));
                } catch (Exception ignored) {
                }
                req.getRequestDispatcher("/order/checkout.jsp").forward(req, resp);
            }
        }

        // ── Cancel order ─────────────────────────────────────────────────
        if ("/order-history".equals(uri)) {
            String action = req.getParameter("action");
            if ("cancel".equals(action)) {
                try {
                    int orderId = Integer.parseInt(req.getParameter("orderId"));
                    String reason = req.getParameter("cancelReason");

                    // Security: chỉ được hủy đơn của chính mình
                    Order order = orderDAO.getOrderDetail(orderId);
                    if (order != null && order.getUserId() == user.getUserId()
                            && order.isCancellable()) {
                        orderService.cancelOrder(orderId, order.getItems(), reason);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                resp.sendRedirect(req.getContextPath() + "/order-history?cancelled=1");
                return;
            }
        }
    }
}
