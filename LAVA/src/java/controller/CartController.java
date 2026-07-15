/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.CartItem;
import model.User;
import service.CartService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/cart")
public class CartController extends HttpServlet {

    private final CartService cartService = new CartService();

    // ── GET /cart → hiển thị giỏ hàng ────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            return;
        }

        try {
            List<CartItem> items = cartService.getCart(user.getUserId());
            double total = cartService.calculateTotal(items);
            req.setAttribute("cartItems", items);
            req.setAttribute("cartTotal", total);
        } catch (SQLException e) {
            req.setAttribute("cartItems", new java.util.ArrayList<>());
            req.setAttribute("cartTotal", 0.0);
        }

        req.getRequestDispatcher("/cart/cart.jsp").forward(req, resp);
    }

    // ── POST /cart → xử lý add / update / remove ─────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("loggedUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            return;
        }

        String action = req.getParameter("action");
        String redirectTo = req.getContextPath() + "/cart";

        try {
            switch (action == null ? "" : action) {

                case "add" -> {
                    int productId = Integer.parseInt(req.getParameter("productId"));
                    String size = req.getParameter("selectedSize");
                    int qty = Integer.parseInt(req.getParameter("quantity"));

                    if (size == null || size.trim().isEmpty()) {
                        size = "M";
                    }

                    String err = cartService.addToCart(user.getUserId(), productId, size, qty);
                    if (err != null) {
                        // Redirect back to product page with error
                        resp.sendRedirect(req.getContextPath()
                                + "/product?id=" + productId + "&cartError=" + err);
                        return;
                    }
                    // Redirect back to product page with success
                    resp.sendRedirect(req.getContextPath()
                            + "/product?id=" + productId + "&cartSuccess=1");
                    return;
                }

                case "update" ->  {
                    int cartItemId = Integer.parseInt(req.getParameter("cartItemId"));
                    int qty = Integer.parseInt(req.getParameter("quantity"));
                    cartService.updateQuantity(cartItemId, qty);
                }

                case "remove" ->  {
                    int cartItemId = Integer.parseInt(req.getParameter("cartItemId"));
                    cartService.removeItem(cartItemId);
                }
            }
        } catch (IOException | NumberFormatException | SQLException e) {
        }

        resp.sendRedirect(redirectTo);
    }
}
