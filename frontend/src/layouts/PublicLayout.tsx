import { Outlet } from 'react-router-dom'
import Navbar from '../components/landing/Navbar'
import Footer from '../components/landing/Footer'

export default function PublicLayout() {
  return (
    <div className="min-h-screen flex flex-col bg-stone-50 dark:bg-stone-950">
      <Navbar />
      <main className="flex-1">
        <Outlet />
      </main>
      <Footer />
    </div>
  )
}
