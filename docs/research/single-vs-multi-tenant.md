# Single-Tenant vs Multi-Tenant Architecture Decision

**Date:** 2025-01-19
**Status:** Decided - Single-Tenant for Initial Launch
**Review Date:** After 5 communities onboarded

## Executive Summary

**Decision: Start with Single-Tenant Architecture**

Use one Firebase project per community (e.g., `community-champion-hills`, `community-lake-lure`) rather than one shared project with `communityId` partitioning.

**Key Reasons:**
- Better security and data isolation
- Clearer billing and cost attribution
- Simpler queries (no `communityId` filtering)
- Easy exit strategy (transfer project to community)
- Scale (5-10 communities) doesn't justify multi-tenant complexity
- Cost difference is minimal (~$5-10/month for 10 communities)

---

## The Question

Should we scale this community app by:
1. **Single-Tenant:** Create separate Firebase projects per community
2. **Multi-Tenant:** Use one Firebase project with `communityId` as partition key

---

## Option 1: Single-Tenant (Separate Projects)

### Architecture
```
community-champion-hills/
  ├── users/
  ├── groups/
  ├── messages/
  └── ...

community-lake-lure/
  ├── users/
  ├── groups/
  ├── messages/
  └── ...
```

### Pros
✅ **Clear billing** - Each community pays for their own Firebase usage
✅ **Complete data isolation** - Impossible to query wrong community's data
✅ **Independent scaling** - One community's spike doesn't affect others
✅ **Simpler queries** - No `communityId` filter needed
✅ **Better performance** - Smaller datasets (300 vs 3,000 users)
✅ **Easy exit** - Transfer Firebase project to community
✅ **Failure isolation** - Outage affects only one community
✅ **Regulatory compliance** - Easier data residency requirements

### Cons
❌ **Deployment overhead** - Must deploy to multiple projects (scriptable)
❌ **Version fragmentation** - Communities could be on different versions
❌ **Admin tool complexity** - Need multi-project admin interface
❌ **Analytics fragmentation** - Harder to see aggregate metrics

### Cost Per Community (300 users)
```
Firestore:
  - Reads: 1.5M/month = $0.36
  - Writes: 300k/month = $1.08
  - Storage: 1GB = $0.18

Cloud Functions:
  - Invocations: 100k/month = $0.40
  - Compute: 50k GB-seconds = $0.90

FCM: Free
Auth: Free
Storage: 5GB = $0.125

TOTAL: ~$3-4/month per community
```

**10 communities:** $30-40/month

---

## Option 2: Multi-Tenant (One Shared Project)

### Architecture
```
single-project/
  ├── users/{userId}
  │   └── communityId: "champion-hills"
  ├── groups/{communityId}-{groupId}
  ├── messages/{messageId}
  │   └── communityId: "champion-hills"
```

**Every query must filter:**
```dart
.where('communityId', '==', currentCommunityId)
```

### Pros
✅ **Single deployment** - Update all communities at once
✅ **Unified admin panel** - Manage all from one interface
✅ **Aggregate analytics** - See trends across communities
✅ **Lower fixed costs** - One set of Firebase fees
✅ **Faster development** - One codebase, one pipeline

### Cons
❌ **Complex billing** - Must manually track usage per `communityId`
❌ **Query overhead** - Every query needs `communityId` filter
❌ **Security complexity** - Must prevent cross-community access
❌ **Noisy neighbor** - One large community affects others
❌ **Single point of failure** - Outage affects all communities
❌ **Data leak risk** - Developer error could expose wrong data
❌ **Hard to migrate out** - Difficult to extract one community's data

### Cost For 10 Communities (3,000 users)
```
Firestore:
  - Reads: 15M/month = $3.60
  - Writes: 3M/month = $10.80
  - Storage: 10GB = $1.80

Cloud Functions:
  - Invocations: 1M/month = $0.40
  - Compute: 500k GB-seconds = $9.00

TOTAL: ~$25-30/month
```

**Savings vs single-tenant:** ~$5-10/month (not significant)

---

## Why Single-Tenant Wins

### 1. Business Model Uncertainty
We haven't validated:
- How to charge communities
- What communities are willing to pay
- Whether they value data isolation

**Start simple, validate first.**

### 2. Scale Doesn't Justify Complexity
Multi-tenant makes sense for:
- 50+ tenants
- Price-sensitive SaaS customers
- Rapid deployment needs

Our reality:
- 5-10 communities
- HOAs can afford $10-50/month
- **Complexity cost > $5-10/month savings**

