/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.*;
import java.time.LocalDate;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.*;

import java.io.IOException;
import java.util.List;

@WebServlet({"/admin", "/admin/products", "/admin/product-form",
    "/admin/product-delete", "/admin/users", "/admin/user-action",
    "/admin/orders", "/admin/order-update", "/admin/product-image-delete",
    "/admin/statistics"})
public class AdminController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final UserDAO userDAO = new UserDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final StatisticsDAO statisticsDAO = new StatisticsDAO();

    private static final int PAGE_SIZE = 10;

    // ── Guard: chỉ admin mới vào được ─────────────────────────────────────
    private boolean isAdmin(HttpServletRequest req) {
        User u = (User) req.getSession().getAttribute("loggedUser");
        return u != null && u.isAdmin();
    }

    // ── GET ───────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        String uri = req.getServletPath();

        try {
            switch (uri) {
                case "/admin":
                    handleDashboard(req, resp);
                    break;
                case "/admin/products":
                    handleProductList(req, resp);
                    break;
                case "/admin/product-form":
                    handleProductForm(req, resp);
                    break;
                case "/admin/users":
                    handleUserList(req, resp);
                    break;
                case "/admin/orders":
                    handleOrderList(req, resp);
                    break;
                case "/admin/statistics":
                    handleStatistics(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        String uri = req.getServletPath();

        try {
            switch (uri) {
                case "/admin/product-form":
                    handleProductSave(req, resp);
                    break;
                case "/admin/product-delete":
                    handleProductDelete(req, resp);
                    break;
                case "/admin/user-action":
                    handleUserAction(req, resp);
                    break;
                case "/admin/order-update":
                    handleOrderUpdate(req, resp);
                    break;
                case "/admin/product-image-delete":
                    handleImageDelete(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // DASHBOARD
    // ══════════════════════════════════════════════════════════════════════
    private void handleDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        // Quick stats
        int totalProducts = productDAO.countAll();
        int totalUsers = userDAO.countAll();
        int totalOrders = orderDAO.countAllOrders();
        req.setAttribute("totalProducts", totalProducts);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("totalOrders", totalOrders);

        // 5 đơn mới nhất
        List<Order> recentOrders = orderDAO.getAllOrders(1, 5);
        req.setAttribute("recentOrders", recentOrders);

        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }

    // ══════════════════════════════════════════════════════════════════════
    // PRODUCTS
    // ══════════════════════════════════════════════════════════════════════
    private void handleProductList(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int page = getPage(req);
        String keyword = req.getParameter("keyword");

        List<Product> products;
        int total;
        if (keyword != null && !keyword.trim().isEmpty()) {
            products = productDAO.getFiltered(keyword.trim(), null, null, null, null, null, null, null, page, PAGE_SIZE);
            total = productDAO.countFiltered(keyword.trim(), null, null, null, null, null, null);
        } else {
            products = productDAO.getAllForAdmin(page, PAGE_SIZE);
            total = productDAO.countAll();
        }

        req.setAttribute("products", products);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.setAttribute("keyword", keyword);
        req.getRequestDispatcher("/admin/product-manager.jsp").forward(req, resp);
    }

    private void handleProductForm(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String idStr = req.getParameter("id");
        if (idStr != null) {
            Product p = productDAO.findById(Integer.parseInt(idStr));
            p.setImages(productDAO.getImageUrls(p.getProductId()));
            req.setAttribute("product", p);
        }
        req.setAttribute("categories", categoryDAO.getAll());
        req.setAttribute("brands", brandDAO.getAll());
        req.getRequestDispatcher("/admin/product-form.jsp").forward(req, resp);
    }

    private void handleProductSave(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String idStr = req.getParameter("productId");
        boolean isEdit = idStr != null && !idStr.isEmpty();

        Product p = new Product();
        if (isEdit) {
            p.setProductId(Integer.parseInt(idStr));
        }
        p.setProductName(req.getParameter("productName"));
        p.setDescription(req.getParameter("description"));
        p.setPrice(Double.parseDouble(req.getParameter("price")));
        p.setStock(Integer.parseInt(req.getParameter("stock")));
        p.setCategoryId(Integer.parseInt(req.getParameter("categoryId")));
        p.setBrandId(Integer.parseInt(req.getParameter("brandId")));
        p.setColor(req.getParameter("color"));
        p.setProductType(req.getParameter("productType"));
        p.setActive(true);

        String imageUrl = req.getParameter("imageUrl");

        // Đọc stock per size
        String[] sizeNames = {"S", "M", "L", "XL", "XXL"};
        java.util.LinkedHashMap<String, Integer> sizeMap = new java.util.LinkedHashMap<>();
        int totalStock = 0;
        for (String sz : sizeNames) {
            String val = req.getParameter("size_" + sz);
            int qty = 0;
            try {
                qty = Integer.parseInt(val);
            } catch (Exception e) {
            }
            sizeMap.put(sz, qty);
            totalStock += qty;
        }
        p.setStock(totalStock);

        if (isEdit) {
            productDAO.update(p);
            productDAO.updateSizeStocks(p.getProductId(), sizeMap);
            if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                productDAO.addImage(p.getProductId(), imageUrl.trim(), true);
            }
            req.getSession().setAttribute("adminSuccess", "Product updated successfully!");
        } else {
            int newId = productDAO.insert(p);
            if (newId > 0) {
                productDAO.updateSizeStocks(newId, sizeMap);
                if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                    productDAO.addImage(newId, imageUrl.trim(), true);
                }
            }
            req.getSession().setAttribute("adminSuccess", "Product added successfully!");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    private void handleProductDelete(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int productId = Integer.parseInt(req.getParameter("productId"));
        String action = req.getParameter("action");
        if ("restore".equals(action)) {
            productDAO.restore(productId);
            req.getSession().setAttribute("adminSuccess", "Product restored.");
        } else {
            productDAO.softDelete(productId);
            req.getSession().setAttribute("adminSuccess", "Product hidden from store.");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    // ══════════════════════════════════════════════════════════════════════
    // USERS
    // ══════════════════════════════════════════════════════════════════════
    private void handleUserList(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int page = getPage(req);
        List<User> users = userDAO.getAll(page, PAGE_SIZE);
        int total = userDAO.countAll();

        req.setAttribute("users", users);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.getRequestDispatcher("/admin/user-manager.jsp").forward(req, resp);
    }

    private void handleUserAction(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int userId = Integer.parseInt(req.getParameter("userId"));
        String action = req.getParameter("action");

        // Không cho phép admin tự xóa/disable chính mình
        User me = (User) req.getSession().getAttribute("loggedUser");
        if (userId == me.getUserId()) {
            req.getSession().setAttribute("adminError", "You cannot modify your own account.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        if ("toggle".equals(action)) {
            userDAO.toggleActive(userId);
        } else if ("delete".equals(action)) {
            userDAO.deleteUser(userId);
            req.getSession().setAttribute("adminSuccess", "User deleted.");
        } else if ("setRole".equals(action)) {
            int roleId = Integer.parseInt(req.getParameter("roleId"));
            userDAO.updateRole(userId, roleId);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    // ══════════════════════════════════════════════════════════════════════
    // ORDERS
    // ══════════════════════════════════════════════════════════════════════
    private void handleOrderList(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int page = getPage(req);
        List<Order> orders = orderDAO.getAllOrders(page, PAGE_SIZE);
        int total = orderDAO.countAllOrders();

        req.setAttribute("orders", orders);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.getRequestDispatcher("/admin/order-manager.jsp").forward(req, resp);
    }

    private void handleOrderUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int orderId = Integer.parseInt(req.getParameter("orderId"));
        String action = req.getParameter("action");

        if ("updateStatus".equals(action)) {
            String newStatus = req.getParameter("status");
            orderDAO.updateStatus(orderId, newStatus);
            req.getSession().setAttribute("adminSuccess", "Order #" + orderId + " updated to " + newStatus);
        } else if ("markPaid".equals(action)) {
            orderDAO.updatePaymentStatus(orderId, "Paid");
            req.getSession().setAttribute("adminSuccess", "Order #" + orderId + " marked as Paid.");
        } else if ("markUnpaid".equals(action)) {
            orderDAO.updatePaymentStatus(orderId, "Unpaid");
            req.getSession().setAttribute("adminSuccess", "Order #" + orderId + " marked as Unpaid.");
        } else if ("delete".equals(action)) {
            orderDAO.deleteOrder(orderId);
            req.getSession().setAttribute("adminSuccess", "Order #" + orderId + " deleted.");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/orders");
    }

    // ── Util ──────────────────────────────────────────────────────────────
    private void handleImageDelete(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int productId = Integer.parseInt(req.getParameter("productId"));
        String imageUrl = req.getParameter("imageUrl");
        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            productDAO.deleteImage(productId, imageUrl.trim());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/product-form?id=" + productId);
    }

    private int getPage(HttpServletRequest req) {
        try {
            return Math.max(1, Integer.parseInt(req.getParameter("page")));
        } catch (Exception e) {
            return 1;
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // STATISTICS
    // ══════════════════════════════════════════════════════════════════════
    private void handleStatistics(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int currentYear = java.time.LocalDate.now().getYear();
        int currentMonth = java.time.LocalDate.now().getMonthValue();

        int year = currentYear;
        int month = currentMonth;
        try {
            year = Integer.parseInt(req.getParameter("year"));
        } catch (Exception e) {
        }
        try {
            month = Integer.parseInt(req.getParameter("month"));
        } catch (Exception e) {
        }

        req.setAttribute("revenueByMonth", statisticsDAO.getRevenueByMonth(year));
        req.setAttribute("revenueByDay", statisticsDAO.getRevenueByDay(year, month));
        req.setAttribute("topSelling", statisticsDAO.getTopSellingProducts(5));
        req.setAttribute("topRated", statisticsDAO.getTopRatedProducts(5));
        req.setAttribute("productByCategory", statisticsDAO.getProductCountByCategory());
        req.setAttribute("newCustomers", statisticsDAO.getNewCustomersByMonth(year));
        req.setAttribute("orderByStatus", statisticsDAO.getOrderCountByStatus());
        req.setAttribute("totalRevYear", statisticsDAO.getTotalRevenueByYear(year));
        req.setAttribute("totalRevMonth", statisticsDAO.getTotalRevenueByMonth(year, month));
        req.setAttribute("selectedYear", year);
        req.setAttribute("selectedMonth", month);
        req.setAttribute("currentYear", currentYear);

        req.getRequestDispatcher("/admin/statistics.jsp").forward(req, resp);
    }

}
