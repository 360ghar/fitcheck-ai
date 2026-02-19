#!/usr/bin/env python3
"""
Script to migrate static blog posts from blog-data.ts to the database.

Usage:
    cd backend
    python scripts/migrate_blog_posts.py

Environment variables required:
    SUPABASE_URL
    SUPABASE_SECRET_KEY
"""

import asyncio
import os
import sys
from datetime import datetime
from typing import Any

# Add parent directory to path to import app modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.connection import SupabaseDB
from app.models.blog import BlogPostCreate


# Static blog posts data (extracted from frontend/src/pages/blog/blog-data.ts)
STATIC_BLOG_POSTS: list[dict[str, Any]] = [
    {
        "slug": "ai-wardrobe-organization-guide",
        "title": "The Complete Guide to AI-Powered Wardrobe Organization",
        "excerpt": "Learn how artificial intelligence can transform your closet from chaos to curated in minutes. Discover the best strategies for digitizing your wardrobe.",
        "category": "Wardrobe Tips",
        "date": "2026-02-15",
        "read_time": "8 min read",
        "emoji": "🤖",
        "keywords": ["AI wardrobe organization", "digital closet", "wardrobe management app", "AI fashion", "virtual closet organizer"],
        "author": "FitCheck AI Team",
        "author_title": "Fashion Technology Experts",
        "content": """# The Complete Guide to AI-Powered Wardrobe Organization

In the age of artificial intelligence, organizing your wardrobe has never been easier. This comprehensive guide will show you how AI can transform your closet from chaos to curated in just minutes.

## What is AI Wardrobe Organization?

AI wardrobe organization uses computer vision and machine learning to automatically catalog your clothing items. Instead of manually entering each piece, you simply upload photos and the AI does the rest—detecting items, extracting colors, identifying categories, and even recognizing brands.

## How FitCheck AI's Wardrobe Extraction Works

Our advanced AI can:
- **Detect multiple items** in a single photo (flat lay or hanging)
- **Identify colors** with precision accuracy across 60+ color palettes
- **Categorize items** by type (tops, bottoms, shoes, accessories, outerwear)
- **Extract brand information** when visible on labels or tags
- **Suggest style tags** based on design elements and patterns
- **Detect materials** like cotton, silk, denim, leather, and more

## Step-by-Step: Organizing Your Wardrobe with AI

### Step 1: Gather Your Items
Collect 10-20 items you want to catalog. Group similar items together for faster processing. Start with your favorite pieces or seasonal essentials.

### Step 2: Photograph Strategically
- Use natural lighting when possible for accurate color detection
- Photograph items flat on a neutral background (white or light gray works best)
- Include multiple angles for complex items with details
- Take group photos for faster batch processing—our AI can separate individual items

### Step 3: Upload and Let AI Work
Upload your photos to FitCheck AI. Our AI processes each image in seconds, extracting:
- Item category and subcategory (e.g., Tops → T-shirts → Graphic Tees)
- Primary and secondary colors
- Material composition detection
- Pattern recognition (stripes, floral, solid, geometric)
- Brand identification

### Step 4: Review and Refine
While our AI is 95%+ accurate, you can easily edit any details:
- Adjust color tags to match your preference
- Add custom categories for your unique organizing system
- Include purchase information (price, date, store)
- Set care instructions and washing preferences

## Benefits of AI Wardrobe Organization

### Save Time
What used to take hours of manual data entry now takes minutes. Our users report saving an average of 5 hours when cataloging 100 items compared to manual entry.

### Better Outfit Discovery
With detailed metadata on every item, our AI can suggest combinations you might never have considered. Discover new ways to wear old favorites.

### Cost-Per-Wear Analytics
Track how often you wear each item and calculate the true cost-per-wear to make smarter purchasing decisions. Identify which pieces give you the best value.

### Seasonal Rotation Insights
Identify which items you actually wear each season and optimize your closet space accordingly. Donate or sell pieces that never get worn.

## Tips for Best Results

1. **Start with favorites**: Catalog items you wear most often first to get immediate value
2. **Be consistent with lighting**: Similar lighting helps with color accuracy across your collection
3. **Group by category**: Process all tops together, then bottoms, etc., for efficient workflow
4. **Add context**: Include occasion tags (work, casual, formal, date night) for better recommendations
5. **Update regularly**: Add new purchases immediately to maintain an accurate digital wardrobe

## The Future of AI Wardrobe Management

As AI technology advances, expect even more powerful features:
- **Predictive outfit suggestions** based on your schedule and weather
- **Smart closet integration** with RFID tags and smart mirrors
- **Sustainability scoring** to help you build a more eco-friendly wardrobe
- **Trend forecasting** that suggests timeless pieces versus passing fads

Ready to transform your wardrobe? Try FitCheck AI for free and experience the power of AI organization.""",
    },
    {
        "slug": "virtual-try-on-technology-explained",
        "title": "How Virtual Try-On Technology Actually Works",
        "excerpt": "A deep dive into the AI and computer vision powering virtual outfit visualization. Understand the technology behind seeing clothes on your body before buying.",
        "category": "Technology",
        "date": "2026-02-10",
        "read_time": "6 min read",
        "emoji": "👗",
        "keywords": ["virtual try-on", "AI fashion technology", "outfit visualization", "generative AI", "virtual fitting room"],
        "author": "FitCheck AI Team",
        "author_title": "AI Research Team",
        "content": """# How Virtual Try-On Technology Actually Works

Virtual try-on technology has revolutionized how we shop for clothes and plan outfits. But how does it actually work? This article explores the AI and computer vision that powers virtual outfit visualization.

## The Technology Stack

Virtual try-on systems combine several cutting-edge technologies:

### 1. Computer Vision and Pose Estimation
Before generating any images, the AI needs to understand body shape and pose. Using pose estimation models, the system identifies:
- Key body landmarks (shoulders, waist, hips, knees, ankles)
- Body proportions and measurements
- Current pose and orientation

### 2. Generative AI and Diffusion Models
The core of virtual try-on uses diffusion models—AI systems that generate images by gradually refining random noise into coherent pictures. These models are trained on millions of clothing images to understand:
- How fabric drapes and folds on different body types
- How colors and patterns appear under various lighting conditions
- How garments interact with each other in layered outfits

### 3. Identity Preservation
One of the biggest challenges is maintaining the user's identity—their face, hair, and unique features—while changing their clothing. Advanced techniques include:
- **Face embedding extraction**: Capturing the unique features of your face
- **Identity-consistent generation**: Ensuring the output still looks like you
- **Attribute preservation**: Keeping hairstyle, body shape, and skin tone consistent

## How FitCheck AI's Virtual Try-On Works

### Step 1: Reference Image Analysis
When you upload photos of yourself, our AI analyzes:
- Your body shape and proportions
- Skin tone and features
- Current hairstyle and color
- Preferred angles and poses

### Step 2: Clothing Item Processing
For each item in your digital wardrobe, the AI extracts:
- Cut and silhouette of the garment
- Fabric texture and drape
- Color and pattern details
- How the item should fit on different body types

### Step 3: Realistic Visualization
The AI combines these elements to generate realistic images showing:
- How the outfit looks on your specific body
- Natural fabric draping and folds
- Appropriate shadows and lighting
- Accurate color representation

## Why Virtual Try-On Matters

### Reduce Return Rates
Online shopping returns cost retailers billions annually. Virtual try-on helps customers make confident purchases, reducing return rates by up to 40%.

### Sustainable Fashion
By helping you visualize how pieces work with your existing wardrobe, virtual try-on encourages thoughtful consumption and reduces impulse purchases.

### Time Savings
No more trying on multiple outfits physically. Plan your looks virtually and only change once—when you're ready to wear the chosen outfit.

## The Future of Virtual Try-On

Emerging technologies promise even more realistic experiences:
- **3D body scanning** for perfect fit predictions
- **Real-time AR try-on** using your phone camera
- **Haptic feedback** for texture simulation
- **Size recommendations** based on fit preferences

Experience virtual try-on today with FitCheck AI.""",
    },
    {
        "slug": "capsule-wardrobe-essentials",
        "title": "Building a Capsule Wardrobe: 30 Essential Pieces",
        "excerpt": "Create a versatile, minimalist wardrobe that works harder so you do not have to. Learn which pieces form the foundation of a perfect capsule collection.",
        "category": "Style Guide",
        "date": "2026-02-05",
        "read_time": "10 min read",
        "emoji": "👔",
        "keywords": ["capsule wardrobe", "minimalist fashion", "wardrobe essentials", "sustainable fashion", "versatile clothing"],
        "author": "FitCheck AI Team",
        "author_title": "Style Consultants",
        "content": """# Building a Capsule Wardrobe: 30 Essential Pieces

A capsule wardrobe is a curated collection of timeless, versatile pieces that work together seamlessly. With just 30 carefully chosen items, you can create hundreds of outfit combinations. Here's how to build yours.

## What is a Capsule Wardrobe?

Popularized by Susie Faux in the 1970s, a capsule wardrobe consists of essential clothing items that don't go out of style. The concept has evolved, but the core principle remains: quality over quantity, versatility over trends.

## Benefits of a Capsule Wardrobe

- **Decision fatigue eliminated**: Fewer choices mean faster mornings
- **Money saved**: Invest in quality pieces that last
- **Sustainability**: Buy less, choose well, make it last
- **Personal style clarity**: Define what truly represents you
- **Easier organization**: A smaller wardrobe is easier to maintain

## The 30-Piece Capsule Wardrobe

### Tops (8 pieces)
1. **White button-down shirt** - The ultimate versatile piece
2. **Black turtleneck** - Sophisticated and seasonless
3. **Striped Breton shirt** - Classic French chic
4. **Neutral t-shirt (white, black, or gray)** - The everyday essential
5. **Silk blouse** - Dress up any outfit instantly
6. **Cashmere sweater** - Luxurious comfort
7. **Denim shirt** - Casual versatility
8. **Camisole/top** - Perfect for layering

### Bottoms (7 pieces)
9. **Dark wash jeans** - The ultimate casual staple
10. **Black trousers** - Professional polish
11. **Pencil skirt** - Feminine and professional
12. **A-line skirt** - Flattering and versatile
13. **Tailored shorts** - Summer essential
14. **Wide-leg trousers** - Modern sophistication
15. **Leggings or joggers** - Comfort without sacrificing style

### Dresses (3 pieces)
16. **Little black dress (LBD)** - The ultimate go-to
17. **Day dress** - Easy one-piece dressing
18. **Maxi dress** - Effortless elegance

### Outerwear (4 pieces)
19. **Trench coat** - Timeless sophistication
20. **Blazer** - Instant polish for any outfit
21. **Denim jacket** - Casual layering
22. **Wool coat** - Winter warmth with style

### Shoes (5 pieces)
23. **Black pumps** - Professional essential
24. **White sneakers** - Casual comfort
25. **Ankle boots** - Transitional perfection
26. **Ballet flats** - Comfortable elegance
27. **Sandals** - Summer staple

### Accessories (3 pieces)
28. **Quality leather handbag** - Elevates every outfit
29. **Silk scarf** - Versatile accent piece
30. **Classic watch** - Timeless sophistication

## Color Strategy for Maximum Versatility

### Base Colors (60% of wardrobe)
- Black
- Navy
- Gray
- White
- Beige/Cream

### Accent Colors (30% of wardrobe)
- Burgundy
- Forest green
- Mustard yellow
- Dusty pink

### Statement Pieces (10% of wardrobe)
- One or two bold colors or prints that express your personality

## How to Build Your Capsule Over Time

### Phase 1: Assessment (Week 1)
Use FitCheck AI to catalog your current wardrobe. Identify what you already own that fits the capsule concept.

### Phase 2: Foundation (Months 1-2)
Invest in high-quality basics that form the backbone of your wardrobe: the perfect white t-shirt, well-fitting jeans, a tailored blazer.

### Phase 3: Refinement (Months 3-4)
Add pieces that fill gaps and create new outfit combinations. Each new piece should work with at least 3 existing items.

### Phase 4: Maintenance (Ongoing)
Regularly review your capsule. Remove items that no longer fit or serve you. Add only pieces that truly enhance your collection.

## Using Technology to Maintain Your Capsule

FitCheck AI makes capsule wardrobe management effortless:
- **Track cost-per-wear** to ensure you're getting value from each piece
- **Visualize outfit combinations** before purchasing new items
- **Identify gaps** in your color palette or category coverage
- **Plan seasonal rotations** to keep your capsule fresh

Ready to build your capsule wardrobe? Start by organizing your existing clothes with FitCheck AI.""",
    },
    {
        "slug": "ai-photoshoot-linkedin-profile",
        "title": "How to Create Professional LinkedIn Photos with AI",
        "excerpt": "Get studio-quality headshots without the studio price using AI photoshoot technology. Perfect for job seekers, professionals, and entrepreneurs.",
        "category": "Photoshoot Tips",
        "date": "2026-01-28",
        "read_time": "7 min read",
        "emoji": "📸",
        "keywords": ["AI photoshoot", "LinkedIn profile photo", "professional headshots", "AI photography", "professional photo generator"],
        "author": "FitCheck AI Team",
        "author_title": "Photography Experts",
        "content": """# How to Create Professional LinkedIn Photos with AI

Your LinkedIn profile photo is often your first impression in the professional world. A great headshot can increase profile views by 21 times and connection requests by 9 times. Here's how to create a professional LinkedIn photo using AI technology—no expensive studio required.

## Why Your LinkedIn Photo Matters

Research shows that profiles with professional photos receive:
- **21x more profile views**
- **9x more connection requests**
- **36x more messages**
- Higher trust and credibility ratings

## The Traditional Approach vs. AI

### Traditional Professional Headshots
- Cost: $200-$500+ for a session
- Time: Half day for shooting, plus editing time
- Logistics: Find photographer, book studio, travel to location
- Limited options: Usually 3-5 final images

### AI-Powered Professional Photos
- Cost: Free to $20 for multiple professional shots
- Time: 5 minutes to upload, 2-5 minutes processing
- Convenience: Create from home using your phone
- Unlimited options: Generate multiple styles and backgrounds

## How to Create the Perfect LinkedIn Photo with AI

### Step 1: Choose the Right Reference Photos
Upload 1-4 clear selfies following these guidelines:
- **Good lighting**: Natural light facing your face (window light works perfectly)
- **Neutral background**: Plain wall or simple background
- **Face clearly visible**: No sunglasses, minimal shadows
- **Professional attire**: Wear what you'd wear to an interview
- **Front-facing**: Look directly at the camera
- **Multiple angles**: Provide variety for better results

### Step 2: Select LinkedIn-Optimized Settings
FitCheck AI's LinkedIn style option automatically configures:
- **Professional lighting**: Soft, even illumination
- **Neutral backgrounds**: Gray, white, or subtle office settings
- **Conservative framing**: Head and shoulders composition
- **Natural retouching**: Subtle improvements without looking artificial

### Step 3: Generate and Select
The AI will create multiple professional headshots. Choose based on:
- **Approachability**: A genuine, confident smile
- **Professionalism**: Appropriate for your industry
- **Authenticity**: Still looks like you
- **Quality**: Sharp focus, good lighting

## Best Practices for LinkedIn Profile Photos

### Do:
- **Dress professionally**: Wear industry-appropriate attire
- **Make eye contact**: Look directly at the camera
- **Smile naturally**: Approachable but professional
- **Use recent photos**: Within the last 2 years
- **Fill 60% of frame**: Head and shoulders composition

### Don't:
- Use group photos or cropped group shots
- Include distracting backgrounds
- Wear sunglasses or hats
- Use obvious filters or heavy editing
- Include pets, children, or partners

## Industry-Specific Recommendations

### Corporate/Finance
- Conservative suit or blazer
- Neutral background (gray, navy)
- Subtle, professional smile
- Minimal jewelry

### Creative/Design
- Smart casual to business casual
- Slightly more personality allowed
- Creative but not distracting backgrounds
- Express your personal brand

### Tech/Startup
- Business casual to smart casual
- Approachable, friendly expression
- Modern, clean backgrounds
- Authentic and relatable

### Healthcare/Legal
- Professional attire required
- Conservative, trustworthy presentation
- Traditional backgrounds
- Confident, competent expression

## Optimizing Your Complete LinkedIn Profile

Once you have your perfect AI-generated headshot, complete your profile:
- **Banner image**: Create visual consistency
- **Headline**: Go beyond your job title
- **About section**: Tell your professional story
- **Experience**: Quantify achievements
- **Skills**: Include relevant keywords

Create your professional LinkedIn photo today with FitCheck AI's Photoshoot Generator.""",
    },
    {
        "slug": "outfit-planning-weather-integration",
        "title": "Smart Outfit Planning: Dressing for the Weather",
        "excerpt": "Never get caught in the rain unprepared again with weather-integrated outfit planning. Learn how AI combines forecast data with your wardrobe for perfect daily recommendations.",
        "category": "Outfit Tips",
        "date": "2026-01-20",
        "read_time": "5 min read",
        "emoji": "🌤️",
        "keywords": ["weather outfit planning", "seasonal dressing", "smart wardrobe", "outfit recommendations", "weather-based fashion"],
        "author": "FitCheck AI Team",
        "author_title": "Fashion Technology Team",
        "content": """# Smart Outfit Planning: Dressing for the Weather

We've all been there: stepping out in a light jacket only to face an unexpected downpour, or wearing boots on a surprisingly warm day. Weather-integrated outfit planning eliminates these fashion emergencies by combining real-time forecast data with your existing wardrobe.

## The Problem with Traditional Weather Apps

Standard weather apps tell you the temperature and conditions, but they don't tell you what to wear. You still need to:
- Mentally translate 68°F and partly cloudy into outfit choices
- Remember which of your clothes are appropriate for those conditions
- Consider factors like humidity, wind, and UV index
- Plan for temperature changes throughout the day

## How AI-Powered Weather Outfit Planning Works

### Real-Time Weather Data Integration
FitCheck AI connects to weather services to access:
- Current conditions and temperature
- Hourly forecasts throughout the day
- Precipitation probability and type
- Wind speed and direction
- Humidity levels
- UV index and sun exposure

### Smart Wardrobe Analysis
The AI knows your wardrobe intimately:
- Which items are weather-appropriate (breathable fabrics for heat, insulated layers for cold)
- Seasonal availability of pieces
- Color appropriateness (light colors for sun, dark colors for cold)
- Layering potential of different items

### Personalized Recommendations
Combining these data sources, the AI suggests outfits that:
- Keep you comfortable in predicted conditions
- Account for temperature changes (morning vs. evening)
- Include appropriate accessories (umbrella, sunglasses, layers)
- Match your personal style preferences

## Weather Conditions and Outfit Strategies

### Hot Weather (80°F+/27°C+)
**AI Recommendations:**
- Breathable fabrics: cotton, linen, rayon
- Light colors that reflect heat
- Loose, flowing silhouettes
- Moisture-wicking materials for active days

**Key Items:**
- Sundresses and skirts
- Short-sleeve shirts and tank tops
- Lightweight trousers or shorts
- Breathable footwear

### Cold Weather (Below 50°F/10°C)
**AI Recommendations:**
- Layering system: base, insulating, outer
- Thermal fabrics and wool blends
- Coverage for extremities (gloves, scarves)
- Wind-resistant outer layers

**Key Items:**
- Coats and jackets
- Sweaters and cardigans
- Boots with good insulation
- Warm accessories

### Rainy Weather
**AI Recommendations:**
- Water-resistant materials
- Coverage for hair and accessories
- Non-slip footwear
- Quick-dry fabrics

**Key Items:**
- Raincoat or water-resistant jacket
- Waterproof boots
- Compact umbrella
- Water-resistant bag

### Variable Weather (Transitional Seasons)
**AI Recommendations:**
- Layering pieces that can be added/removed
- Versatile items that work in multiple temperatures
- Accessories for quick adjustments

**Key Items:**
- Lightweight jackets and cardigans
- Scarves for adaptable warmth
- Versatile closed-toe shoes
- Layer-friendly tops

## Using FitCheck AI for Weather-Based Planning

### Morning Recommendations
Each morning, FitCheck AI analyzes the day's forecast and suggests 3-5 outfit options from your wardrobe. Each suggestion includes:
- Weather-appropriate pieces
- Style rating based on your preferences
- Occasion appropriateness
- Comfort level for predicted conditions

### Calendar Integration
Connect your calendar for context-aware suggestions:
- **Outdoor meetings**: Prioritize weather-appropriate professional wear
- **Travel days**: Suggest comfortable, climate-appropriate outfits
- **Events**: Factor in evening temperature drops

### Packing Assistant
Planning a trip? The AI creates a weather-appropriate packing list:
- Analyzes destination forecast
- Selects versatile pieces from your wardrobe
- Suggests outfit combinations for each day
- Ensures appropriate coverage for all conditions

## Tips for Building a Weather-Ready Wardrobe

### Invest in Transitional Pieces
- Lightweight jackets for layering
- Versatile boots that work in multiple conditions
- Neutral scarves and accessories
- Pieces that work across seasons

### Organize by Season
Use FitCheck AI to tag items by season, making weather-based filtering instant.

### Consider Your Climate
Build your wardrobe around your local weather patterns:
- **Hot climates**: Focus on breathable, sun-protective pieces
- **Cold climates**: Invest in quality layering and insulation
- **Variable climates**: Prioritize versatile, transitional items

Never check the weather and your wardrobe separately again. Try FitCheck AI's weather-integrated outfit planning.""",
    },
    {
        "slug": "cost-per-wear-fashion-investment",
        "title": "Understanding Cost-Per-Wear: The Smart Fashion Metric",
        "excerpt": "Learn how to calculate and optimize your wardrobe investments for maximum value. Make smarter purchasing decisions with this simple but powerful metric.",
        "category": "Fashion Finance",
        "date": "2026-01-15",
        "read_time": "6 min read",
        "emoji": "💰",
        "keywords": ["cost per wear", "wardrobe investment", "sustainable fashion", "fashion budgeting", "smart shopping"],
        "author": "FitCheck AI Team",
        "author_title": "Fashion Finance Experts",
        "content": """# Understanding Cost-Per-Wear: The Smart Fashion Metric

Cost-per-wear (CPW) is a simple but powerful metric that helps you understand the true value of your clothing purchases. By calculating CPW, you can make smarter buying decisions, build a more valuable wardrobe, and ultimately save money while dressing better.

## What is Cost-Per-Wear?

Cost-per-wear is calculated by dividing the purchase price of an item by the number of times you've worn it:

**Cost-Per-Wear = Purchase Price ÷ Number of Wears**

### Example Calculations:
- **$20 fast fashion top** worn 3 times = $6.67 per wear
- **$200 quality blazer** worn 100 times = $2.00 per wear
- **$50 mid-range jeans** worn 50 times = $1.00 per wear

## Why Cost-Per-Wear Matters

### It Reveals True Value
That "bargain" $15 shirt you wore twice actually cost $7.50 per wear—more expensive than the $100 quality shirt you wore 30 times ($3.33 per wear).

### It Encourages Mindful Consumption
When you think in terms of cost-per-wear, impulse purchases become less appealing. You start asking: "Will I wear this enough to justify the price?"

### It Supports Sustainable Fashion
Buying fewer, higher-quality pieces reduces waste and environmental impact while often saving money long-term.

### It Helps Optimize Your Wardrobe
Understanding which items give you the best CPW helps you identify gaps and make better future purchases.

## What is a Good Cost-Per-Wear?

### Target Benchmarks by Category:

**Core Basics (t-shirts, jeans, basic tops):** Under $1.00 per wear
**Mid-range Pieces (dresses, blazers, shoes):** $2.00-$5.00 per wear
**Investment Pieces (coats, suits, bags):** $5.00-$10.00 per wear
**Special Occasion (formal wear):** $10.00-$20.00 per wear

## How to Improve Your Wardrobe's Cost-Per-Wear

### Strategy 1: Calculate Before You Buy
Before purchasing, estimate:
- How often will you wear this item?
- For how many seasons/years?
- What's the realistic total wears?

**Example:** A $150 winter coat worn 60 times per year for 5 years = 300 total wears = $0.50 per wear

### Strategy 2: Focus on Versatility
Items that work in multiple contexts deliver better CPW:
- **Versatile example:** A black blazer for work, weekends, and evenings
- **Specific example:** A sequined top for one type of event only

### Strategy 3: Quality Over Quantity
Higher-quality items typically:
- Last longer (more wears before replacement)
- Maintain appearance (you'll want to wear them more)
- Feel better (increases likelihood of reaching for them)

### Strategy 4: Track and Analyze
Use FitCheck AI's wardrobe analytics to:
- Automatically calculate CPW for every item
- Identify your best and worst value pieces
- See trends in your purchasing habits
- Make data-driven decisions for future buys

## Real-World Examples

### The "Investment" Coat
- **Purchase price:** $400
- **Estimated wears:** 80 per year × 8 years = 640 wears
- **Cost-per-wear:** $0.62
- **Verdict:** Excellent investment

### The "Bargain" Trend Item
- **Purchase price:** $25
- **Estimated wears:** 3 times before it's out of style/unloved
- **Cost-per-wear:** $8.33
- **Verdict:** Poor value despite low price

### The Quality Everyday Shoe
- **Purchase price:** $180
- **Estimated wears:** 100 times per year × 3 years = 300 wears
- **Cost-per-wear:** $0.60
- **Verdict:** Smart investment

## Using FitCheck AI to Track Cost-Per-Wear

FitCheck AI makes CPW tracking effortless:

### Automatic Tracking
- Log each wear with a simple tap
- CPW updates automatically
- View trends over time

### Wardrobe Analytics Dashboard
- See your best value pieces
- Identify underutilized items
- Compare CPW across categories

### Purchase Decision Support
- Compare potential purchases by projected CPW
- See how new items would fit your current wardrobe value
- Get recommendations for high-value additions

## Building a High-Value Wardrobe

### The 80/20 Rule
Typically, 80% of your wears come from 20% of your wardrobe. Focus on building that high-value 20%:
- Quality basics in neutral colors
- Well-fitting pieces you love
- Versatile items that work across occasions

### Seasonal Reviews
Every season, review your CPW data:
- **High CPW items:** Consider donating/selling
- **Low CPW items:** Buy similar pieces in different colors
- **Zero wears:** Challenge yourself to style or remove

Ready to optimize your wardrobe's value? Start tracking cost-per-wear with FitCheck AI.""",
    },
]


