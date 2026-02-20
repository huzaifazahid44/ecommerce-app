// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import * as Turbo from "@hotwired/turbo-rails"
window.Turbo = Turbo  // expose globally so browser console can inspect it

import "controllers"
import "@tailwindplus/elements"
