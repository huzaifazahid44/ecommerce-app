import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  add(event) {
    try {
      const form = event.target
      const qtyInput = form.querySelector('input[name="quantity"]') || form.querySelector('input[type="number"]')
      const qty = qtyInput ? parseInt(qtyInput.value, 10) || 1 : 1
      const badge = document.getElementById('cart_count')
      if (badge) {
        const current = parseInt(badge.textContent.replace(/\D/g, '')) || 0
        badge.textContent = String(current + qty)
      }
      // disable submit to avoid double-clicks
      const submit = form.querySelector('input[type="submit"], button[type="submit"]')
      if (submit) submit.disabled = true
    } catch (e) {
      console.debug('cart controller add error', e)
    }
  }

  remove(event) {
    try {
      const form = event.target
      // try to find qty on the same item row
      const row = form.closest('[data-cart-item]')
      let qty = 1
      if (row) {
        const qtySpan = row.querySelector('[data-cart-quantity]')
        if (qtySpan) qty = parseInt(qtySpan.textContent.replace(/\D/g,'')) || 1
      }
      const badge = document.getElementById('cart_count')
      if (badge) {
        const current = parseInt(badge.textContent.replace(/\D/g, '')) || 0
        const next = Math.max(0, current - qty)
        badge.textContent = String(next)
      }
    } catch (e) {
      console.debug('cart controller remove error', e)
    }
  }
}
