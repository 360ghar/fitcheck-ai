import { Link } from 'react-router-dom'
import { Shirt, Twitter, Instagram, Linkedin, Mail, Phone } from 'lucide-react'

const footerLinks = {
  Product: [
    { name: 'All features', href: '/features' },
    { name: 'AI Wardrobe Extraction', href: '/features/ai-wardrobe-extraction' },
    { name: 'Virtual Try-On', href: '/features/virtual-try-on' },
    { name: 'AI Photoshoot', href: '/features/ai-photoshoot-generator' },
    { name: 'Outfit Recommendations', href: '/features/outfit-recommendations' },
    { name: 'FAQ', href: '/faq' },
    {
      name: 'Android app',
      href: 'https://play.google.com/store/apps/details?id=com.fitcheckaiapp.fitcheckai&hl=en_IN',
    },
  ],
  Resources: [
    { name: 'Blog', href: '/blog' },
    { name: 'What to wear today', href: '/guides/what-to-wear-today' },
    { name: 'Digitize your wardrobe', href: '/guides/how-to-digitize-your-wardrobe' },
    { name: 'Best virtual closet apps', href: '/best/virtual-closet-apps' },
    { name: 'Acloset alternatives', href: '/alternatives/acloset-alternatives' },
  ],
  Company: [
    { name: 'About', href: '/about' },
    { name: 'For professionals', href: '/for/busy-professionals' },
    { name: 'Festive & wedding', href: '/for/festive-and-wedding-outfits' },
    { name: 'Contact', href: 'mailto:info@fitcheckaiapp.com' },
  ],
  Legal: [
    { name: 'Terms of Service', href: '/terms' },
    { name: 'Privacy Policy', href: '/privacy' },
  ],
}

const socialLinks = [
  { name: 'Twitter', href: '#', icon: Twitter },
  { name: 'Instagram', href: '#', icon: Instagram },
  { name: 'LinkedIn', href: '#', icon: Linkedin },
]

export default function Footer() {
  return (
    <footer className="bg-stone-950 text-stone-400 pt-14 pb-8 border-t border-stone-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid md:grid-cols-2 lg:grid-cols-5 gap-10 mb-12">
          <div className="lg:col-span-2">
            <Link to="/" className="flex items-center gap-2.5 mb-4">
              <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center">
                <Shirt className="w-4 h-4 text-white" />
              </div>
              <span className="text-lg font-semibold tracking-tight text-stone-50">
                FitCheck<span className="font-normal text-stone-500"> AI</span>
              </span>
            </Link>
            <p className="max-w-xs text-sm leading-relaxed">
              Photograph your clothes. Get outfits that fit the day. A quieter way to use what you own.
            </p>
            <div className="flex gap-4 mt-5">
              {socialLinks.map((social) => (
                <a
                  key={social.name}
                  href={social.href}
                  className="hover:text-stone-100 transition-colors"
                  aria-label={social.name}
                >
                  <social.icon className="w-5 h-5" />
                </a>
              ))}
            </div>
            <div className="mt-6 space-y-2 text-sm">
              <a
                href="mailto:info@fitcheckaiapp.com"
                className="flex items-center gap-2 hover:text-stone-100 transition-colors"
              >
                <Mail className="w-4 h-4" />
                <span>info@fitcheckaiapp.com</span>
              </a>
              <a
                href="https://wa.me/919310833204"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 hover:text-stone-100 transition-colors"
              >
                <Phone className="w-4 h-4" />
                <span>+91 9310833204</span>
              </a>
            </div>
          </div>

          {Object.entries(footerLinks).map(([category, links]) => (
            <div key={category}>
              <h3 className="font-medium text-stone-100 text-sm mb-4">{category}</h3>
              <ul className="space-y-2.5 text-sm">
                {links.map((link) => (
                  <li key={link.name}>
                    {link.href.startsWith('/') ? (
                      <Link to={link.href} className="hover:text-stone-100 transition-colors">
                        {link.name}
                      </Link>
                    ) : (
                      <a href={link.href} className="hover:text-stone-100 transition-colors">
                        {link.name}
                      </a>
                    )}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="border-t border-stone-900 pt-6 flex flex-col md:flex-row justify-between items-center gap-3">
          <p className="text-xs text-stone-500">
            &copy; {new Date().getFullYear()} FitCheck AI. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  )
}
