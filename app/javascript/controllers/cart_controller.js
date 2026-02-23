import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  add(event) {
    try {
      const form = event.target;
      // disable submit to avoid double-clicks
      const submit = form.querySelector('input[type="submit"], button[type="submit"]');
      if (submit) submit.disabled = true;
    } catch (e) {
      console.debug('cart controller add error', e);
    }
  }

  remove(event) {
    try {
      // No manual badge update; Turbo Stream will handle UI
    } catch (e) {
      console.debug('cart controller remove error', e);
    }
  }
}