def parse_date(date_str: str) -> datetime:
    """Parse date string in format 'Jan 15, 2026' to datetime."""
    try:
        return datetime.strptime(date_str, "%Y-%m-%d")
    except ValueError:
        # Fallback to current date if parsing fails
        return datetime.now()


async def migrate_blog_posts():
    """Migrate static blog posts to the database."""
    print("Starting blog posts migration...")
    print(f"Found {len(STATIC_BLOG_POSTS)} static posts to migrate\n")

    # Get database client
    try:
        db = SupabaseDB.get_service_client()
    except Exception as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)

    success_count = 0
    skip_count = 0
    error_count = 0

    for post_data in STATIC_BLOG_POSTS:
        slug = post_data["slug"]
        title = post_data["title"]

        try:
            # Check if post already exists
            existing = (
                db.table("blog_posts")
                .select("id")
                .eq("slug", slug)
                .maybe_single()
                .execute()
            )

            if existing.data:
                print(f"⏭️  Skipping '{title}' - already exists (slug: {slug})")
                skip_count += 1
                continue

            # Prepare post data for insertion
            post_create = BlogPostCreate(
                slug=slug,
                title=title,
                excerpt=post_data["excerpt"],
                content=post_data["content"],
                category=post_data["category"],
                date=parse_date(post_data["date"]).date(),
                read_time=post_data["read_time"],
                emoji=post_data["emoji"],
                keywords=post_data["keywords"],
                author=post_data["author"],
                author_title=post_data.get("author_title"),
                is_published=True,
            )

            # Insert into database
            result = db.table("blog_posts").insert(post_create.model_dump()).execute()

            if result.data:
                print(f"✅ Migrated '{title}' (slug: {slug})")
                success_count += 1
            else:
                print(f"❌ Failed to migrate '{title}' - no data returned")
                error_count += 1

        except Exception as e:
            print(f"❌ Error migrating '{title}': {e}")
            error_count += 1

    print(f"\n{'='*50}")
    print("Migration complete!")
    print(f"  ✅ Successfully migrated: {success_count}")
    print(f"  ⏭️  Skipped (already exists): {skip_count}")
    print(f"  ❌ Errors: {error_count}")
    print(f"{'='*50}")

    if error_count > 0:
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(migrate_blog_posts())
