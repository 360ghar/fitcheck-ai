# Feature: Advanced Features

## Overview

Advanced Features provide additional functionality for wardrobe maintenance, care, and household management. These features enhance the core wardrobe management capabilities.

## User Value

- **Better Care:** Proper garment care extends item life
- **Efficient Management:** Track maintenance and repairs
- **Household Sharing:** Share some items with family
- **Professional Quality:** Enhanced photos for better AI performance
- **Organization:** Export lookbooks for reference

## Functional Requirements

### 1. Laundry Tracking

**Priority:** P1

**Description:** Track which items are dirty, in laundry, and schedule laundry days.

**Requirements:**

**Laundry Schedule:**
- Set laundry days (e.g., Saturday, Wednesday)
- Set reminder notifications
- View upcoming laundry days

**Item Status:**
- Mark items as: Clean, Dirty, In Laundry
- Bulk update multiple items
- Show "dirty" items count

**Laundry Queue:**
- Queue of items marked "dirty"
- Show items that need washing
- Prioritize by: color, fabric type, urgency

**Filtering:**
- Filter wardrobe to show only clean items
- Filter to show dirty items
- Filter to show items in laundry

**Notifications:**
- Remind before laundry day
- Remind to pick up from dry cleaner
- Remind to put away clean laundry

**History:**
- Track laundry frequency per item
- Track days between wears
- Identify items that need frequent washing

**API Endpoints:**

```
POST /api/v1/laundry/schedule
- Set laundry schedule
- Request: JSON
  - days: List<string> ["Monday", "Wednesday", "Saturday"]
  - reminder_time: string (HH:MM)
- Response: 200 OK
  - schedule: laundry_schedule_object
```

```
GET /api/v1/laundry/schedule
- View laundry schedule
- Response: 200 OK
  - schedule: laundry_schedule_object
```

```
POST /api/v1/laundry/queue
- Add items to laundry queue
- Request: JSON
  - item_ids: List<string>
- Response: 201 Created
  - queue: laundry_queue_object
```

```
GET /api/v1/laundry/queue
- View laundry queue
- Response: 200 OK
  - queue: {
        items: List<item_object>
        count: number
        priority: "colors"|"whites"|"delicates"
      }
```

```
POST /api/v1/laundry/queue/process
- Mark laundry as done
- Request: JSON
  - item_ids: List<string>
- Response: 200 OK
  - items_updated: number
```

**Acceptance Criteria:**
- [ ] Laundry schedule can be set and viewed
- [ ] Items can be added to laundry queue
- [ ] Notifications are sent before laundry day
- [ ] Items filter correctly by status
- [ ] Laundry history is tracked

**Error Handling:**
- `400 Bad Request`: Invalid day or item IDs
- `404 Not Found`: Items not found

---

### 2. Alteration Notes

**Priority:** P2

**Description:** Save tailor details, measurements, and notes for altered items.

**Requirements:**

**Tailor Information:**
- Tailor name
- Phone number
- Address
- Notes (specializations, quality, etc.)

**Alteration Details:**
- Type of alteration (hem, take in/let out, etc.)
- Measurements taken
- Before and after photos
- Cost
- Date
- Notes from tailor

**Alteration History:**
- Track all alterations per item
- Show timeline of changes
- Photos of before and after

**Reminders:**
- Set reminder for next alteration (e.g., "get hem re-done in 6 months")
- Notify when due

**Tailor Directory:**
- Save multiple tailors
- Rate tailors
- Notes on each tailor

**API Endpoints:**

```
POST /api/v1/tailors
- Add tailor
- Request: JSON
  - name: string
  - phone: string
  - address: string
  - notes: string
  - rating?: number (1-5)
- Response: 201 Created
  - tailor: tailor_object
```

```
GET /api/v1/tailors
- List saved tailors
- Response: 200 OK
  - tailors: List<tailor_object>
```

