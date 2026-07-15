package controller;

import dao.OrderDAO;
import dao.ReviewDAO;
import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.Order;
import model.Review;
import model.User;
import utils.PasswordUtils;

import java.io.IOException;
import java.util.List;

@WebServlet({"/profile", "/edit-profile", "/review"})
public class UserController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    // ── GET ───────────────────────────────────────────────────────────────
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
            // Luôn refresh từ DB để hiển thị dữ liệu mới nhất
            User fresh = userDAO.findById(user.getUserId());
            if (fresh != null) {
                req.getSession().setAttribute("loggedUser", fresh);
                user = fresh;
            }

            if ("/profile".equals(uri)) {
                // Lấy 5 đơn hàng gần nhất
                List<Order> orders = orderDAO.getOrdersByUserId(user.getUserId());
                if (orders.size() > 5) {
                    orders = orders.subList(0, 5);
                }
                for (Order o : orders) {
                    o.setItems(orderDAO.getOrderItems(o.getOrderId()));
                }
                req.setAttribute("recentOrders", orders);
                req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);

            } else if ("/edit-profile".equals(uri)) {
                req.getRequestDispatcher("/user/edit-profile.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            return;
        }

        String uri = req.getServletPath();

        // ── POST /edit-profile ────────────────────────────────────────────
        if ("/edit-profile".equals(uri)) {
            String fullName = req.getParameter("fullName");
            String phone = req.getParameter("phone");
            String email = req.getParameter("email");

            // Validate server-side
            if (fullName == null || fullName.trim().isEmpty()) {
                req.setAttribute("error", "Full name is required.");
                req.getRequestDispatcher("/user/edit-profile.jsp").forward(req, resp);
                return;
            }
            if (email == null || !email.trim().toLowerCase().endsWith("@gmail.com")) {
                req.setAttribute("error", "Email must be a valid Gmail address (e.g. example@gmail.com).");
                req.getRequestDispatcher("/user/edit-profile.jsp").forward(req, resp);
                return;
            }
            if (phone != null && !phone.trim().isEmpty()
                    && !phone.trim().matches("^0[0-9]{9}$")) {
                req.setAttribute("error", "Phone must be exactly 10 digits and start with 0 (e.g. 0912345678).");
                req.getRequestDispatcher("/user/edit-profile.jsp").forward(req, resp);
                return;
            }

            // Kiểm tra email trùng với user khác
            try {
                User existing = userDAO.findByEmail(email.trim());
                if (existing != null && existing.getUserId() != user.getUserId()) {
                    req.setAttribute("error", "Email is already in use by another account.");
                    req.getRequestDispatcher("/user/edit-profile.jsp").forward(req, resp);
                    return;
                }

                userDAO.updateProfile(user.getUserId(),
                        fullName.trim(),
                        phone != null ? phone.trim() : "",
                        email.trim());

                // Refresh session
                User updated = userDAO.findById(user.getUserId());
                req.getSession().setAttribute("loggedUser", updated);
                req.getSession().setAttribute("profileSuccess", "Profile updated successfully!");
                resp.sendRedirect(req.getContextPath() + "/profile");

            } catch (Exception e) {
                e.printStackTrace();
                req.setAttribute("error", "Update failed. Please try again.");
                req.getRequestDispatcher("/user/edit-profile.jsp").forward(req, resp);
            }
        } // ── POST /review ──────────────────────────────────────────────────
        else if ("/review".equals(uri)) {
            String pidStr = req.getParameter("productId");
            String rateStr = req.getParameter("rating");
            String comment = req.getParameter("comment");

            if (pidStr == null || rateStr == null) {
                resp.sendRedirect(req.getContextPath() + "/products");
                return;
            }

            try {
                int productId = Integer.parseInt(pidStr);
                int rating = Integer.parseInt(rateStr);

                if (!reviewDAO.hasReviewed(user.getUserId(), productId)) {
                    Review review = new Review();
                    review.setProductId(productId);
                    review.setUserId(user.getUserId());
                    review.setRating(rating);
                    review.setComment(comment != null ? comment.trim() : "");
                    reviewDAO.add(review);
                    reviewDAO.updateProductRating(productId);
                }
                resp.sendRedirect(req.getContextPath() + "/product?id=" + productId + "#reviews");

            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/products");
            }
        }
    }
}
