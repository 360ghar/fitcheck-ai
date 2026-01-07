/**
 * Recommendations Page
 * AI-powered outfit suggestions and style recommendations
 */

import { useState } from 'react'
import { Sparkles, Shirt, Layers, TrendingUp, Palette } from 'lucide-react'
import { useWardrobeStore } from '../../stores/wardrobeStore'

type TabType = 'match' | 'complete' | 'weather' | 'shopping'

export default function RecommendationsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('match')
  const items = useWardrobeStore((state) => state.items)

  const tabs = [
    { id: 'match' as TabType, name: 'Find Matches', icon: Shirt },
    { id: 'complete' as TabType, name: 'Complete Look', icon: Layers },
    { id: 'weather' as TabType, name: 'Weather-Based', icon: TrendingUp },
    { id: 'shopping' as TabType, name: 'Shopping', icon: Palette },
  ]

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900 flex items-center">
          <Sparkles className="h-7 w-7 text-purple-600 mr-2" />
          AI Recommendations
        </h1>
        <p className="mt-2 text-gray-600">
          Get personalized outfit suggestions powered by AI
        </p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200 mb-6">
        <nav className="flex space-x-8">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center px-1 py-4 border-b-2 font-medium text-sm transition-colors ${
                activeTab === tab.id
                  ? 'border-purple-500 text-purple-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <tab.icon className="h-4 w-4 mr-2" />
              {tab.name}
            </button>
          ))}
        </nav>
      </div>

      {/* Tab content */}
      <div className="bg-white rounded-lg shadow p-8">
        {activeTab === 'match' && (
          <div className="text-center py-12">
            <Shirt className="mx-auto h-16 w-16 text-gray-400" />
            <h3 className="mt-4 text-lg font-medium text-gray-900">Find Matching Items</h3>
            <p className="mt-2 text-sm text-gray-600">
              Select an item from your wardrobe to find matching pieces
            </p>
            <button className="mt-6 px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700">
              Browse Wardrobe
            </button>
          </div>
        )}

        {activeTab === 'complete' && (
          <div className="text-center py-12">
            <Layers className="mx-auto h-16 w-16 text-gray-400" />
            <h3 className="mt-4 text-lg font-medium text-gray-900">Complete Your Look</h3>
            <p className="mt-2 text-sm text-gray-600">
              Get AI-generated complete outfit suggestions based on selected items
            </p>
            <button className="mt-6 px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700">
              Generate Outfit
            </button>
          </div>
        )}

        {activeTab === 'weather' && (
          <div className="text-center py-12">
            <TrendingUp className="mx-auto h-16 w-16 text-gray-400" />
            <h3 className="mt-4 text-lg font-medium text-gray-900">Weather-Based Recommendations</h3>
            <p className="mt-2 text-sm text-gray-600">
              Get outfit suggestions based on your local weather
            </p>
            <button className="mt-6 px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700">
              Enable Location
            </button>
          </div>
        )}

        {activeTab === 'shopping' && (
          <div className="text-center py-12">
            <Palette className="mx-auto h-16 w-16 text-gray-400" />
            <h3 className="mt-4 text-lg font-medium text-gray-900">Shopping Recommendations</h3>
            <p className="mt-2 text-sm text-gray-600">
              Get suggestions for items that would complement your wardrobe
            </p>
            <button className="mt-6 px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700">
              Get Suggestions
            </button>
          </div>
        )}
      </div>

      {/* Tips section */}
      <div className="mt-8 bg-purple-50 rounded-lg p-6">
        <h3 className="font-medium text-purple-900 mb-2">Pro Tips</h3>
        <ul className="text-sm text-purple-800 space-y-1">
          <li>• The more items you add, the better the recommendations become</li>
          <li>• Tag your items with styles and occasions for better matches</li>
          <li>• Mark items as favorites to prioritize them in suggestions</li>
        </ul>
      </div>
    </div>
  )
}