```
POST /api/v1/wardrobe/items/{item_id}/alterations
- Add alteration record
- Request: multipart/form-data
  - type: string
  - measurements: string
  - cost: number
  - tailor_id: string
  - before_photo: image file
  - after_photo: image file
  - notes: string
  - reminder_date: ISO8601 date
- Response: 201 Created
  - alteration: alteration_record_object
```

```
GET /api/v1/wardrobe/items/{item_id}/alterations
- View alteration history
- Response: 200 OK
  - alterations: List<alteration_record_object>
```

```
PUT /api/v1/wardrobe/items/{item_id}/alterations/{alteration_id}
- Update alteration record
- Response: 200 OK
  - alteration: updated_record
```

**Acceptance Criteria:**
- [ ] Tailors can be saved and rated
- [ ] Alteration records are complete
- [ ] Before/after photos are saved
- [ ] Reminders are triggered
- [ ] Alteration history is tracked

**Error Handling:**
- `400 Bad Request`: Invalid data
- `404 Not Found`: Item or tailor not found

---

### 3. Care Instructions

**Priority:** P2

**Description:** Store and display washing and care instructions for each item.

**Requirements:**

**Auto-Detect Care Symbols:**
- Scan photo for care labels
- OCR to read symbols
- Convert to readable instructions

**Manual Entry:**
- Enter care instructions manually
- Upload photo of care label
- Add custom notes

**Care Instructions Fields:**
- Washing (machine wash, hand wash, dry clean only)
- Temperature (cold, warm, hot)
- Bleach (do not bleach, non-chlorine bleach)
- Drying (tumble dry, dry flat, hang dry, line dry)
- Ironing (do not iron, low, medium, high)
- Dry cleaning (dry clean only, do not dry clean)

**Care Icons:**
- Display standard care symbols
- Hover to see meaning
- Click for detailed instructions

**Filter by Care Requirements:**
- Show items that can be machine washed
- Show items that require dry cleaning
- Show items with special care requirements

**Care Schedule:**
- Track last wash date
- Suggest when to wash based on usage
- Show items that need special attention

**API Endpoints:**

```
POST /api/v1/wardrobe/items/{item_id}/care-instructions
- Add care instructions
- Request: multipart/form-data
  - label_photo: image file
  - washing: string
  - temperature: string
  - bleach: string
  - drying: string
  - ironing: string
  - dry_cleaning: string
  - notes: string
- Response: 201 Created
  - instructions: care_instructions_object
```

```
GET /api/v1/wardrobe/items/{item_id}/care-instructions
- View care instructions
- Response: 200 OK
  - instructions: care_instructions_object
```

```
PUT /api/v1/wardrobe/items/{item_id}/care-instructions
- Update care instructions
- Response: 200 OK
  - instructions: updated_instructions
```

```
POST /api/v1/wardrobe/items/{item_id}/care-scan
- Auto-detect care instructions from photo
- Request: multipart/form-data
  - photo: image file
- Response: 200 OK
  - detected: {
        washing: string
        temperature: string
        drying: string
        confidence: number
      }
```

```
GET /api/v1/wardrobe/items?care_requirement=dry_clean
- Filter by care requirement
- Response: 200 OK
  - items: List<item_objects>
```

**Acceptance Criteria:**
- [ ] Care instructions can be added manually
- [ ] OCR detection works for clear labels
- [ ] Care symbols are displayed correctly
- [ ] Filtering by care requirements works
- [ ] Instructions are clear and readable

**Error Handling:**
- `400 Bad Request`: Invalid data
- `404 Not Found`: Item not found
- `422 Unprocessable Entity`: OCR cannot read label

---

### 4. Photo Enhancement

**Priority:** P2

**Description:** AI-powered image enhancement to improve photo quality.

**Requirements:**

**Enhancement Types:**
- Brightness and contrast adjustment
- Color correction
- Sharpness enhancement
- Noise reduction
- Background removal

**Auto-Enhance:**
- Automatically analyze photo
- Apply appropriate enhancements
- Show preview before/after
- Option to adjust or accept

