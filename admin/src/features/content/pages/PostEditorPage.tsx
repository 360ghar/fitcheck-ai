import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  ArrowLeft,
  Calendar,
  Eye,
  Hash,
  Loader2,
  Save,
  Sparkles,
  User,
  X,
} from 'lucide-react'
import { useEffect, useMemo, useRef, useState } from 'react'
import { FormProvider, useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { useBlocker, useNavigate, useParams } from 'react-router-dom'
import { toast } from 'sonner'

import {
  blogKeys,
  createBlogPost,
  fetchAllAdminPosts,
  getPostForEdit,
  updateBlogPost,
  type BlogPostCreate,
  type BlogPostUpdate,
} from '@/features/content/api/blog'
import { RichTextEditor } from '@/features/content/components/RichTextEditor'
import { categoryNames } from '@/features/content/lib/categories'
import {
  calculateReadTime,
  emptyPostValues,
  postFormSchema,
  postToFormValues,
  slugifyTitle,
  type PostFormValues,
} from '@/features/content/lib/postForm'
import { isApiError } from '@/shared/api/errors'
import { Badge } from '@/shared/ui/badge'
import { Button } from '@/shared/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/ui/card'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/shared/ui/dialog'
import {
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/shared/ui/form'
import { Input } from '@/shared/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/shared/ui/select'
import { Skeleton } from '@/shared/ui/skeleton'
import { Switch } from '@/shared/ui/switch'
import { Textarea } from '@/shared/ui/textarea'

export function PostEditorPage() {
  const { slug } = useParams<{ slug: string }>()
  const isEditing = Boolean(slug)
  const navigate = useNavigate()
  const { t } = useTranslation('content')
  const queryClient = useQueryClient()
  const [keywordInput, setKeywordInput] = useState('')
  const [previewOpen, setPreviewOpen] = useState(false)
  // Set on successful save so the leave-guard never blocks the post-save
  // navigation (form.reset()'s state commit is async — the blocker would
  // otherwise evaluate against a stale isDirty=true and strand the user).
  const saveSucceededRef = useRef(false)

  const messages = useMemo(
    () => ({
      titleRequired: t('editor.errors.titleRequired'),
      titleMax: t('editor.errors.titleMax'),
      slugRequired: t('editor.errors.slugRequired'),
      slugFormat: t('editor.errors.slugFormat'),
      slugMax: t('editor.errors.slugMax'),
      excerptRequired: t('editor.errors.excerptRequired'),
      excerptMax: t('editor.errors.excerptMax'),
      contentRequired: t('editor.errors.contentRequired'),
      categoryRequired: t('editor.errors.categoryRequired'),
      emojiRequired: t('editor.errors.emojiRequired'),
      emojiMax: t('editor.errors.emojiMax'),
      authorRequired: t('editor.errors.authorRequired'),
      dateRequired: t('editor.errors.dateRequired'),
      featuredImageUrl: t('editor.errors.featuredImageUrl'),
      keywordsMin: t('editor.errors.keywordsMin'),
    }),
    [t],
  )

  const schema = useMemo(() => postFormSchema(messages), [messages])

  const form = useForm<PostFormValues>({
    resolver: zodResolver(schema),
    defaultValues: emptyPostValues(),
  })

  // Load the post being edited (admin list lookup — no admin single-get endpoint).
  const postQuery = useQuery({
    queryKey: blogKeys.post(slug ?? ''),
    queryFn: () => getPostForEdit(slug!),
    enabled: isEditing,
    staleTime: 30_000,
  })

  useEffect(() => {
    if (postQuery.data) {
      form.reset(postToFormValues(postQuery.data))
    }
  }, [postQuery.data, form])

  // Category options: derived from the whole catalogue (all statuses).
  const categoriesQuery = useQuery({
    queryKey: blogKeys.adminAll,
    queryFn: () => fetchAllAdminPosts(),
    staleTime: 300_000,
  })
  const categories = useMemo(
    () => categoryNames(categoriesQuery.data ?? []),
    [categoriesQuery.data],
  )
  const currentCategory = form.watch('category')
  const categoryOptions = useMemo(() => {
    const options = [...categories]
    if (currentCategory && !options.includes(currentCategory)) options.push(currentCategory)
    return options
  }, [categories, currentCategory])

  const keywords = form.watch('keywords') ?? []
  const isPublished = form.watch('is_published')
  const slugValue = form.watch('slug')

  const handleTitleChange = (event: React.ChangeEvent<HTMLInputElement>): void => {
    const title = event.target.value
    // shouldDirty: this handler bypasses register's onChange, so setValue
    // must mark the field dirty itself (RHF 7.70 default is false).
    form.setValue('title', title, { shouldDirty: true })
    if (!isEditing || !slugValue) {
      form.setValue('slug', slugifyTitle(title), { shouldDirty: true })
    }
  }

  const addKeyword = (): void => {
    const trimmed = keywordInput.trim().toLowerCase()
    if (trimmed && !keywords.includes(trimmed)) {
      form.setValue('keywords', [...keywords, trimmed], { shouldDirty: true })
      setKeywordInput('')
    }
  }

  const removeKeyword = (keyword: string): void => {
    form.setValue(
      'keywords',
      keywords.filter((entry) => entry !== keyword),
      { shouldDirty: true },
    )
  }

  const saveMutation = useMutation({
    mutationFn: (values: PostFormValues) => {
      const read_time = calculateReadTime(values.content)
      if (isEditing && slug) {
        const body: BlogPostUpdate = {
          slug: values.slug,
          title: values.title,
          excerpt: values.excerpt,
          content: values.content,
          category: values.category,
          date: values.date,
          read_time,
          emoji: values.emoji,
          keywords: values.keywords,
          author: values.author,
          author_title: values.author_title || null,
          is_published: values.is_published,
          featured_image_url: values.featured_image_url || null,
        }
        return updateBlogPost(slug, body)
      }
      const body: BlogPostCreate = {
        slug: values.slug,
        title: values.title,
        excerpt: values.excerpt,
        content: values.content,
        category: values.category,
        date: values.date,
        read_time,
        emoji: values.emoji,
        keywords: values.keywords,
        author: values.author,
        author_title: values.author_title || null,
        is_published: values.is_published,
        featured_image_url: values.featured_image_url || null,
      }
      return createBlogPost(body)
    },
    onSuccess: () => {
      saveSucceededRef.current = true
      toast.success(t(isEditing ? 'editor.updated' : 'editor.created'))
      // Clear the dirty flag so the leave-guard does not fire on navigation.
      form.reset(form.getValues())
      void queryClient.invalidateQueries({ queryKey: blogKeys.all })
      void queryClient.invalidateQueries({ queryKey: blogKeys.adminAll })
      void queryClient.invalidateQueries({ queryKey: blogKeys.categories })
      void navigate('/content/posts')
    },
    onError: (error) => {
      saveSucceededRef.current = false
      if (isApiError(error) && error.code === 'VALIDATION_ERROR') {
        if (error.details?.field === 'slug') {
          form.setError('slug', { message: t('editor.errors.slugDuplicate') })
          return
        }
        if (error.fieldErrors) {
          for (const [field, message] of Object.entries(error.fieldErrors)) {
            form.setError(field as keyof PostFormValues, { message })
          }
          return
        }
      }
      toast.error(t('editor.errorSave'))
    },
  })

  const onSubmit = (values: PostFormValues): void => {
    saveMutation.mutate(values)
  }

  // Leave guard: block navigation away with unsaved changes. A successful
  // save arms saveSucceededRef so the post-save navigate() is never blocked
  // (the reset state commit is async; isDirty would still be stale-true).
  const blocker = useBlocker(
    ({ currentLocation, nextLocation }) =>
      form.formState.isDirty &&
      !saveSucceededRef.current &&
      currentLocation.pathname !== nextLocation.pathname,
  )

  // New edits after a save re-arm the guard.
  useEffect(() => {
    if (form.formState.isDirty) {
      saveSucceededRef.current = false
    }
  }, [form.formState.isDirty])

  // The category select is fed by the catalogue query; the edit form must
  // not mount until BOTH queries resolve — otherwise Radix Select's hidden
  // native-select sync can dispatch a spurious `change` with "" right after
  // `form.reset(...)`, wiping the category value.
  if (isEditing && (postQuery.isPending || categoriesQuery.isPending)) {
    return (
      <div className="mx-auto max-w-4xl space-y-6">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-12 w-full" />
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-96 w-full" />
      </div>
    )
  }

  if (isEditing && (postQuery.isError || !postQuery.data)) {
    return (
      <div className="mx-auto max-w-4xl space-y-4 text-center">
        <p className="text-destructive">{t('editor.errorLoad')}</p>
        <Button variant="secondary" onClick={() => navigate('/content/posts')}>
          {t('editor.back')}
        </Button>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-4xl space-y-8">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => navigate('/content/posts')}
          >
            <ArrowLeft aria-hidden="true" />
            {t('editor.back')}
          </Button>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">
              {t(isEditing ? 'editor.editTitle' : 'editor.newTitle')}
            </h1>
            <p className="text-sm text-muted-foreground">
              {t(isEditing ? 'editor.editDescription' : 'editor.newDescription')}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" onClick={() => setPreviewOpen(true)}>
            <Eye aria-hidden="true" />
            {t('editor.preview')}
          </Button>
          <Button
            onClick={form.handleSubmit(onSubmit)}
            loading={saveMutation.isPending}
          >
            {saveMutation.isPending ? <Loader2 className="animate-spin" aria-hidden="true" /> : <Save aria-hidden="true" />}
            {t('editor.save')}
          </Button>
        </div>
      </div>

      <FormProvider {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Save className="size-4 text-muted-foreground" aria-hidden="true" />
              {t('editor.sections.content')}
            </CardTitle>
            <CardDescription>{t('editor.sections.contentDescription')}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <FormField
              control={form.control}
              name="title"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t('editor.fields.title')}</FormLabel>
                  <FormControl>
                    <Input
                      placeholder={t('editor.fields.titlePlaceholder')}
                      {...field}
                      onChange={handleTitleChange}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="slug"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t('editor.fields.slug')}</FormLabel>
                  <FormControl>
                    <Input placeholder="post-url-slug" autoComplete="off" {...field} />
                  </FormControl>
                  <FormDescription>
                    {t('editor.fields.slugHint', { slug: slugValue || '…' })}
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="excerpt"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>{t('editor.fields.excerpt')}</FormLabel>
                  <FormControl>
                    <Textarea
                      rows={3}
                      placeholder={t('editor.fields.excerptPlaceholder')}
                      {...field}
                    />
                  </FormControl>
                  <FormDescription>
                    {t('editor.fields.excerptCount', { count: field.value.length })}
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="content"
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    <RichTextEditor
                      label={t('editor.fields.content')}
                      value={field.value}
                      onChange={field.onChange}
                      {...(form.formState.errors.content
                        ? { error: t('editor.errors.contentRequired') }
                        : {})}
                      minHeight="500px"
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <Sparkles className="size-4 text-muted-foreground" aria-hidden="true" />
              {t('editor.sections.settings')}
            </CardTitle>
            <CardDescription>{t('editor.sections.settingsDescription')}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
              <FormField
                control={form.control}
                name="category"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('editor.fields.category')}</FormLabel>
                    <Select
                      value={field.value}
                      onValueChange={(value) => {
                        // Radix Select's hidden native-select sync can fire a
                        // spurious `onValueChange("")` right after the form
                        // value changes (jsdom/browser timing race). A select
                        // can never legitimately be cleared by the user, so
                        // ignore empty writes while a value is set.
                        if (value === '' && field.value !== '') return
                        field.onChange(value)
                      }}
                    >
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder={t('editor.fields.categoryPlaceholder')} />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {categoryOptions.map((category) => (
                          <SelectItem key={category} value={category}>
                            {category}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="emoji"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('editor.fields.emoji')}</FormLabel>
                    <FormControl>
                      <Input placeholder="📝" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="author"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('editor.fields.author')}</FormLabel>
                    <FormControl>
                      <Input placeholder={t('editor.fields.authorPlaceholder')} {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="author_title"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('editor.fields.authorTitle')}</FormLabel>
                    <FormControl>
                      <Input placeholder={t('editor.fields.authorTitlePlaceholder')} {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="date"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('editor.fields.date')}</FormLabel>
                    <FormControl>
                      <Input type="date" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="featured_image_url"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{t('editor.fields.featuredImage')}</FormLabel>
                    <FormControl>
                      <Input
                        type="url"
                        placeholder={t('editor.fields.featuredImagePlaceholder')}
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="is_published"
              render={({ field }) => (
                <FormItem className="flex items-center justify-between gap-4 rounded-md border border-border p-3">
                  <FormLabel>{t('editor.fields.isPublished')}</FormLabel>
                  <FormControl>
                    <Switch checked={field.value} onCheckedChange={field.onChange} />
                  </FormControl>
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="keywords"
              render={() => (
                <FormItem>
                  <FormLabel>{t('editor.fields.keywords')}</FormLabel>
                  <div className="flex gap-2">
                    <Input
                      value={keywordInput}
                      onChange={(event) => setKeywordInput(event.target.value)}
                      onKeyDown={(event) => {
                        if (event.key === 'Enter') {
                          event.preventDefault()
                          addKeyword()
                        }
                      }}
                      placeholder={t('editor.fields.keywordsPlaceholder')}
                    />
                    <Button type="button" variant="secondary" onClick={addKeyword}>
                      {t('editor.fields.keywordsAdd')}
                    </Button>
                  </div>
                  <FormMessage />
                  <div className="flex flex-wrap gap-2">
                    {keywords.map((keyword) => (
                      <Badge key={keyword} variant="secondary" className="gap-1">
                        {keyword}
                        <button
                          type="button"
                          onClick={() => removeKeyword(keyword)}
                          className="ml-1 hover:text-destructive"
                          aria-label={t('editor.fields.keywordsRemove', { keyword })}
                        >
                          <X className="size-3" aria-hidden="true" />
                        </button>
                      </Badge>
                    ))}
                  </div>
                </FormItem>
              )}
            />
          </CardContent>
        </Card>

        <div className="flex justify-end gap-4">
          <Button
            type="button"
            variant="outline"
            onClick={() => navigate('/content/posts')}
            disabled={saveMutation.isPending}
          >
            {t('editor.cancel')}
          </Button>
          <Button
            type="submit"
            variant={isPublished ? 'primary' : 'secondary'}
            loading={saveMutation.isPending}
          >
            {saveMutation.isPending ? (
              <Loader2 className="animate-spin" aria-hidden="true" />
            ) : (
              <Save aria-hidden="true" />
            )}
            {t('editor.save')}
          </Button>
        </div>
      </form>
      </FormProvider>

      {/* Preview dialog */}
      <Dialog open={previewOpen} onOpenChange={setPreviewOpen}>
        <DialogContent className="max-h-[90dvh] max-w-3xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{t('editor.preview')}</DialogTitle>
            <DialogDescription>
              {form.watch('title') || 'Untitled'}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-6">
            <div className="border-b pb-6">
              <Badge className="mb-4">{form.watch('category') || 'Uncategorized'}</Badge>
              <h2 className="mb-4 text-3xl font-bold">{form.watch('title') || 'Untitled post'}</h2>
              <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
                <span className="flex items-center gap-1">
                  <User className="size-4" aria-hidden="true" />
                  {form.watch('author')}
                  {form.watch('author_title') ? ` — ${form.watch('author_title')}` : ''}
                </span>
                <span className="flex items-center gap-1">
                  <Calendar className="size-4" aria-hidden="true" />
                  {form.watch('date') || '—'}
                </span>
                <span className="flex items-center gap-1">
                  <Hash className="size-4" aria-hidden="true" />
                  {calculateReadTime(form.watch('content') || '')}
                </span>
              </div>
            </div>
            {form.watch('content') ? (
              <div
                className="prose max-w-none"
                dangerouslySetInnerHTML={{ __html: renderMarkdown(form.watch('content')) }}
              />
            ) : (
              <p className="italic text-muted-foreground">No content yet…</p>
            )}
          </div>
          <DialogFooter>
            <Button variant="secondary" onClick={() => setPreviewOpen(false)}>
              {t('editor.close')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Unsaved-changes leave guard */}
      <Dialog
        open={blocker.state === 'blocked'}
        onOpenChange={(open) => {
          if (!open) blocker.reset?.()
        }}
      >
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{t('editor.leaveGuard')}</DialogTitle>
          </DialogHeader>
          <DialogFooter>
            <Button variant="secondary" onClick={() => blocker.reset?.()}>
              {t('editor.leaveGuardStay')}
            </Button>
            <Button onClick={() => blocker.proceed?.()}>{t('editor.leaveGuardLeave')}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}

/** Simple markdown → escaped HTML for the preview (ported from the frontend). */
function renderMarkdown(content: string): string {
  return escapeHtml(content)
    .replace(/^# (.*$)/gim, '<h1 class="mb-4 mt-8 text-3xl font-bold">$1</h1>')
    .replace(/^## (.*$)/gim, '<h2 class="mb-3 mt-6 text-2xl font-bold">$1</h2>')
    .replace(/^### (.*$)/gim, '<h3 class="mb-2 mt-4 text-xl font-bold">$1</h3>')
    .replace(/\*\*(.*)\*\*/gim, '<strong>$1</strong>')
    .replace(/\*(.*)\*/gim, '<em>$1</em>')
    .replace(/`([^`]+)`/gim, '<code class="rounded bg-surface-card px-1 py-0.5 font-mono text-xs">$1</code>')
    .replace(/^- (.*$)/gim, '<li class="ml-4">$1</li>')
    .replace(/^\d+\. (.*$)/gim, '<li class="ml-4">$1</li>')
    .replace(/\n/gim, '<br />')
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}
