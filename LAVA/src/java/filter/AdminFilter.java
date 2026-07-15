/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import model.User;
import java.io.IOException;

@WebFilter("/admin/*")
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("loggedUser") != null);

        // Case 1: Not logged in → redirect to login
        if (!isLoggedIn) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            return;
        }

        // Case 2: Logged in but not ADMIN → redirect to home with error
        User loggedUser = (User) session.getAttribute("loggedUser");
        if (!loggedUser.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/home?error=forbidden");
            return;
        }

        // Case 3: Is ADMIN → continue
        chain.doFilter(request, response);
    }

    @Override
    public void init(FilterConfig fc) {
    }

    @Override
    public void destroy() {
    }
}