**Manual Adjustments:**
- Brightness slider
- Contrast slider
- Saturation slider
- Sharpness slider
- Temperature slider

**Background Removal:**
- Remove background automatically
- Replace with solid color or transparent
- Manual brush to fine-tune

**Batch Enhancement:**
- Apply enhancements to multiple photos
- Save settings as preset

**Enhancement Presets:**
- "Brighten dark photo"
- "Remove yellow tint"
- "Make pop for catalog"
- "Remove background"
- Custom presets

**Quality Metrics:**
- Show quality score before/after
- Highlight issues (blur, noise, etc.)
- Suggest improvements

**API Endpoints:**

```
POST /api/v1/photos/enhance
- Enhance photo
- Request: multipart/form-data
  - photo: image file
  - preset?: string
  - auto_enhance: boolean (default: true)
- Response: 200 OK
  - result: {
        original_url: string
        enhanced_url: string
        improvements: List<string>
        quality_score: {before: number, after: number}
      }
```

```
POST /api/v1/photos/background-remove
- Remove background
- Request: multipart/form-data
  - photo: image file
  - output: "transparent"|"white"|"custom_color"
  - color?: string (hex)
- Response: 200 OK
  - result: {
        original_url: string
        processed_url: string
      }
```

```
POST /api/v1/photos/batch-enhance
- Enhance multiple photos
- Request: multipart/form-data
  - photos: List<image files>
  - preset: string
- Response: 200 OK
  - results: {
        successful: number
        failed: number
        items: List<photo_enhancement_result>
      }
```

**Acceptance Criteria:**
- [ ] Auto-enhance improves photo quality
- [ ] Before/after comparison is clear
- [ ] Manual adjustments work correctly
- [ ] Background removal is accurate
- [ ] Batch processing is efficient

**Error Handling:**
- `400 Bad Request`: Invalid image file
- `422 Unprocessable Entity`: Enhancement failed
- `503 AI Service Unavailable`: Enhancement engine down

---

### 5. Multi-User Households

**Priority:** P2

**Description:** Allow sharing certain items between household members.

**Requirements:**

**Household Setup:**
- Create household
- Invite members via email
- Accept/decline invitations
- View household members

**Item Sharing:**
- Mark items as "sharable"
- Select which household members can access
- Track who currently has item
- Set borrowing limits (days)

**Shared Wardrobe View:**
- See all shared items from household
- Filter by owner
- See item location (who has it)

**Borrowing:**
- Request to borrow shared item
- Owner approves/denies request
- Track borrow history
- Set return reminders

**Permissions:**
- Read-only access to shared items
- Cannot edit other's items
- Can borrow with permission

**Household Settings:**
- Set household name
- Manage members (remove, change roles)
- Set default sharing preferences

**API Endpoints:**

```
POST /api/v1/households
- Create household
- Request: JSON
  - name: string
- Response: 201 Created
  - household: household_object
```

```
POST /api/v1/households/{id}/invite
- Invite member
- Request: JSON
  - email: string
  - role: string
- Response: 201 Created
  - invitation: invitation_object
```

```
POST /api/v1/households/{id}/join
- Accept invitation
- Request: JSON
  - invitation_token: string
- Response: 200 OK
  - household: household_object
```

```
POST /api/v1/wardrobe/items/{item_id}/share
- Share item with household
- Request: JSON
  - share_with: List<string> (user_ids)
  - borrowing_limit_days: number
- Response: 200 OK
  - sharing: item_sharing_object
```

```
GET /api/v1/households/{id}/shared-items
- View shared items
- Response: 200 OK
  - shared_items: List<shared_item_object>
```

```
POST /api/v1/wardrobe/items/{item_id}/borrow
- Request to borrow item
- Request: JSON
  - borrower_id: string
  - days: number
- Response: 201 Created
  - request: borrow_request_object
```

```
POST /api/v1/borrow-requests/{id}/approve
- Approve borrow request
- Response: 200 OK
  - request: approved_request
```

