import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { AnimatedSection } from './AnimatedSection'
import { ArrowRight, CheckCircle2, Loader2 } from 'lucide-react'
import { joinWaitlist } from '@/api/waitlist'

export default function CTASection() {
  const [email, setEmail] = useState('')
  const [fullName, setFullName] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isSuccess, setIsSuccess] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    setIsSubmitting(true)

    try {
      await joinWaitlist({
        email,
        full_name: fullName || undefined,
      })
      setIsSuccess(true)
      setEmail('')
      setFullName('')
    } catch (err) {
      const apiError = err as { code?: string; message?: string }
      if (apiError.code === 'WAITLIST_EMAIL_EXISTS') {
        setError('This email is already on the waitlist.')
      } else {
        setError(apiError.message || 'Something went wrong. Please try again.')
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <section className="py-20 md:py-28 bg-stone-50 dark:bg-stone-900/40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="rounded-2xl border border-stone-800 bg-stone-900 px-6 py-12 sm:px-10 sm:py-14 md:px-14 md:py-16 text-stone-50">
            <div className="grid lg:grid-cols-2 gap-10 lg:gap-16 items-start">
              <div>
                <h2 className="landing-display text-3xl sm:text-4xl font-semibold leading-tight">
                  Start free on the web. Get the Android app today.
                </h2>
                <p className="mt-4 text-stone-400 text-base md:text-lg leading-relaxed max-w-md">
                  Create an account in the browser, or install Android from Google Play. Leave your email for iOS and product updates.
                </p>
                <div className="mt-8">
                  <Button
                    size="lg"
                    className="bg-indigo-600 hover:bg-indigo-700 text-white h-12 px-6 shadow-none"
                    asChild
                  >
                    <Link to="/auth/register">
                      Start free on web
                      <ArrowRight className="ml-2 h-4 w-4" />
                    </Link>
                  </Button>
                  <p className="mt-3 text-sm text-stone-500">
                    Already have an account?{' '}
                    <Link to="/auth/login" className="text-stone-300 underline-offset-4 hover:underline">
                      Log in
                    </Link>
                  </p>
                </div>
              </div>

              <div className="rounded-xl border border-stone-700/80 bg-stone-950/50 p-6 sm:p-7">
                <p className="text-sm font-medium text-stone-200 mb-4">iOS and product updates</p>
                {isSuccess ? (
                  <div className="flex items-start gap-3 py-4">
                    <CheckCircle2 className="h-6 w-6 text-emerald-400 shrink-0 mt-0.5" />
                    <div>
                      <p className="font-medium text-stone-50">You&apos;re on the list</p>
                      <p className="text-sm text-stone-400 mt-1">
                        We&apos;ll email you about iOS availability and major product updates.
                      </p>
                    </div>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-3">
                    <div>
                      <Label htmlFor="waitlist-email" className="sr-only">
                        Email address
                      </Label>
                      <Input
                        id="waitlist-email"
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                        disabled={isSubmitting}
                        className="h-11 bg-stone-900 border-stone-700 text-stone-50 placeholder:text-stone-500 focus-visible:ring-indigo-500"
                      />
                    </div>
                    <div>
                      <Label htmlFor="waitlist-name" className="sr-only">
                        Full name (optional)
                      </Label>
                      <Input
                        id="waitlist-name"
                        type="text"
                        placeholder="Name (optional)"
                        value={fullName}
                        onChange={(e) => setFullName(e.target.value)}
                        disabled={isSubmitting}
                        className="h-11 bg-stone-900 border-stone-700 text-stone-50 placeholder:text-stone-500 focus-visible:ring-indigo-500"
                      />
                    </div>
                    {error && (
                      <p className="text-sm text-red-300 bg-red-950/40 rounded-lg px-3 py-2">
                        {error}
                      </p>
                    )}
                    <Button
                      type="submit"
                      disabled={isSubmitting || !email}
                      className="w-full h-11 bg-white text-stone-900 hover:bg-stone-100 font-medium shadow-none"
                    >
                      {isSubmitting ? (
                        <>
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                          Joining...
                        </>
                      ) : (
                        'Get updates'
                      )}
                    </Button>
                  </form>
                )}
              </div>
            </div>
          </div>
        </AnimatedSection>
      </div>
    </section>
  )
}
