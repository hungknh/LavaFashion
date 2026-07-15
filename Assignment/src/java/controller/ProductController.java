package controller;

import dao.BrandDAO;
import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.Brand;
import model.Category;
import model.Product;

import java.io.IOException;
import java.util.List;

@WebServlet("/products")
public class ProductController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    private static final int PAGE_SIZE = 9;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Read all filter/search/sort params ──────────────────────────
        String keyword = req.getParameter("keyword");
        String sortBy = req.getParameter("sortBy");
        String productType = req.getParameter("productType"); // featured | new | best_seller
        String color = req.getParameter("color");
        int page = parseIntOrDefault(req.getParameter("page"), 1);
        int categoryId = parseIntOrDefault(req.getParameter("categoryId"), 0);
        int brandId = parseIntOrDefault(req.getParameter("brandId"), 0);
        Double minPrice = parseDoubleOrNull(req.getParameter("minPrice"));
        Double maxPrice = parseDoubleOrNull(req.getParameter("maxPrice"));

        if (page < 1) {
            page = 1;
        }

        try {
            // ── Query DB ─────────────────────────────────────────────────
            List<Product> products = productDAO.getFiltered(
                    keyword,
                    categoryId > 0 ? categoryId : null,
                    brandId > 0 ? brandId : null,
                    minPrice, maxPrice,
                    productType, color,
                    sortBy, page, PAGE_SIZE);

            int totalProducts = productDAO.countFiltered(
                    keyword,
                    categoryId > 0 ? categoryId : null,
                    brandId > 0 ? brandId : null,
                    minPrice, maxPrice,
                    productType, color);

            int totalPages = (int) Math.ceil((double) totalProducts / PAGE_SIZE);
            if (totalPages < 1) {
                totalPages = 1;
            }

            List<Category> categories = categoryDAO.getAll();
            List<Brand> brands = brandDAO.getAll();
            List<String> colors = productDAO.getDistinctColors();

            // ── Pass to JSP ───────────────────────────────────────────────
            req.setAttribute("products", products);
            req.setAttribute("categories", categories);
            req.setAttribute("brands", brands);
            req.setAttribute("colors", colors);
            req.setAttribute("totalProducts", totalProducts);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("currentPage", page);
            req.setAttribute("keyword", keyword != null ? keyword : "");
            req.setAttribute("sortBy", sortBy != null ? sortBy : "");
            req.setAttribute("productType", productType != null ? productType : "");
            req.setAttribute("color", color != null ? color : "");
            req.setAttribute("categoryId", categoryId);
            req.setAttribute("brandId", brandId);
            req.setAttribute("minPrice", minPrice);
            req.setAttribute("maxPrice", maxPrice);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load products. Please try again.");
        }

        req.getRequestDispatcher("/product/product-list.jsp").forward(req, resp);
    }

    private int parseIntOrDefault(String val, int def) {
        try {
            return (val != null && !val.isEmpty()) ? Integer.parseInt(val) : def;
        } catch (NumberFormatException e) {
            return def;
        }
    }

    private Double parseDoubleOrNull(String val) {
        try {
            return (val != null && !val.isEmpty()) ? Double.parseDouble(val) : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