```
PUT /api/v1/wardrobe/items/{item_id}/return
- Mark item as returned
- Response: 200 OK
  - item: updated_item
```

**Acceptance Criteria:**
- [ ] Households can be created and joined
- [ ] Items can be shared with specific members
- [ ] Borrowing requests work correctly
- [ ] Item location is tracked
- [ ] Permissions are enforced

**Error Handling:**
- `400 Bad Request`: Invalid data
- `403 Forbidden`: Not authorized to access item
- `404 Not Found`: Household, item, or user not found
- `409 Conflict`: Request already exists

---

### 6. Export Lookbooks

**Priority:** P2

**Description:** Export outfits as PDF lookbooks for sharing or reference.

**Requirements:**

**Lookbook Creation:**
- Select multiple outfits
- Choose template/layout
- Add custom notes
- Add cover page

**Templates:**
- Grid layout (2x2, 3x2)
- Full-page per outfit
- Magazine style
- Minimalist
- Custom

**Customization:**
- Add title and subtitle
- Add outfit descriptions
- Add color swatches
- Add item breakdown

**Export Options:**
- PDF export
- Image gallery export
- Web page export
- Social media images

**Organization:**
- Save lookbook projects
- Edit later
- Multiple versions

**Sharing:**
- Download PDF
- Share via link
- Email lookbook

**Print-Ready:**
- High resolution
- CMYK color mode
- Bleed/margins configured

**API Endpoints:**

```
POST /api/v1/lookbooks
- Create lookbook
- Request: JSON
  - name: string
  - outfit_ids: List<string>
  - template: string
  - notes: string
- Response: 201 Created
  - lookbook: lookbook_object
```

```
GET /api/v1/lookbooks
- List lookbooks
- Response: 200 OK
  - lookbooks: List<lookbook_object>
```

```
PUT /api/v1/lookbooks/{id}
- Update lookbook
- Request: JSON
  - name?: string
  - outfit_ids?: List<string>
  - template?: string
  - notes?: string
- Response: 200 OK
  - lookbook: updated_lookbook
```

```
POST /api/v1/lookbooks/{id}/export
- Export lookbook
- Request: JSON
  - format: "pdf"|"images"|"web"
  - template: string
  - options: {
        include_descriptions: boolean
        include_color_swatches: boolean
        include_item_breakdown: boolean
      }
- Response: 202 Accepted
  - export: {
        id: string
        status: "processing"
        download_url: string (when ready)
      }
```

```
GET /api/v1/lookbooks/{id}/export/{export_id}
- Check export status
- Response: 200 OK
  - export: export_result_object
```

**Acceptance Criteria:**
- [ ] Lookbooks can be created
- [ ] Multiple templates are available
- [ ] Export generates high-quality output
- [ ] PDF is print-ready
- [ ] Lookbooks can be edited

**Error Handling:**
- `400 Bad Request`: Invalid data
- `404 Not Found`: Lookbook not found
- `422 Unprocessable Entity`: Export failed

---

## Database Schema

### Laundry Schedule Table

```sql
CREATE TABLE laundry_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    days VARCHAR(20)[] NOT NULL,
    reminder_time TIME,
    next_laundry_day DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

CREATE INDEX idx_laundry_schedules_user_id ON laundry_schedules(user_id);
```

### Laundry Queue Table

```sql
CREATE TABLE laundry_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    priority VARCHAR(20) DEFAULT 'normal',
    UNIQUE(user_id, item_id)
);

CREATE INDEX idx_laundry_queue_user_id ON laundry_queue(user_id);
CREATE INDEX idx_laundry_queue_priority ON laundry_queue(priority);
```

### Tailors Table

```sql
CREATE TABLE tailors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tailors_user_id ON tailors(user_id);
```

### Alteration Records Table

