/**
 * Blog Editor Page - Create and edit blog posts
 */

import { useState, useEffect, useCallback } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm, Controller } from 'react-hook-form';
import { z } from 'zod';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { RichTextEditor } from '@/components/admin/RichTextEditor';
import {
  ArrowLeft,
  Save,
  Eye,
  Calendar,
  Hash,
  User,
  FileText,
  Check,
  X,
  Loader2,
  Sparkles,
} from 'lucide-react';
import {
  createBlogPost,
  updateBlogPost,
  getBlogPostBySlug,
  getBlogCategories,
  generateSlug,
  calculateReadTime,
} from '@/api/blog';
import { showSuccess, showError } from '@/lib/toast-utils';

// Form validation schema
const blogPostSchema = z.object({
  title: z.string().min(1, 'Title is required').max(200, 'Title is too long'),
  slug: z
    .string()
    .min(1, 'Slug is required')
    .max(200, 'Slug is too long')
    .regex(/^[a-z0-9-]+$/, 'Slug can only contain lowercase letters, numbers, and hyphens'),
  excerpt: z.string().min(1, 'Excerpt is required').max(500, 'Excerpt is too long'),
  content: z.string().min(1, 'Content is required'),
  category: z.string().min(1, 'Category is required'),
  emoji: z.string().min(1, 'Emoji is required').max(2, 'Please use a single emoji'),
  keywords: z.array(z.string()).min(1, 'At least one keyword is required'),
  author: z.string().min(1, 'Author is required'),
  author_title: z.string().optional(),
  is_published: z.boolean(),
  date: z.string().min(1, 'Date is required'),
});

type BlogPostFormData = z.infer<typeof blogPostSchema>;

