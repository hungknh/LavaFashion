package controller;

import dao.CartDAO;
import dao.ProductDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.Product;
import model.User;

import java.io.IOException;
import java.util.*;

@WebServlet({"/ajax/cart-count", "/ajax/search"})
public class AjaxController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-cache");
        String uri = req.getServletPath();

        try {
            if ("/ajax/cart-count".equals(uri)) {
                handleCartCount(req, resp);
            } else if ("/ajax/search".equals(uri)) {
                handleSearch(req, resp);
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"error\":\"Server error\"}");
        }
    }

    // ── GET /ajax/cart-count → {"count": 3} ──────────────────────────────
    private void handleCartCount(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        User user = (User) req.getSession().getAttribute("loggedUser");
        int count = 0;
        if (user != null) {
            int cartId = cartDAO.getOrCreateCart(user.getUserId());
            count = cartDAO.countItems(cartId);
        }
        Map<String, Integer> result = new HashMap<>();
        result.put("count", count);
        resp.getWriter().write("{\"count\":" + count + "}");
    }

    // ── GET /ajax/search?q=keyword → [{id,name,price,img}, ...] ──────────
    private void handleSearch(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String q = req.getParameter("q");
        if (q == null || q.trim().length() < 2) {
            resp.getWriter().write("[]");
            return;
        }
        // Lấy tối đa 6 kết quả
        List<Product> products = productDAO.getFiltered(
                q.trim(), null, null, null, null, null, null, null, 1, 6);

        List<Map<String, Object>> results = new ArrayList<>();
        for (Product p : products) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", p.getProductId());
            item.put("name", p.getProductName());
            item.put("price", p.getFormattedPrice());
            item.put("img", p.getDisplayImage());
            item.put("cat", p.getCategoryName() != null ? p.getCategoryName() : "");
            results.add(item);
        }
        // Build JSON manually — no external library needed
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < results.size(); i++) {
            Map<String, Object> item = results.get(i);
            json.append("{")
                    .append("\"id\":").append(item.get("id")).append(",")
                    .append("\"name\":\"").append(escapeJson(item.get("name").toString())).append("\",")
                    .append("\"price\":\"").append(escapeJson(item.get("price").toString())).append("\",")
                    .append("\"img\":\"").append(escapeJson(item.get("img").toString())).append("\",")
                    .append("\"cat\":\"").append(escapeJson(item.get("cat").toString())).append("\"")
                    .append("}");
            if (i < results.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        resp.getWriter().write(json.toString());
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

}
