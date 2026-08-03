/**
 * Blog Dashboard Page - Overview of blog metrics
 */

import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  FileText,
  Plus,
  Eye,
  TrendingUp,
  ArrowRight,
  CheckCircle2,
  Clock,
} from 'lucide-react';
import { getAllBlogPosts, getBlogCategories } from '@/api/blog';

export default function BlogDashboardPage() {
  const navigate = useNavigate();

  // Fetch posts. The Published/Drafts stat cards must count ALL posts, not just
  // the 5 shown in "Recent Posts", so page through the backend's max
  // page_size (100) until the whole catalogue is fetched (summaries only — no
  // content bodies — so this stays cheap) and derive the counts from the
  // full set. Requesting page_size > 100 would 422 against the backend's
  // `page_size: Query(..., le=100)`.
  const { data: postsData, isLoading: isLoadingPosts } = useQuery({
    queryKey: ['blog-posts', 'admin', 'all'],
    queryFn: async () => {
      const PAGE_SIZE = 100
      const first = await getAllBlogPosts(1, PAGE_SIZE, true)
      const posts = [...(first.posts || [])]
      let total = first.total ?? posts.length
      let page = 2
      // Guard against runaway loops if the backend ever under-reports total.
      while (posts.length < total && page <= 20) {
        const next = await getAllBlogPosts(page, PAGE_SIZE, true)
        posts.push(...(next.posts || []))
        total = next.total ?? total
        page += 1
      }
      return { posts, total }
    },
  });

  // Fetch categories
  const { data: categories, isLoading: isLoadingCategories } = useQuery({
    queryKey: ['blog-categories'],
    queryFn: getBlogCategories,
  });

  const allPosts = postsData?.posts || [];
  const recentPosts = allPosts.slice(0, 5);
  const totalPosts = postsData?.total || 0;
  // Every post is published XOR draft, so the draft count is total − published.
  const publishedPosts = allPosts.filter((p) => p.is_published).length;
  const draftPosts = Math.max(totalPosts - publishedPosts, 0);

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">Blog Dashboard</h1>
          <p className="text-muted-foreground mt-1">
            Overview of your blog performance
          </p>
        </div>
        <Button onClick={() => navigate('/admin/blog/new')} className="gap-2">
          <Plus className="w-4 h-4" />
          New Post
        </Button>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Total Posts</p>
                <p className="text-3xl font-bold">
                  {isLoadingPosts ? <Skeleton className="h-8 w-16" /> : totalPosts}
                </p>
              </div>
              <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center">
                <FileText className="w-6 h-6 text-primary" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Published</p>
                <p className="text-3xl font-bold text-green-600">
                  {isLoadingPosts ? <Skeleton className="h-8 w-16" /> : publishedPosts}
                </p>
              </div>
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                <CheckCircle2 className="w-6 h-6 text-green-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Drafts</p>
                <p className="text-3xl font-bold text-amber-600">
                  {isLoadingPosts ? <Skeleton className="h-8 w-16" /> : draftPosts}
                </p>
              </div>
              <div className="w-12 h-12 bg-amber-100 rounded-full flex items-center justify-center">
                <Clock className="w-6 h-6 text-amber-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Categories</p>
                <p className="text-3xl font-bold">
                  {isLoadingCategories ? (
                    <Skeleton className="h-8 w-16" />
                  ) : (
                    categories?.length || 0
                  )}
                </p>
              </div>
              <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center">
                <TrendingUp className="w-6 h-6 text-primary" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Recent Posts */}
        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <Clock className="w-5 h-5" />
              Recent Posts
            </CardTitle>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate('/admin/blog/posts')}
            >
              View All
              <ArrowRight className="w-4 h-4 ml-2" />
            </Button>
          </CardHeader>
          <CardContent>
            {isLoadingPosts ? (
              <div className="space-y-4">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Skeleton key={i} className="h-16 w-full" />
                ))}
              </div>
            ) : recentPosts.length === 0 ? (
              <div className="text-center py-8">
                <FileText className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                <p className="text-muted-foreground">No posts yet</p>
                <Button
                  variant="outline"
                  className="mt-4"
                  onClick={() => navigate('/admin/blog/new')}
                >
                  Create your first post
                </Button>
              </div>
            ) : (
              <div className="space-y-4">
                {recentPosts.map((post) => (
                  <button
                    type="button"
                    key={post.id}
                    className="flex items-center justify-between w-full p-4 border rounded-lg hover:bg-muted/50 transition-colors cursor-pointer text-left"
                    onClick={() => navigate(`/admin/blog/edit/${post.slug}`)}
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded bg-primary/10 flex items-center justify-center text-lg">
                        {post.emoji}
                      </div>
                      <div>
                        <p className="font-medium">{post.title}</p>
                        <p className="text-sm text-muted-foreground">
                          {post.category} • {new Date(post.date).toLocaleDateString()}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      {post.is_published ? (
                        <Badge className="bg-green-100 text-green-700">Published</Badge>
                      ) : (
                        <Badge variant="outline" className="text-amber-600">
                          Draft
                        </Badge>
                      )}
                    </div>
                  </button>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Quick Actions */}
        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <Button
              variant="outline"
              className="w-full justify-start"
              onClick={() => navigate('/admin/blog/new')}
            >
              <Plus className="w-4 h-4 mr-2" />
              Create New Post
            </Button>
            <Button
              variant="outline"
              className="w-full justify-start"
              onClick={() => navigate('/admin/blog/posts')}
            >
              <FileText className="w-4 h-4 mr-2" />
              Manage Posts
            </Button>
            <Button
              variant="outline"
              className="w-full justify-start"
              onClick={() => navigate('/admin/blog/categories')}
            >
              <TrendingUp className="w-4 h-4 mr-2" />
              Manage Categories
            </Button>
            <Button
              variant="outline"
              className="w-full justify-start"
              onClick={() => window.open('/blog', '_blank')}
            >
              <Eye className="w-4 h-4 mr-2" />
              View Blog
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
