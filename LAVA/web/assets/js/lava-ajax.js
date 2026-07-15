/* ================================================================
 lava-ajax.js  —  Cart badge + Live search
 Include vào mọi trang: <script src="/assets/js/lava-ajax.js">
 ================================================================ */

const CONTEXT_PATH = document.documentElement.dataset.ctx || '';

/* ── 1. CART BADGE AUTO-UPDATE ─────────────────────────────────────── */
function updateCartBadge() {
    fetch(CONTEXT_PATH + '/ajax/cart-count')
            .then(r => r.json())
            .then(data => {
                const badge = document.getElementById('cartBadge');
                if (!badge)
                    return;
                const n = data.count || 0;
                badge.textContent = n;
                if (n > 0) {
                    badge.classList.add('cart-badge-show');
                } else {
                    badge.classList.remove('cart-badge-show');
                }
            })
            .catch(() => {
            });
}

/* ── 2. LIVE SEARCH ─────────────────────────────────────────────────── */
function initLiveSearch() {
    const input = document.getElementById('searchInput');
    const dropdown = document.getElementById('searchDropdown');
    if (!input || !dropdown)
        return;

    let debounceTimer;

    input.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        const q = this.value.trim();

        if (q.length < 2) {
            dropdown.style.display = 'none';
            return;
        }

        debounceTimer = setTimeout(() => {
            fetch(CONTEXT_PATH + '/ajax/search?q=' + encodeURIComponent(q))
                    .then(r => r.json())
                    .then(items => {
                        if (!items.length) {
                            dropdown.style.display = 'none';
                            return;
                        }

                        dropdown.innerHTML = items.map(p => `
                        <a href="${CONTEXT_PATH}/product?id=${p.id}" class="search-item">
                            <img src="${CONTEXT_PATH}/${p.img}" alt="${p.name}"
                                 onerror="this.src='${CONTEXT_PATH}/assets/images/placeholder.jpg'">
                            <div class="search-item-info">
                                <div class="search-item-name">${p.name}</div>
                                <div class="search-item-meta">${p.cat} &nbsp;·&nbsp; ${p.price}</div>
                            </div>
                        </a>
                    `).join('');

                        // Footer link
                        dropdown.innerHTML += `
                        <a href="${CONTEXT_PATH}/products?keyword=${encodeURIComponent(q)}"
                           class="search-see-all">
                           View all results for "<strong>${q}</strong>" →
                        </a>`;

                        dropdown.style.display = 'block';
                    })
                    .catch(() => {
                        dropdown.style.display = 'none';
                    });
        }, 250); // debounce 250ms
    });

    // Đóng dropdown khi click ngoài
    document.addEventListener('click', function (e) {
        if (!input.contains(e.target) && !dropdown.contains(e.target)) {
            dropdown.style.display = 'none';
        }
    });

    // Submit form khi nhấn Enter
    input.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            window.location.href = CONTEXT_PATH + '/products?keyword=' + encodeURIComponent(this.value.trim());
        }
    });
}

/* ── INIT ──────────────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', function () {
    updateCartBadge();
    initLiveSearch();
});