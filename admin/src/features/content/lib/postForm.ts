import { z } from 'zod'

import type { BlogPost } from '@/features/content/api/blog'

/**
 * Blog post form schema + pure helpers (ported from the old frontend blog
 * admin; messages are injected so i18n keys stay in the feature namespace).
 */

export interface PostFormMessages {
  titleRequired: string
  titleMax: string
  slugRequired: string
  slugFormat: string
  slugMax: string
  excerptRequired: string
  excerptMax: string
  contentRequired: string
  categoryRequired: string
  emojiRequired: string
  emojiMax: string
  authorRequired: string
  dateRequired: string
  featuredImageUrl: string
  keywordsMin: string
}

export function postFormSchema(messages: PostFormMessages) {
  return z.object({
    title: z.string().min(1, messages.titleRequired).max(200, messages.titleMax),
    slug: z
      .string()
      .min(1, messages.slugRequired)
      .max(255, messages.slugMax)
      .regex(/^[a-z0-9-]+$/, messages.slugFormat),
    excerpt: z.string().min(1, messages.excerptRequired).max(500, messages.excerptMax),
    content: z.string().min(1, messages.contentRequired),
    category: z.string().min(1, messages.categoryRequired).max(100, messages.categoryRequired),
    emoji: z.string().min(1, messages.emojiRequired).max(10, messages.emojiMax),
    keywords: z.array(z.string()).min(1, messages.keywordsMin),
    author: z.string().min(1, messages.authorRequired).max(100, messages.authorRequired),
    author_title: z.string().max(100).optional(),
    date: z.string().min(1, messages.dateRequired),
    is_published: z.boolean(),
    featured_image_url: z
      .string()
      .max(500)
      .refine(
        (value) => value === '' || /^https?:\/\/\S+$/.test(value),
        messages.featuredImageUrl,
      )
      .optional()
      .or(z.literal('')),
  })
}

export type PostFormValues = z.infer<ReturnType<typeof postFormSchema>>

/** Generate a URL slug from a title ("My Post!" → "my-post"). */
export function slugifyTitle(title: string): string {
  return title
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

/** Estimate reading time ("3 min read") — ported from the frontend. */
export function calculateReadTime(content: string): string {
  const wordsPerMinute = 200
  const wordCount = content.trim().split(/\s+/).length
  const minutes = Math.ceil(wordCount / wordsPerMinute)
  return `${minutes} min read`
}

/** Default form values for a new post. */
export function emptyPostValues(): PostFormValues {
  return {
    title: '',
    slug: '',
    excerpt: '',
    content: '',
    category: '',
    emoji: '📝',
    keywords: [],
    author: 'FitCheck AI Team',
    author_title: '',
    date: new Date().toISOString().split('T')[0] ?? '',
    is_published: false,
    featured_image_url: '',
  }
}

/** Map an existing post into form values. */
export function postToFormValues(post: BlogPost): PostFormValues {
  return {
    title: post.title,
    slug: post.slug,
    excerpt: post.excerpt,
    content: post.content,
    category: post.category,
    emoji: post.emoji,
    keywords: [...post.keywords],
    author: post.author,
    author_title: post.author_title ?? '',
    date: post.date.split('T')[0] ?? post.date,
    is_published: post.is_published,
    featured_image_url: post.featured_image_url ?? '',
  }
}
