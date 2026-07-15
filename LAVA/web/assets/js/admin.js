/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// ── Confirm delete ────────────────────────────────────────────────────────
function confirmDelete(form, msg) {
    if (confirm(msg || "Are you sure you want to delete this item?")) {
        form.submit();
    }
}

// ── Image preview ─────────────────────────────────────────────────────────
function previewImage(input, previewId) {
    var url = input.value.trim();
    var preview = document.getElementById(previewId);
    if (!preview)
        return;
    if (url) {
        preview.src = url;
        preview.style.display = "block";
    } else {
        preview.style.display = "none";
    }
}

// ── Toast auto-hide ───────────────────────────────────────────────────────
document.addEventListener("DOMContentLoaded", function () {
    var toast = document.getElementById("adminToast");
    if (toast) {
        setTimeout(function () {
            toast.style.opacity = "0";
            setTimeout(function () {
                toast.style.display = "none";
            }, 400);
        }, 3000);
    }
});

// ── Status color update on select change ─────────────────────────────────
function onStatusChange(select) {
    var val = select.value;
    var colors = {
        "Pending": "#fff3cd",
        "Processing": "#cce5ff",
        "Shipped": "#d4edda",
        "Delivered": "#d1e7dd",
        "Cancelled": "#f8d7da"
    };
    select.style.background = colors[val] || "#fff";
}