```sql
CREATE TABLE alteration_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    tailor_id UUID REFERENCES tailors(id),
    type VARCHAR(100),
    measurements TEXT,
    cost DECIMAL(10, 2),
    before_photo_url VARCHAR(500),
    after_photo_url VARCHAR(500),
    notes TEXT,
    reminder_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_alteration_records_item_id ON alteration_records(item_id);
CREATE INDEX idx_alteration_records_tailor_id ON alteration_records(tailor_id);
```

### Care Instructions Table

```sql
CREATE TABLE care_instructions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    washing VARCHAR(50),
    temperature VARCHAR(50),
    bleach VARCHAR(50),
    drying VARCHAR(50),
    ironing VARCHAR(50),
    dry_cleaning VARCHAR(50),
    label_photo_url VARCHAR(500),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(item_id)
);

CREATE INDEX idx_care_instructions_item_id ON care_instructions(item_id);
```

### Households Table

```sql
CREATE TABLE households (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_households_created_by ON households(created_by);
```

### Household Members Table

```sql
CREATE TABLE household_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(household_id, user_id)
);

CREATE INDEX idx_household_members_household_id ON household_members(household_id);
CREATE INDEX idx_household_members_user_id ON household_members(user_id);
```

### Item Sharing Table

```sql
CREATE TABLE item_sharing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    shared_with UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    borrowing_limit_days INTEGER,
    currently_with UUID REFERENCES users(id),
    borrowed_at TIMESTAMP,
    return_reminder_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(item_id, shared_with)
);

CREATE INDEX idx_item_sharing_item_id ON item_sharing(item_id);
CREATE INDEX idx_item_sharing_shared_with ON item_sharing(shared_with);
CREATE INDEX idx_item_sharing_currently_with ON item_sharing(currently_with);
```

### Borrow Requests Table

```sql
CREATE TABLE borrow_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    borrower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    days INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP
);

CREATE INDEX idx_borrow_requests_item_id ON borrow_requests(item_id);
CREATE INDEX idx_borrow_requests_borrower_id ON borrow_requests(borrower_id);
CREATE INDEX idx_borrow_requests_status ON borrow_requests(status);
```

### Lookbooks Table

```sql
CREATE TABLE lookbooks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    outfit_ids UUID[] NOT NULL,
    template VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lookbooks_user_id ON lookbooks(user_id);
```

### Lookbook Exports Table

```sql
CREATE TABLE lookbook_exports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lookbook_id UUID NOT NULL REFERENCES lookbooks(id) ON DELETE CASCADE,
    format VARCHAR(20) NOT NULL,
    template VARCHAR(50),
    options JSONB,
    status VARCHAR(50) DEFAULT 'processing',
    download_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_lookbook_exports_lookbook_id ON lookbook_exports(lookbook_id);
CREATE INDEX idx_lookbook_exports_status ON lookbook_exports(status);
```

---

## Frontend Components

### LaundrySchedule.tsx
Set and view laundry schedule

### LaundryQueue.tsx
Manage items in laundry queue

### AlterationForm.tsx
Add alteration records

### CareInstructionsForm.tsx
Add and view care instructions

### PhotoEnhancer.tsx
Enhance item photos

### HouseholdSettings.tsx
Manage household members

### ItemSharingPanel.tsx
Share items with household

### BorrowRequestsView.tsx
View and manage borrow requests

### LookbookBuilder.tsx
Create and edit lookbooks

### LookbookExport.tsx
Export lookbooks to PDF

---

## Success Metrics

- **Laundry Adherence:** 60% of users follow laundry schedule
- **Alteration Tracking:** 30% of altered items have records
- **Care Instruction Usage:** 40% of items have care instructions
- **Photo Enhancement:** 50% of uploaded photos are enhanced
- **Household Sharing:** 15% of users share items
- **Lookbook Creation:** 10% of users create lookbooks

---

## Future Enhancements

- AI garment age detection (when to retire items)
- Professional cleaning scheduling
- Subscription to dry cleaning services
- Household analytics (shared item usage)
- Collaborative lookbook creation
- Integration with garment repair services
- Seasonal storage recommendations
- Virtual closet organization tips