### 3. Security Is Critical
HOA data includes:
- Resident addresses
- Private discussions
- Financial information
- Incident reports

**One community's breach should NEVER affect others.**

### 4. Clear Exit Strategy
Communities may want to:
- Self-host later
- Switch vendors
- Take data ownership

**Single-tenant:** Transfer Firebase project
**Multi-tenant:** Complex data extraction

### 5. Transparent Billing
**Single-tenant:**
- Show Firebase console to community
- Bill: "Firebase ($4) + our fee ($X)"
- Transparent, trustworthy

**Multi-tenant:**
- Manual tracking required
- Less transparent

### 6. Better Performance
- Smaller datasets (300 vs 3,000 users)
- Faster queries
- No filter overhead
- Simpler indexes

---

## Implementation Plan

### Phase 1: Now (Single-Tenant Foundation)

1. **Keep separate projects**
   - `community-champion-hills`
   - `community-lake-lure`

2. **Build deployment script**
```bash
# scripts/deploy-all.sh
for project in champion-hills lake-lure; do
  firebase use $project
  firebase deploy
done
```

3. **Create multi-project admin tool**
   - Flutter web app
   - Project switcher dropdown
   - Same codebase, different Firebase configs
   - Features: seed data, manage users, analytics

4. **Automate with GitHub Actions**
```yaml
strategy:
  matrix:
    project: [champion-hills, lake-lure]
```

### Phase 2: After 5 Communities (Evaluate)

**Track:**
- Deployment time overhead
- Actual costs per community
- Customer feedback on isolation
- Admin tool maintenance burden

**Decision criteria:**
- If deployment > 30 min → Consider multi-tenant
- If costs > $10/community → Consider multi-tenant
- If isolation highly valued → Stay single-tenant

### Phase 3: 10+ Communities (Scale Decision)

**Option A: Optimize Single-Tenant**
- Better CI/CD automation
- Enhanced admin dashboard
- "Enterprise isolated" tier

**Option B: Hybrid Model**
- Offer both tiers:
  - **Standard:** Multi-tenant (lower cost)
  - **Premium:** Single-tenant (isolation)
- Build migration tools
- Let communities choose

---

## Admin Tool Architecture

Build one admin Flutter web app that connects to any project:

```dart
class AdminApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProject = ref.watch(selectedProjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Community Admin'),
        actions: [
          ProjectSelectorDropdown(
            projects: [
              FirebaseProject('champion-hills', config1),
              FirebaseProject('lake-lure', config2),
            ],
          ),
        ],
      ),
      body: AdminDashboard(projectId: selectedProject.id),
    );
  }
}
```

**Benefits:**
- ✅ Unified admin experience
- ✅ Single-tenant data isolation
- ✅ One codebase

---

## Cost Comparison Summary

| Metric | Single-Tenant (10) | Multi-Tenant (10) |
|--------|-------------------|-------------------|
| **Monthly Cost** | $30-40 | $25-30 |
| **Security Risk** | Very Low | Low-Medium |
| **Billing Complexity** | None | High |
| **Query Performance** | Excellent | Good |
| **Exit Strategy** | Easy | Hard |

**Winner:** Single-tenant (better isolation for only ~$5-10/month more)

**Breakeven:** ~50+ communities (where ops overhead > cost savings)

---

## Migration Path (If Needed Later)

### When to Consider Multi-Tenant
- 20+ communities
- Significant deployment overhead
- Customers demand lower costs
- Cross-community features needed

### Migration Strategy
1. Build parallel multi-tenant project
2. Create export/import tools
3. Migrate willing communities gradually
4. Offer both tiers (standard vs premium)
5. Keep both running during transition

---

## Action Items

- [ ] Build deployment automation script
- [ ] Create multi-project admin tool
- [ ] Set up GitHub Actions multi-project deploy
- [ ] Create seed data templates
- [ ] Monitor costs for first 3 communities
- [ ] Review after 5 communities

---

## References

- [Firebase Pricing](https://firebase.google.com/pricing)
- [Firestore Multi-tenancy Best Practices](https://cloud.google.com/firestore/docs/solutions/multi-tenancy)
- `lib/core/utils/group_initializer.dart`
- `lib/core/utils/seed_data.dart`

---

## Decision Log

| Date | Decision | Reason |
|------|----------|--------|
| 2025-01-19 | Start Single-Tenant | Better isolation, simpler billing, easier exits. Scale doesn't justify multi-tenant complexity. |
| TBD | Review after 5 communities | Evaluate overhead vs benefits |
