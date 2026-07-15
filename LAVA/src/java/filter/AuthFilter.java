/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebFilter(urlPatterns = {
    "/cart",
    "/cart/*",
    "/checkout",
    "/order-success",
    "/order-history",
    "/profile",
    "/edit-profile",
    "/review",
    "/auth?action=changeForm"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session    = req.getSession(false);
        boolean     isLoggedIn = (session != null && session.getAttribute("loggedUser") != null);

        if (!isLoggedIn) {
            // Save the original URL so we can redirect back after login
            String originalUrl = req.getRequestURI();
            String query       = req.getQueryString();
            if (query != null) originalUrl += "?" + query;

            // Store it in session to redirect after login (optional but nice UX)
            req.getSession(true).setAttribute("redirectAfterLogin", originalUrl);

            resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            return;
        }

        // User is logged in → continue
        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}