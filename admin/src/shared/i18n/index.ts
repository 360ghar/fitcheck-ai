import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'

// Feature namespaces — JSON files are created by the owning feature; the
// registry imports them so a missing file fails typecheck loudly.
import audit from './en/audit.json'
import auth from './en/auth.json'
import common from './en/common.json'
import components from './en/components.json'
import content from './en/content.json'
import dashboard from './en/dashboard.json'
import dataTable from './en/dataTable.json'
import errors from './en/errors.json'
import feedback from './en/feedback.json'
import iap from './en/iap.json'
import layout from './en/layout.json'
import ops from './en/ops.json'
import placeholder from './en/placeholder.json'
import promo from './en/promo.json'
import quotas from './en/quotas.json'
import search from './en/search.json'
import settings from './en/settings.json'
import subscriptions from './en/subscriptions.json'
import users from './en/users.json'

/**
 * i18next bootstrap — English default, keys from day 1 (spec §12). Adding a
 * locale = adding a `resources/<locale>/*.json` block; no component changes.
 * Interpolation escaping is off because React escapes output anyway.
 */
void i18n.use(initReactI18next).init({
  resources: {
    en: {
      common,
      auth,
      layout,
      errors,
      dataTable,
      components,
      placeholder,
      users,
      dashboard,
      audit,
      quotas,
      search,
      subscriptions,
      iap,
      promo,
      feedback,
      ops,
      settings,
      content,
    },
  },
  lng: 'en',
  fallbackLng: 'en',
  interpolation: {
    escapeValue: false,
  },
  returnNull: false,
})

export default i18n