export default function BlogEditorPage() {
  const navigate = useNavigate();
  const { slug } = useParams<{ slug: string }>();
  const queryClient = useQueryClient();
  const isEditing = Boolean(slug);

  const [previewOpen, setPreviewOpen] = useState(false);
  const [keywordInput, setKeywordInput] = useState('');

  // Fetch post data if editing
  const {
    data: postData,
    isLoading: isLoadingPost,
    error: postError,
  } = useQuery({
    queryKey: ['blog-post', slug],
    queryFn: () => getBlogPostBySlug(slug!),
    enabled: isEditing,
  });

  // Fetch categories
  const { data: categories, isLoading: isLoadingCategories } = useQuery({
    queryKey: ['blog-categories'],
    queryFn: getBlogCategories,
  });

  // Form setup
  const {
    register,
    handleSubmit,
    control,
    watch,
    setValue,
    reset,
    formState: { errors, isDirty },
  } = useForm<BlogPostFormData>({
    resolver: zodResolver(blogPostSchema),
    defaultValues: {
      title: '',
      slug: '',
      excerpt: '',
      content: '',
      category: '',
      emoji: '📝',
      keywords: [],
      author: 'FitCheck AI Team',
      author_title: '',
      is_published: false,
      date: new Date().toISOString().split('T')[0],
    },
  });

  // Watch form values for preview
  const formValues = watch();

  // Reset form when post data loads
  useEffect(() => {
    if (postData) {
      reset({
        title: postData.title,
        slug: postData.slug,
        excerpt: postData.excerpt,
        content: postData.content,
        category: postData.category,
        emoji: postData.emoji,
        keywords: postData.keywords,
        author: postData.author,
        author_title: postData.author_title || '',
        is_published: postData.is_published,
        date: postData.date.split('T')[0],
      });
    }
  }, [postData, reset]);

  // Auto-generate slug from title
  const handleTitleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const title = e.target.value;
      setValue('title', title);
      if (!isEditing || !watch('slug')) {
        setValue('slug', generateSlug(title));
      }
    },
    [isEditing, setValue, watch]
  );

  // Add keyword
  const addKeyword = () => {
    const trimmed = keywordInput.trim().toLowerCase();
    if (trimmed && !formValues.keywords.includes(trimmed)) {
      setValue('keywords', [...formValues.keywords, trimmed]);
      setKeywordInput('');
    }
  };

  // Remove keyword
  const removeKeyword = (keyword: string) => {
    setValue(
      'keywords',
      formValues.keywords.filter((k) => k !== keyword)
    );
  };

  // Create mutation
  const createMutation = useMutation({
    mutationFn: (data: BlogPostFormData) =>
      createBlogPost({
        ...data,
        read_time: calculateReadTime(data.content),
      }),
    onSuccess: () => {
      showSuccess('Blog post created successfully');
      queryClient.invalidateQueries({ queryKey: ['blog-posts'] });
      navigate('/admin/blog/posts');
    },
    onError: (error: Error) => {
      showError(error.message, 'Failed to create blog post');
    },
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: (data: BlogPostFormData) =>
      updateBlogPost(slug!, {
        ...data,
        read_time: calculateReadTime(data.content),
      }),
    onSuccess: () => {
      showSuccess('Blog post updated successfully');
      queryClient.invalidateQueries({ queryKey: ['blog-posts'] });
      queryClient.invalidateQueries({ queryKey: ['blog-post', slug] });
      navigate('/admin/blog/posts');
    },
    onError: (error: Error) => {
      showError(error.message, 'Failed to update blog post');
    },
  });

  // Form submission
  const onSubmit = (data: BlogPostFormData) => {
    if (isEditing) {
      updateMutation.mutate(data);
    } else {
      createMutation.mutate(data);
    }
  };

  // Loading state
  if (isEditing && isLoadingPost) {
    return (
      <div className="p-8 max-w-4xl mx-auto">
        <Skeleton className="h-8 w-48 mb-8" />
        <div className="space-y-6">
          <Skeleton className="h-12 w-full" />
          <Skeleton className="h-12 w-full" />
          <Skeleton className="h-32 w-full" />
          <Skeleton className="h-96 w-full" />
        </div>
      </div>
    );
  }

  // Error state
  if (isEditing && postError) {
    return (
      <div className="p-8 text-center">
        <p className="text-destructive mb-4">Failed to load blog post</p>
        <Button onClick={() => navigate('/admin/blog/posts')}>Go Back</Button>
      </div>
    );
  }

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  return (
    <div className="p-8 max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="sm" onClick={() => navigate('/admin/blog/posts')}>
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back
          </Button>
          <div>
            <h1 className="text-3xl font-bold">{isEditing ? 'Edit Post' : 'New Post'}</h1>
            <p className="text-muted-foreground mt-1">
              {isEditing ? 'Update your blog post' : 'Create a new blog post'}
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => setPreviewOpen(true)}>
            <Eye className="w-4 h-4 mr-2" />
            Preview
          </Button>
          <Button
            onClick={handleSubmit(onSubmit)}
            disabled={isSubmitting || !isDirty}
          >
            {isSubmitting ? (
              <>
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Save className="w-4 h-4 mr-2" />
                {isEditing ? 'Update' : 'Create'}
              </>
            )}
          </Button>
        </div>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-8">
        {/* Main Content */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <FileText className="w-5 h-5" />
              Content
            </CardTitle>
            <CardDescription>The main content of your blog post</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Title */}
            <div className="space-y-2">
              <Label htmlFor="title">Title</Label>
              <Input
                id="title"
                placeholder="Enter post title..."
                {...register('title')}
                onChange={handleTitleChange}
                className={cn(errors.title && 'border-destructive')}
              />
              {errors.title && (
                <p className="text-sm text-destructive">{errors.title.message}</p>
              )}
            </div>

            {/* Slug */}
            <div className="space-y-2">
              <Label htmlFor="slug">Slug</Label>
              <Input
                id="slug"
                placeholder="post-url-slug"
                {...register('slug')}
                className={cn(errors.slug && 'border-destructive')}
              />
              {errors.slug && (
                <p className="text-sm text-destructive">{errors.slug.message}</p>
              )}
              <p className="text-xs text-muted-foreground">
                This will be the URL: /blog/{watch('slug')}
              </p>
            </div>

            {/* Excerpt */}
            <div className="space-y-2">
              <Label htmlFor="excerpt">Excerpt</Label>
              <Textarea
                id="excerpt"
                placeholder="Brief summary of the post..."
                rows={3}
                {...register('excerpt')}
                className={cn(errors.excerpt && 'border-destructive')}
              />
              {errors.excerpt && (
                <p className="text-sm text-destructive">{errors.excerpt.message}</p>
              )}
              <p className="text-xs text-muted-foreground">
                {watch('excerpt')?.length || 0}/500 characters
              </p>
            </div>

            {/* Content */}
            <Controller
              name="content"
              control={control}
              render={({ field }) => (
                <RichTextEditor
                  label="Content"
                  value={field.value}
                  onChange={field.onChange}
                  error={errors.content?.message}
                  minHeight="500px"
                />
              )}
            />
          </CardContent>
        </Card>

        {/* Settings */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Sparkles className="w-5 h-5" />
              Settings
            </CardTitle>
            <CardDescription>Metadata and publishing options</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Category */}
              <div className="space-y-2">
                <Label htmlFor="category">Category</Label>
                <Controller
                  name="category"
                  control={control}
                  render={({ field }) => (
                    <Select value={field.value} onValueChange={field.onChange}>
                      <SelectTrigger
                        className={cn(errors.category && 'border-destructive')}
                      >
                        <SelectValue placeholder="Select category" />
                      </SelectTrigger>
                      <SelectContent>
                        {isLoadingCategories ? (
                          <SelectItem value="loading" disabled>
                            Loading...
                          </SelectItem>
                        ) : (
                          categories?.map((cat: string) => (
                            <SelectItem key={cat} value={cat}>
                              {cat}
                            </SelectItem>
                          ))
                        )}
                      </SelectContent>
                    </Select>
                  )}
                />
                {errors.category && (
                  <p className="text-sm text-destructive">{errors.category.message}</p>
                )}
              </div>

              {/* Emoji */}
              <div className="space-y-2">
                <Label htmlFor="emoji">Emoji</Label>
                <Input
                  id="emoji"
                  placeholder="📝"
                  {...register('emoji')}
                  className={cn(errors.emoji && 'border-destructive')}
                />
                {errors.emoji && (
                  <p className="text-sm text-destructive">{errors.emoji.message}</p>
                )}
              </div>

              {/* Author */}
              <div className="space-y-2">
                <Label htmlFor="author">Author</Label>
                <Input
                  id="author"
                  placeholder="Author name"
                  {...register('author')}
                  className={cn(errors.author && 'border-destructive')}
                />
                {errors.author && (
                  <p className="text-sm text-destructive">{errors.author.message}</p>
                )}
              </div>

              {/* Author Title */}
              <div className="space-y-2">
                <Label htmlFor="author_title">Author Title (Optional)</Label>
                <Input
                  id="author_title"
                  placeholder="e.g., Fashion Expert"
                  {...register('author_title')}
                />
              </div>

              {/* Date */}
              <div className="space-y-2">
                <Label htmlFor="date">Publish Date</Label>
                <Input
                  id="date"
                  type="date"
                  {...register('date')}
                  className={cn(errors.date && 'border-destructive')}
                />
                {errors.date && (
                  <p className="text-sm text-destructive">{errors.date.message}</p>
                )}
              </div>

              {/* Published Toggle */}
              <div className="space-y-2">
                <Label>Status</Label>
                <div className="flex items-center gap-3 pt-2">
                  <Controller
                    name="is_published"
                    control={control}
                    render={({ field }) => (
                      <Switch
                        checked={field.value}
                        onCheckedChange={field.onChange}
                      />
                    )}
                  />
                  <span className={cn(watch('is_published') ? 'text-green-600' : 'text-amber-600')}>
                    {watch('is_published') ? 'Published' : 'Draft'}
                  </span>
                </div>
              </div>
            </div>

            {/* Keywords */}
            <div className="space-y-2">
              <Label>Keywords</Label>
              <div className="flex gap-2">
                <Input
                  placeholder="Add a keyword and press Enter"
                  value={keywordInput}
                  onChange={(e) => setKeywordInput(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      addKeyword();
                    }
                  }}
                />
                <Button type="button" variant="secondary" onClick={addKeyword}>
                  Add
                </Button>
              </div>
              {errors.keywords && (
                <p className="text-sm text-destructive">{errors.keywords.message}</p>
              )}
              <div className="flex flex-wrap gap-2 mt-2">
                {watch('keywords')?.map((keyword) => (
                  <Badge key={keyword} variant="secondary" className="gap-1">
                    {keyword}
                    <button
                      type="button"
                      onClick={() => removeKeyword(keyword)}
                      className="ml-1 hover:text-destructive"
                    >
                      <X className="w-3 h-3" />
                    </button>
                  </Badge>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Actions */}
        <div className="flex justify-end gap-4">
          <Button
            type="button"
            variant="outline"
            onClick={() => navigate('/admin/blog/posts')}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
          <Button
            type="submit"
            disabled={isSubmitting || !isDirty}
            variant={watch('is_published') ? 'default' : 'secondary'}
          >
            {isSubmitting ? (
              <>
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                Saving...
              </>
            ) : watch('is_published') ? (
              <>
                <Check className="w-4 h-4 mr-2" />
                {isEditing ? 'Update & Publish' : 'Publish'}
              </>
            ) : (
              <>
                <Save className="w-4 h-4 mr-2" />
                {isEditing ? 'Update Draft' : 'Save Draft'}
              </>
            )}
          </Button>
        </div>
      </form>

      {/* Preview Dialog */}
      <Dialog open={previewOpen} onOpenChange={setPreviewOpen}>
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Post Preview</DialogTitle>
            <DialogDescription>This is how your post will appear</DialogDescription>
          </DialogHeader>
          <div className="space-y-6">
            {/* Preview Header */}
            <div className="border-b pb-6">
              <Badge className="mb-4">{formValues.category || 'Uncategorized'}</Badge>
              <h1 className="text-3xl font-bold mb-4">{formValues.title || 'Untitled Post'}</h1>
              <div className="flex items-center gap-4 text-sm text-muted-foreground">
                <span className="flex items-center gap-1">
                  <User className="w-4 h-4" />
                  {formValues.author}
                  {formValues.author_title && ` — ${formValues.author_title}`}
                </span>
                <span className="flex items-center gap-1">
                  <Calendar className="w-4 h-4" />
                  {formValues.date}
                </span>
                <span className="flex items-center gap-1">
                  <Hash className="w-4 h-4" />
                  {calculateReadTime(formValues.content || '')}
                </span>
              </div>
            </div>

            {/* Preview Content */}
            <div className="prose prose-lg dark:prose-invert max-w-none">
              {formValues.content ? (
                <div
                  dangerouslySetInnerHTML={{
                    __html: renderMarkdown(formValues.content),
                  }}
                />
              ) : (
                <p className="text-muted-foreground italic">No content yet...</p>
              )}
            </div>

            {/* Preview Keywords */}
            {formValues.keywords?.length > 0 && (
              <div className="border-t pt-6">
                <h3 className="text-sm font-semibold mb-3">Related Topics</h3>
                <div className="flex flex-wrap gap-2">
                  {formValues.keywords.map((keyword) => (
                    <Badge key={keyword} variant="outline">
                      {keyword}
                    </Badge>
                  ))}
                </div>
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// Helper function to render markdown for preview
function renderMarkdown(content: string): string {
  return content
    .replace(/^# (.*$)/gim, '<h1 class="text-3xl font-bold mt-8 mb-4">$1</h1>')
    .replace(/^## (.*$)/gim, '<h2 class="text-2xl font-bold mt-6 mb-3">$1</h2>')
    .replace(/^### (.*$)/gim, '<h3 class="text-xl font-bold mt-4 mb-2">$1</h3>')
    .replace(/\*\*(.*)\*\*/gim, '<strong>$1</strong>')
    .replace(/\*(.*)\*/gim, '<em>$1</em>')
    .replace(/`([^`]+)`/gim, '<code class="bg-muted px-1 py-0.5 rounded text-sm">$1</code>')
    .replace(/^- (.*$)/gim, '<li class="ml-4">$1</li>')
    .replace(/^\d+\. (.*$)/gim, '<li class="ml-4">$1</li>')
    .replace(/\n/gim, '<br />');
}
