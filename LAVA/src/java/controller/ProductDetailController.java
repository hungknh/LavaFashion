/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ProductDAO;
import dao.ReviewDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.Product;
import model.Review;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet("/product")
public class ProductDetailController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        try {
            int productId = Integer.parseInt(idParam);
            Product product = productDAO.findById(productId);

            if (product == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found.");
                return;
            }

            // Reviews + similar products
            List<Review> reviews = reviewDAO.getByProductId(productId);
            List<Product> similar = productDAO.getSimilar(product.getCategoryId(), productId, 4);

            // Check if logged-in user already reviewed
            User loggedUser = (User) req.getSession().getAttribute("loggedUser");
            boolean alreadyReviewed = false;
            if (loggedUser != null) {
                alreadyReviewed = reviewDAO.hasReviewed(loggedUser.getUserId(), productId);
            }

            req.setAttribute("product", product);
            req.setAttribute("reviews", reviews);
            req.setAttribute("similar", similar);
            req.setAttribute("alreadyReviewed", alreadyReviewed);

            // Pass cart items so JSP can calculate remaining stock per size
            if (loggedUser != null) {
                try {
                    service.CartService cartService = new service.CartService();
                    java.util.List<model.CartItem> cartItemsForCheck
                            = cartService.getCart(loggedUser.getUserId());
                    req.setAttribute("cartItemsForCheck", cartItemsForCheck);
                } catch (Exception ignored) {
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load product.");
        }

        req.getRequestDispatcher("/product/product-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Handle review submission
        User loggedUser = (User) req.getSession().getAttribute("loggedUser");
        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            return;
        }

        try {
            int productId = Integer.parseInt(req.getParameter("productId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");

            if (!reviewDAO.hasReviewed(loggedUser.getUserId(), productId)) {
                Review review = new Review();
                review.setProductId(productId);
                review.setUserId(loggedUser.getUserId());
                review.setRating(rating);
                review.setComment(comment != null ? comment.trim() : "");
                reviewDAO.add(review);
                reviewDAO.updateProductRating(productId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath() + "/product?id=" + req.getParameter("productId"));
    }
}
