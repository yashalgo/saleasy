# Product Requirements Document

# SalesVoice
## Sales Call Recording & Analytics Platform

**Version:** 2.3
**Date:** January 2026
**Status:** Draft
**Classification:** Confidential

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Target Users](#3-target-users)
4. [Product Overview](#4-product-overview)
5. [Detailed Features & Requirements](#5-detailed-features--requirements)
6. [Technical Architecture](#6-technical-architecture)
7. [Data Model](#7-data-model)
8. [UI/UX Requirements](#8-uiux-requirements)
9. [Non-Functional Requirements](#9-non-functional-requirements)
10. [Security & Privacy](#10-security--privacy)
11. [Monitoring & Observability](#11-monitoring--observability)
12. [Testing Strategy](#12-testing-strategy)
13. [Metrics & Success Criteria](#13-metrics--success-criteria)
14. [Roadmap & Phases](#14-roadmap--phases)
15. [Play Store Launch Requirements](#15-play-store-launch-requirements)
16. [Cost Analysis](#16-cost-analysis)
17. [Risks & Mitigations](#17-risks--mitigations)
18. [Open Questions & Future Considerations](#18-open-questions--future-considerations)
19. [Appendix](#19-appendix)

---

## 1. Executive Summary

SalesVoice is a mobile-first sales call recording and analytics platform for businesses in India. Field sales agents record in-person customer meetings, the platform automatically transcribes conversations (supporting Hindi-English code-switching), and generates AI-powered insights including summaries, key topics, sentiment analysis, and actionable next steps.

Business owners gain visibility into sales team activities through a web dashboard, enabling accountability, performance monitoring, and data-driven coaching.

### Key Value Propositions

| Stakeholder | Value |
|-------------|-------|
| **Sales Agents** | Effortless call documentation, automatic transcription, personal performance insights, audio playback within retention window |
| **Business Owners** | Complete visibility into field sales activities, accountability, team performance metrics, real-time dashboard updates |
| **The Business** | Reduced manual reporting overhead, better sales coaching, improved customer relationship tracking, cost-optimized AI pipeline |

### MVP Scope

The MVP focuses on the core recording-to-insight loop: one-tap recording with pause/resume, offline-first architecture with silence-boundary chunked sync, AI-powered transcription and analysis via cost-optimized providers with automatic fallback, time-limited audio playback, and a clean owner dashboard with real-time updates.

---

## 2. Problem Statement

### For Sales Agents

- Manual documentation of customer conversations is time-consuming and incomplete
- Important details, commitments, and next steps are frequently forgotten
- No systematic way to improve sales techniques through self-review
- No personal performance analytics to track improvement

### For Business Owners

- Limited visibility into what happens during customer meetings
- Reliance on self-reported data which may be inaccurate
- Difficulty identifying coaching opportunities and performance issues
- No standardized metrics for comparing agent performance
- No real-time awareness of field activity

### Market Gap

Enterprise solutions like Gong and Chorus are priced for large organizations and focused on phone/video calls. No affordable, India-focused solution handles Hindi-English code-switching and works reliably in low-connectivity field conditions.

---

## 3. Target Users

### Primary Personas

#### Persona 1: Sales Agent (Ramesh)

| Attribute | Details |
|-----------|---------|
| **Age** | 25-40 years |
| **Role** | Field Sales Executive / Medical Representative / Insurance Agent |
| **Tech Proficiency** | Moderate - comfortable with WhatsApp, basic Android apps |
| **Device** | Mid-range Android smartphone (₹10,000-25,000) |
| **Connectivity** | Variable - often in areas with poor network coverage |
| **Daily Routine** | 4-6 customer meetings per day, travels between locations |
| **Pain Points** | Manual reporting, forgetting meeting details, proving productivity |
| **Goals** | Minimize paperwork, improve sales performance, build customer relationships |

#### Persona 2: Business Owner (Priya)

| Attribute | Details |
|-----------|---------|
| **Age** | 35-55 years |
| **Role** | Business Owner / Sales Manager / Regional Head |
| **Tech Proficiency** | Moderate to High - uses laptop for business operations |
| **Team Size** | 5-50 sales agents |
| **Industry** | Pharma, Insurance, FMCG, B2B Sales, Real Estate |
| **Pain Points** | No visibility into field activities, inconsistent reporting, coaching at scale |
| **Goals** | Ensure accountability, identify top performers, improve team-wide results |

### Target Industries

- **Pharmaceutical:** Medical representatives visiting doctors and hospitals
- **Insurance:** Agents meeting prospects for policy discussions
- **FMCG:** Sales executives visiting retail outlets and distributors
- **B2B Sales:** Account executives meeting business clients
- **Real Estate:** Agents meeting property buyers and sellers

---

## 4. Product Overview

### Product Components

| Component | Platform | Primary Users | Description |
|-----------|----------|---------------|-------------|
| Agent Mobile App | Android (Native Kotlin) | Sales Agents | Recording, playback, viewing transcripts/insights, call history, personal analytics |
| Owner Dashboard | Next.js (Web, Responsive) | Business Owners/Admins | Team management, call review, audio playback, analytics, reports, real-time updates |
| Backend Services | Supabase + Cloudflare R2 | System | Auth, database, audio storage, AI processing pipeline with provider fallback |

### Core Capabilities

#### Recording & Transcription

- One-tap recording initiation with pause/resume support
- Offline-first architecture — recordings stored locally until sync
- Support for calls up to 2 hours duration
- Hindi-English code-switching support in transcription
- On-device silence-boundary chunking (variable 45-90s segments) and resumable background upload
- Audio quality gate (silence/noise detection) before upload
- Screen-off recording via Android foreground service
- Audio playback within 7-day R2 retention window

#### AI-Powered Insights

- Automatic call summarization with confidence scoring
- Key topics and products discussed extraction
- Next steps identification
- Sentiment analysis (positive/neutral/negative)
- Thumbs up/down feedback on AI-generated insights
- Transcript correction mechanism for inaccurate words/phrases
- Anti-hallucination guardrails and language-aware processing

#### Team Management

- Company profile creation with shareable invite codes
- Agent onboarding via deep-linked invite link
- Role-based access control: owner, admin, agent
- Agent removal with data retention and immediate token revocation

#### Reporting

- Daily summary reports (brief, WhatsApp-optimized)
- WhatsApp share functionality for reports
- Per-agent and team-wide metrics

---

## 5. Detailed Features & Requirements

### 5.1 Agent Mobile Application

#### 5.1.1 Authentication

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| AUTH-001 | Phone number OTP-based authentication | P0 |
| AUTH-002 | Automatic session persistence (stay logged in) | P0 |
| AUTH-003 | Join company via deep-linked invite link/code | P0 |
| AUTH-004 | Logout functionality | P1 |
| AUTH-005 | OTP rate limiting: max 5 requests/hour per number, 3 verification attempts per OTP, 10-minute OTP expiry | P0 |
| AUTH-006 | Show "You've been removed" screen if agent is removed from company | P0 |
| AUTH-007 | Minimum app version check on launch with force-update prompt | P0 |
| AUTH-008 | In-app account & data deletion flow: user can request deletion of their account and all associated data from within the app (Play Store requirement) | P0 |

#### 5.1.2 Call Recording

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| REC-001 | One-tap recording start from home screen | P0 |
| REC-002 | Visual recording indicator (timer, waveform) | P0 |
| REC-003 | One-tap recording stop | P0 |
| REC-004 | Audio saved locally in compressed format (M4A/AAC, mono, 64kbps) | P0 |
| REC-005 | Maximum recording duration: 2 hours | P0 |
| REC-006 | Recording continues when screen is off via Android foreground service with persistent notification and wakelock | P0 |
| REC-007 | Low storage warning before recording | P1 |
| REC-008 | Consent checkbox with timestamp before recording starts (agent confirms verbal consent obtained) | P0 |
| REC-009 | Pause/resume recording button | P0 |
| REC-010 | Minimum call duration threshold: 30 seconds. Below threshold, prompt "Discard this recording?" | P1 |
| REC-011 | Single active recording enforcement — cannot start new recording while one is in progress | P0 |
| REC-012 | Audio focus handling: gracefully handle phone call interruptions, microphone conflicts, and voice assistant activations during recording | P0 |
| REC-013 | Audio quality gate: detect silence ratio (>80% silence) and low audio energy before queuing upload. Flag poor-quality recordings for agent review. | P1 |
| REC-014 | Audio playback: agent can play recorded audio within 7-day R2 retention window | P1 |
| REC-015 | Prominent disclosure screen shown before first recording: full-screen disclosure explaining what data is collected (audio, metadata), how it is used (transcription, AI analysis), and that audio is recorded. User must affirmatively consent before proceeding. Required by Play Store. | P0 |

#### 5.1.3 Post-Call Metadata Entry

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| META-001 | Customer name field with autocomplete from existing customers (fuzzy matching) | P0 |
| META-002 | Customer phone number field (optional, used for deduplication) | P1 |
| META-003 | Company name field (optional) | P1 |
| META-004 | Call type selection: First Meeting / Follow-up / Closing | P0 |
| META-005 | Outcome selection: Positive / Neutral / Negative | P0 |
| META-006 | Create new customer if not found in autocomplete | P0 |
| META-007 | Skip/Save later option for metadata (call still syncs) | P0 |
| META-008 | Agent notes field (free-text, optional) for personal context | P1 |
| META-009 | Edit call metadata after saving (customer name, type, outcome, notes) | P1 |

#### 5.1.4 Offline & Sync

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| SYNC-001 | All recordings saved locally first (offline-first) | P0 |
| SYNC-002 | On-device audio chunking: split recording into variable 45-90s chunks at nearest silence boundary (>=200ms gap). No overlap. | P0 |
| SYNC-003 | Resumable chunked upload — failed chunks resume from last successful chunk, not from zero | P0 |
| SYNC-004 | Background upload when network available (max 2 parallel chunk uploads) | P0 |
| SYNC-005 | Sync status indicator (X calls pending upload) | P0 |
| SYNC-006 | Automatic retry on upload failure (max 5 retries per chunk with exponential backoff) | P0 |
| SYNC-007 | After max retries exhausted: show "Upload failed — tap to retry" in call history | P0 |
| SYNC-008 | Upload order: smallest-first for quick progress indication | P1 |
| SYNC-009 | WiFi-preferred upload option in settings | P2 |
| SYNC-010 | Manual sync trigger button | P1 |
| SYNC-011 | Removed agent's pending uploads still sync (data belongs to company) | P0 |
| SYNC-012 | Cache last 50 call insights locally for offline viewing | P1 |
| SYNC-013 | File type validation: only M4A/AAC audio accepted. Server-side max file size: 250MB. MIME type verification. | P0 |
| SYNC-014 | Crash recovery: on app launch, scan for orphaned chunk files. Validate with MediaExtractor. Recover valid chunks and queue for upload. Delete corrupt chunks. | P0 |

#### 5.1.5 Call History & Insights

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| HIST-001 | List view of agent's own calls (newest first) with cursor-based pagination (20 per page) | P0 |
| HIST-002 | Call detail view with full transcript | P0 |
| HIST-003 | AI-generated summary display | P0 |
| HIST-004 | Key topics/products as tags | P0 |
| HIST-005 | Next steps list | P0 |
| HIST-006 | Sentiment indicator | P1 |
| HIST-007 | Filter calls by date range (default: last 7 days) | P1 |
| HIST-008 | Filter calls by customer | P1 |
| HIST-009 | Search within transcripts | P2 |
| HIST-010 | Thumbs up/down feedback on AI-generated summary and insights | P1 |
| HIST-011 | Transcript correction: tap a word/phrase to suggest correction | P2 |
| HIST-012 | Audio playback in call detail: streaming via presigned URL within 7-day window | P1 |

#### 5.1.6 Agent Personal Analytics

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| AGENT-ANALYTICS-001 | Total calls this week / this month | P1 |
| AGENT-ANALYTICS-002 | Outcome distribution (positive/neutral/negative) for the agent | P1 |
| AGENT-ANALYTICS-003 | Calls this week vs last week comparison | P2 |
| AGENT-ANALYTICS-004 | Most-visited customers list | P2 |

#### 5.1.7 Notifications

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| NOTIF-001 | Batched push notifications: aggregate insights ("3 insights ready") every 30 minutes instead of per-call | P1 |
| NOTIF-002 | Batched notification for sync failures: aggregate failures every 30 minutes | P1 |
| NOTIF-003 | Quiet hours: suppress non-critical notifications 9PM-8AM (default, configurable) | P1 |
| NOTIF-004 | Request `POST_NOTIFICATIONS` runtime permission on Android 13+ (API 33) before sending any notifications. Gracefully degrade if denied. | P0 |

#### 5.1.8 First-Time Experience

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| FTX-001 | Welcome screen after joining company with brief tutorial (3 screens max) | P1 |
| FTX-002 | Empty state on home screen: "Record your first call" CTA with visual guidance | P1 |
| FTX-003 | Microphone permission request with explanation of why it's needed | P0 |
| FTX-004 | Battery optimization whitelisting prompt for OEM devices (Xiaomi, Vivo, Oppo, Samsung) | P0 |
| FTX-005 | Declare `foregroundServiceType="microphone"` for the recording foreground service in AndroidManifest.xml. Required for Android 14+ (API 34). | P0 |

---

### 5.2 Owner Web Dashboard

#### 5.2.1 Authentication & Onboarding

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| DASH-AUTH-001 | Phone number OTP-based authentication | P0 |
| DASH-AUTH-002 | Company profile creation (name, basic info) | P0 |
| DASH-AUTH-003 | Generate shareable invite link (deep-linked with Android App Links) | P0 |
| DASH-AUTH-004 | Generate invite codes | P1 |
| DASH-AUTH-005 | Regenerate/invalidate invite links | P2 |
| DASH-AUTH-006 | OTP rate limiting (same rules as agent: 5/hr, 3 attempts, 10-min expiry) | P0 |
| DASH-AUTH-007 | Empty state for new company: "Invite your first agent" prompt with copy-link CTA | P1 |

#### 5.2.2 Team Management

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| TEAM-001 | View list of all agents | P0 |
| TEAM-002 | View agent details (name, phone, join date, calls count) | P0 |
| TEAM-003 | Remove agent from company (with confirmation dialog) | P0 |
| TEAM-004 | Removed agent data retained for owner view | P0 |
| TEAM-005 | Agent status indicator (active/removed) | P1 |
| TEAM-006 | Removing agent immediately invalidates their auth tokens | P0 |
| TEAM-007 | Add admin role: owner can promote an agent to admin (admin sees all calls, manages agents) | P1 |
| TEAM-008 | Configure per-agent daily call limit (default: 15, configurable 1-50) | P1 |

#### 5.2.3 Call Review

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| REVIEW-001 | View all calls across all agents with cursor-based pagination (default: last 7 days) | P0 |
| REVIEW-002 | Filter by agent | P0 |
| REVIEW-003 | Filter by date range | P0 |
| REVIEW-004 | Filter by customer | P1 |
| REVIEW-005 | Filter by outcome (positive/neutral/negative) | P1 |
| REVIEW-006 | Call detail view with transcript | P0 |
| REVIEW-007 | View AI summary and insights | P0 |
| REVIEW-008 | View customer conversation history (all calls to same customer) | P1 |
| REVIEW-009 | View failed calls with option to manually trigger reprocessing | P1 |
| REVIEW-010 | Real-time call list updates via Supabase Realtime (new calls appear without page refresh) | P1 |
| REVIEW-011 | Audio playback for owner/admin within 7-day R2 retention window | P1 |

#### 5.2.4 Analytics & Metrics

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| ANALYTICS-001 | Total calls today/this week/this month | P0 |
| ANALYTICS-002 | Calls per agent breakdown | P0 |
| ANALYTICS-003 | Average call duration | P1 |
| ANALYTICS-004 | Outcome distribution (positive/neutral/negative) | P1 |
| ANALYTICS-005 | Active agents today indicator | P0 |

#### 5.2.5 Daily Reports

| Requirement ID | Requirement | Priority |
|----------------|-------------|----------|
| REPORT-001 | Auto-generated daily summary (brief format, optimized for WhatsApp sharing) | P0 |
| REPORT-002 | Total calls and active agents count | P0 |
| REPORT-003 | Per-agent highlights (calls, outcomes) | P0 |
| REPORT-004 | Share report via WhatsApp (share intent, max 500 characters for readability) | P0 |
| REPORT-005 | View historical daily reports | P2 |
| REPORT-006 | Customizable report time (default 8 PM) | P2 |

---

## 6. Technical Architecture

### 6.1 Technology Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Mobile App | Native Kotlin (Android) | Best performance on mid-range Android, native foreground service/wakelock support, optimal audio recording APIs |
| Owner Dashboard | Next.js | Fast development, good Supabase integration, responsive |
| Backend Database & Auth | Supabase | Auth, PostgreSQL database, Realtime subscriptions, Edge Functions |
| Audio Storage | Cloudflare R2 | S3-compatible, zero egress fees, ~$0.015/GB/month |
| Transcription | Groq Whisper v3 Turbo (primary) / OpenAI Whisper (fallback) / Sarvam AI Saarika v2 (Hindi evaluation, Phase 2) | Groq Turbo: $0.04/hr. Supports Hindi and 98 other languages. Hindi-English code-mixed WER ~25-34%; A/B test with Sarvam AI ($0.35/hr) in Phase 2 |
| LLM Processing | GPT-4o Mini (primary) / Claude Haiku (fallback) | Summary generation, insight extraction, sentiment analysis |
| Push Notifications | Firebase Cloud Messaging | Industry standard for Android, free |
| Async Job Queue | Inngest / Trigger.dev | Reliable async processing with retries, checkpointing, independent stage scaling |
| Crash Reporting | Firebase Crashlytics | Free, unlimited, production-grade |
| Error Tracking | Sentry (free tier) | Backend error tracking (supplements centralized logging) |
| Centralized Logging | Axiom or Betterstack | Structured logging across all services, dashboards, alerts. Free tier covers MVP (~$0-25/month) |
| Target SDK | API 34 (Android 14) | Play Store requires targeting recent API level; enables foregroundServiceType declaration |
| Build Format | Android App Bundle (.aab) | Play Store requirement since August 2021; enables dynamic delivery and smaller downloads |
| CI/CD | GitHub Actions + Fastlane (Android), Vercel (Dashboard), Supabase CLI (migrations) | Automated build, test, deploy |

### 6.2 System Architecture

The system uses Supabase as the core backend for auth, database, and realtime, with Cloudflare R2 as a dedicated audio storage layer. Processing is handled through an async job queue (Inngest/Trigger.dev) with per-stage checkpointing and provider fallback.

#### Component Overview

- **Mobile App (Kotlin):** Recording (foreground service), local storage (Room/SQLite), on-device silence-boundary chunking, resumable sync, audio playback, offline caching
- **Web Dashboard (Next.js):** Owner-facing interface for team management, analytics, audio playback, and real-time call monitoring via Supabase Realtime
- **Supabase Auth:** Phone OTP authentication for agents, owners, and admins
- **Supabase Database (PostgreSQL):** All structured data with Row Level Security
- **Cloudflare R2:** Audio chunks with lifecycle policy (auto-delete after 7 days)
- **Async Job Queue (Inngest/Trigger.dev):** Transcription pipeline, LLM processing, report generation with per-stage checkpointing

### 6.3 Processing Pipeline

**Call Processing Flow (with checkpointing):**

```
Stage 1: UPLOAD
  1. Agent stops recording -> Audio saved locally
  2. Agent enters metadata -> Stored in local Room DB
  3. On-device: split audio into variable 45-90s chunks at silence boundaries
  4. Background service uploads chunks to Cloudflare R2 (resumable, 2 parallel max)
  5. All chunks uploaded -> Call status set to 'uploaded'
  6. Job enqueued in async queue

Stage 2: TRANSCRIPTION (independent retry)
  7. Worker downloads audio chunks from R2
  8. Sends chunks to transcription provider (parallel, max 5 concurrent)
  9. Concatenates transcript segments in chunk order
  10. Saves transcript to call_insights table
  11. Call status set to 'transcribed'

Stage 3: ANALYSIS (independent retry)
  12. Worker sends transcript to LLM for summary, topics, next steps, sentiment, confidence
  13. Saves insights to call_insights table
  14. Call status set to 'completed'
  15. Queues push notification for next batch cycle

Error handling:
  - Each stage retries independently (max 5 retries with exponential backoff)
  - Stage 2 failure does NOT re-upload audio
  - Stage 3 failure does NOT re-transcribe
  - Provider fallback: 3 consecutive errors -> switch to fallback provider for 5 minutes
  - After max retries: call status set to 'failed', owner notified
  - Owner can manually trigger reprocessing from dashboard
```

### 6.4 Audio Chunking Strategy

```
On-device (before upload):
+-- Input: single M4A/AAC file (mono, 64kbps)
+-- Split into variable 45-90s chunks at nearest silence boundary (>=200ms gap)
+-- Target ~60s per chunk, each ~480KB
+-- No overlap between chunks
+-- Chunks named: {call_id}_chunk_{index}.m4a
+-- Manifest file: {call_id}_manifest.json (chunk count, order, boundaries)

Server-side (during transcription):
+-- Download all chunks from R2
+-- Transcribe each chunk independently via transcription provider (parallel)
+-- Concatenate transcripts in chunk order
+-- Produce single continuous transcript
```

### 6.5 Offline Sync Architecture

```
Local Room DB tables:
+-- pending_uploads (call_id, chunk_paths[], metadata, retry_count, status)
+-- cached_calls (last 50 synced calls with insights for offline viewing)
+-- cached_customers (for autocomplete while offline)

Sync logic:
+-- On app open: check pending_uploads, attempt upload (smallest-first)
+-- On network restore: trigger sync via connectivity broadcast receiver
+-- Foreground service with 15-min periodic sync (when app alive)
+-- Max 2 parallel chunk uploads to avoid saturating bandwidth
+-- Show badge: "3 calls pending sync"
+-- After max retries: show "Upload failed -- tap to retry"
+-- Removed agent's pending uploads still sync to company

Crash recovery:
+-- On app launch: check `is_recording_active` SharedPreferences flag
+-- If true (abnormal termination): scan local chunk directory
+-- Validate each file with MediaExtractor
+-- Re-queue valid chunks for upload
+-- Delete corrupt/unrecoverable chunks
```

### 6.6 Deep Linking Architecture

```
Invite link format: https://app.salesvoice.in/invite/{invite_code}

Android App Links setup:
+-- assetlinks.json hosted at https://app.salesvoice.in/.well-known/assetlinks.json
+-- Intent filter in AndroidManifest.xml for app.salesvoice.in/invite/*
+-- If app installed -> opens app directly, auto-joins company
+-- If app not installed -> web fallback page with Play Store redirect
+-- Invite code extracted from URL and passed to join API

Web fallback page:
+-- Shows company name and "Download SalesVoice" CTA
+-- Play Store badge link
+-- Manual invite code entry option
```

### 6.7 Provider Abstraction

```
TranscriptionProvider interface:
+-- transcribe(audioChunk) -> TranscriptSegment
+-- Implementations:
    +-- GroqWhisperProvider (primary)
    +-- OpenAIWhisperProvider (fallback)

LLMProvider interface:
+-- extractInsights(transcript) -> CallInsights
+-- Implementations:
    +-- GPT4oMiniProvider (primary)
    +-- ClaudeHaikuProvider (fallback)

Fallback behavior:
+-- Circuit breaker pattern per provider
+-- 3 consecutive errors -> switch to fallback provider
+-- Fallback active for 5 minutes, then retry primary
+-- Health check endpoint monitors provider status
+-- All provider switches logged for observability
```

---

## 7. Data Model

### 7.1 Entity Relationship Overview

The data model has six core entities: Companies, Users, Customers, Calls, Call Insights, and Daily Reports. A company has one owner, optional admins, and many agents. Agents make calls to customers. Each call generates one set of insights after processing.

```
companies
    |
    +-- 1:N -> users (owner + admins + agents)
    |
    +-- 1:N -> customers
    |
    +-- 1:N -> calls
    |
    +-- 1:N -> daily_reports

calls
    |
    +-- 1:1 -> call_insights
```

### 7.2 Table Definitions

#### companies

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| name | VARCHAR(255) | NOT NULL | Company display name |
| invite_code | VARCHAR(20) | UNIQUE, NOT NULL | Shareable code for agent onboarding |
| max_daily_calls_per_agent | INTEGER | DEFAULT 15 | Configurable daily call limit per agent |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification timestamp |

> **Note:** Owner is derived via `users WHERE role = 'owner' AND company_id = ?`. No `owner_id` column to avoid circular FK.

#### users

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier (Supabase Auth ID) |
| phone_number | VARCHAR(15) | UNIQUE, NOT NULL | Phone number for auth |
| name | VARCHAR(255) | NOT NULL | User display name |
| role | ENUM | NOT NULL | Values: owner, admin, agent |
| company_id | UUID | FK -> companies, NULLABLE | Company association |
| status | ENUM | DEFAULT 'active' | Values: active, removed |
| created_at | TIMESTAMP | DEFAULT NOW() | Registration timestamp |
| fcm_token | VARCHAR(255) | NULLABLE | Firebase Cloud Messaging device token |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification timestamp |

#### customers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| company_id | UUID | FOREIGN KEY -> companies | Parent company |
| name | VARCHAR(255) | NOT NULL | Customer/prospect name |
| phone_number | VARCHAR(15) | NULLABLE | Customer phone (optional, for dedup) |
| company_name | VARCHAR(255) | NULLABLE | Customer's company name |
| created_by | UUID | FOREIGN KEY -> users | Agent who created this customer |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification timestamp |

#### calls

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| agent_id | UUID | FOREIGN KEY -> users | Agent who made the call |
| company_id | UUID | FOREIGN KEY -> companies | Company association |
| customer_id | UUID | FK -> customers, NULLABLE | Customer (nullable if metadata skipped) |
| call_type | ENUM | NULLABLE | first_meeting, follow_up, closing |
| outcome | ENUM | NULLABLE | positive, neutral, negative |
| agent_notes | TEXT | NULLABLE | Agent's personal notes |
| duration_seconds | INTEGER | NOT NULL | Call duration |
| recorded_at | TIMESTAMP | NOT NULL | When recording started |
| uploaded_at | TIMESTAMP | NULLABLE | When upload completed |
| status | ENUM | NOT NULL | recording, uploading, uploaded, transcribing, transcribed, analyzing, completed, failed |
| retry_count | INTEGER | DEFAULT 0 | Processing retry attempts per current stage |
| audio_path | VARCHAR(500) | NULLABLE | R2 storage path for audio chunks |
| chunk_count | INTEGER | DEFAULT 0 | Number of audio chunks |
| audio_quality_flag | BOOLEAN | DEFAULT false | True if audio quality gate detected issues |
| failed_stage | VARCHAR(50) | NULLABLE | Pipeline stage that failed (transcription/analysis) |
| failed_reason | TEXT | NULLABLE | Error message from failed processing |
| consent_timestamp | TIMESTAMP | NULLABLE | When agent confirmed verbal consent obtained |
| created_at | TIMESTAMP | DEFAULT NOW() | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification timestamp |

#### call_insights

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| call_id | UUID | FK -> calls, UNIQUE | Associated call |
| transcript | TEXT | NOT NULL | Full transcription text |
| summary | TEXT | NULLABLE | AI-generated summary |
| key_topics | JSONB | NULLABLE | Array of topics discussed |
| next_steps | JSONB | NULLABLE | Array of action items |
| sentiment | ENUM | NULLABLE | positive, neutral, negative |
| confidence | DECIMAL(3,2) | NULLABLE | LLM confidence score 0.0-1.0 |
| dominant_language | VARCHAR(20) | NULLABLE | Detected dominant language of transcript |
| coaching_notes | TEXT | NULLABLE | Future: AI coaching suggestions |
| feedback_rating | SMALLINT | NULLABLE | User feedback: 1 (thumbs down) or 5 (thumbs up) |
| transcript_corrections | JSONB | NULLABLE | Array of {original, corrected, position} |
| processing_cost_cents | INTEGER | NULLABLE | Total processing cost in paisa |
| created_at | TIMESTAMP | DEFAULT NOW() | Processing completion timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification timestamp |

#### daily_reports

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| company_id | UUID | FOREIGN KEY -> companies | Company association |
| report_date | DATE | NOT NULL | Date of the report |
| report_content | TEXT | NOT NULL | Generated report text (<500 chars for WhatsApp) |
| total_calls | INTEGER | NOT NULL | Calls that day |
| active_agents | INTEGER | NOT NULL | Agents who made calls |
| created_at | TIMESTAMP | DEFAULT NOW() | Generation timestamp |

#### subscriptions (skeleton for future billing)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| company_id | UUID | FK -> companies, UNIQUE | Company association |
| plan | ENUM | NOT NULL | starter, growth, business, enterprise |
| status | ENUM | NOT NULL | active, trialing, cancelled, past_due |
| max_agents | INTEGER | NOT NULL | Agent limit for plan |
| max_minutes_monthly | INTEGER | NOT NULL | Transcription minutes limit |
| current_period_start | TIMESTAMP | NOT NULL | Billing period start |
| current_period_end | TIMESTAMP | NOT NULL | Billing period end |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification timestamp |

#### audit_log

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| actor_id | UUID | FK -> users | Who performed the action |
| action | VARCHAR(100) | NOT NULL | e.g., 'agent.removed', 'role.changed' |
| resource_type | VARCHAR(50) | NOT NULL | e.g., 'user', 'call', 'company' |
| resource_id | UUID | NULLABLE | ID of affected resource |
| details | JSONB | NULLABLE | Action-specific context |
| ip_address | VARCHAR(45) | NULLABLE | Request IP address |
| created_at | TIMESTAMP | DEFAULT NOW() | Event timestamp |

### 7.3 Row Level Security Policies

- **Agents:** Can read/write their own calls and customers within their company. Can read (not write) company details.
- **Admins:** Can read all calls, customers, and users within their company. Can remove agents.
- **Owners:** Full read/write on all company data. Can manage roles, remove agents/admins.
- **Cross-company:** No user can access data from other companies.
- **Removed agents:** RLS policies deny all access. Token revocation provides defense in depth.

### 7.4 File Storage Structure (Cloudflare R2)

```
salesvoice-audio/
+-- {company_id}/
    +-- {call_id}/
        +-- manifest.json
        +-- chunk_000.m4a
        +-- chunk_001.m4a
        +-- ...
```

- R2 lifecycle rule: auto-delete objects older than 7 days
- All access via presigned URLs (generated server-side, 15-minute expiry)
- Zero egress fees for processing pipeline downloads

### 7.5 Database Indexes

```sql
-- Call lookups by agent and company
CREATE INDEX idx_calls_agent_recorded ON calls (agent_id, recorded_at DESC);
CREATE INDEX idx_calls_company_recorded ON calls (company_id, recorded_at DESC);

-- Partial index for non-terminal call statuses (pipeline monitoring)
CREATE INDEX idx_calls_status ON calls (status) WHERE status NOT IN ('completed');

-- Customer search
CREATE INDEX idx_customers_company_name ON customers (company_id, name);
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_customers_name_trgm ON customers USING gin (name gin_trgm_ops);

-- Insights and reports
CREATE INDEX idx_call_insights_call ON call_insights (call_id);
CREATE INDEX idx_daily_reports_company_date ON daily_reports (company_id, report_date DESC);

-- Active users per company
CREATE INDEX idx_users_company ON users (company_id) WHERE status = 'active';
```

---

## 8. UI/UX Requirements

### 8.1 Design Principles

- **Simplicity First:** Minimize taps to complete core actions. Recording should be one tap.
- **Offline-Aware:** Always show sync status. Never block the user due to connectivity.
- **Low-End Device Friendly:** Optimize for mid-range Android. Avoid heavy animations.
- **Trust Building:** Clear feedback on what's happening (uploading, processing, complete).
- **Accessible:** Minimum 48dp touch targets, WCAG AA color contrast, colorblind-safe outcome indicators (icons alongside colors).

### 8.2 Agent App Screens

#### Home / Recording Screen
- Large 'Record' button (primary action)
- Sync status badge ('3 calls pending')
- Quick access to recent calls
- Company name in header
- Personal stats summary (calls this week)
- Empty state: "Record your first call" with illustration

#### Active Recording Screen
- Large timer showing duration
- Audio waveform with real-time level indicator
- 'Pause' and 'Stop' buttons (equally prominent)
- Minimal UI to avoid distraction
- Persistent notification with timer + pause/stop controls

#### Post-Call Metadata Screen
- Customer name input with fuzzy autocomplete
- Customer phone number input (optional)
- Call type selector (pill buttons)
- Outcome selector (color-coded with icons for colorblind accessibility)
- Notes field (optional, multiline)
- Audio quality warning banner (if flagged)

#### Call History Screen
- List sorted by date (newest first), paginated (20 per page)
- Each card: customer name, date/time, duration, outcome badge, status
- Failed calls highlighted with "Tap to retry"
- Filter chips (date range, customer)

#### Call Detail Screen
- Header: customer name, call type badge, outcome badge
- Audio playback controls (if within 7-day retention window)
- Agent notes section (editable)
- Summary section (collapsible) with thumbs up/down
- Key topics as tags
- Next steps as checklist
- Full transcript (scrollable, tappable words for correction)
- Edit button for metadata

#### Personal Analytics Screen
- Calls this week / this month counters
- Outcome distribution chart
- Most-visited customers list

### 8.3 Owner Dashboard Screens

#### Dashboard Home
- Key metrics cards (calls today, active agents, outcome breakdown)
- Recent calls list (real-time updates via Supabase Realtime)
- Agent activity summary
- Quick filters

#### Team Management
- Agent list with status and role badge
- Invite link with copy button
- Remove agent action (with confirmation)
- Promote to admin action
- Configure daily call limit

#### Calls View
- Filterable table/list with cursor-based pagination
- Default: last 7 days
- Columns: Agent, Customer, Date, Duration, Type, Outcome, Status
- Audio playback controls (within 7-day window)
- Click to expand details
- Failed calls tab with reprocess button

#### Reports
- Today's summary (brief format)
- Share to WhatsApp button

---

## 9. Non-Functional Requirements

### 9.1 Performance

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| App launch time | < 3 seconds | Time from tap to home screen ready |
| Recording start latency | < 500ms | Time from tap to recording active |
| Transcript processing | < 5 minutes for 1-hour call | End-to-end processing time |
| Dashboard page load | < 2 seconds | Time to interactive |
| Offline operation | 100% core features | Recording, viewing cached calls/insights |
| Chunk upload speed | < 5 seconds per chunk on 4G | Individual chunk upload time |

### 9.2 Scalability

| Metric | MVP Target | Year 1 Target |
|--------|------------|---------------|
| Concurrent companies | 100 | 1,000 |
| Total agents | 1,000 | 10,000 |
| Daily calls processed | 5,000 | 50,000 |
| Audio storage (R2, peak with 7-day retention) | 500 GB | 5 TB |

### 9.3 Reliability

- **System uptime:** 99.5% availability (excluding planned maintenance)
- **Data durability:** Zero data loss for completed uploads
- **Processing reliability:** < 1% permanent failure rate (after retries per stage)
- **Offline resilience:** Core recording and cached insight viewing works without internet
- **Pipeline recovery:** Each processing stage independently retryable; no wasted work on partial failures
- **Provider fallback:** Automatic failover ensures continued operation during provider outages

### 9.4 Compatibility

- **Minimum SDK:** Android 8.0 (API 26)
- **Target SDK:** API 34 (Android 14) — required by Play Store. Implies: `POST_NOTIFICATIONS` runtime permission (API 33+), `foregroundServiceType` declaration (API 34+)
- **Target devices:** Mid-range smartphones (2GB+ RAM)
- **OEM testing:** Xiaomi (MIUI), Samsung (OneUI), Vivo (FuntouchOS), Oppo (ColorOS), Realme (RealmeUI)
- **Web browsers:** Chrome 90+, Safari 14+, Firefox 90+, Edge 90+
- **Screen sizes:** Responsive design for mobile, tablet, desktop

### 9.5 Localization

- **MVP languages:** English (default)
- **Transcription languages:** English, Hindi, Hindi-English code-mixed
- **Future:** Hindi UI, regional language transcription

### 9.6 Accessibility

- Minimum touch target size: 48dp (Android Material guidelines)
- Color contrast: WCAG AA compliance (4.5:1 for text, 3:1 for large text)
- Outcome indicators: icons alongside colors (not color-only) for colorblind users
- Screen reader compatibility for core flows (recording, call history)

---

## 10. Security & Privacy

### 10.1 Authentication & Authorization

- Phone OTP-based authentication (no passwords)
- OTP rate limiting: max 5 requests/hour per phone number, max 3 verification attempts per OTP, 10-minute OTP expiry
- Block disposable/VoIP numbers (use provider validation)
- JWT tokens for session management:
  - Access token expiry: 1 hour
  - Refresh token expiry: 7 days (agents) / 14 days (owners/admins)
  - Refresh token rotation on each use
- Immediate token revocation when agent is removed (Supabase Auth admin API)
- Row Level Security for data isolation
- Role-based access: owner > admin > agent
- Invite-only company membership
- Minimum app version enforcement on API calls (reject outdated clients)

### 10.2 Data Protection

- All data encrypted in transit (TLS 1.3)
- Data encrypted at rest (Supabase default for database, R2 default for storage)
- Audio files auto-deleted after 7 days via R2 lifecycle policy
- Audio access via presigned URLs only (15-minute expiry, generated server-side)
- No direct/public URLs to audio files

### 10.3 Upload Security

- Server-side file validation:
  - MIME type check (audio/mp4, audio/aac only)
  - Max file size per chunk: 5MB
  - Max total file size per call: 250MB
  - Audio header verification (reject non-audio files)
- Per-agent daily call limit (configurable, default 15) as cost guardrail
- Rate limiting on all API endpoints

### 10.4 Privacy

| Aspect | Approach |
|--------|----------|
| **Consent model** | Checkbox + timestamp — agent confirms verbal consent via in-app checkbox. Consent timestamp logged per recording. |
| **In-app reminder** | Displayed before each recording starts |
| **Prominent disclosure** | Full-screen disclosure shown before first audio recording, explaining what data is collected, how it is used, and that audio is recorded. Required by Play Store Prominent Disclosure policy. |
| **In-app data deletion** | User can request account and all associated data deletion from within the app. Deletion completes within 60 days. Required by Play Store. |
| **Data ownership** | Company owns call data, retained even after agent removal |
| **Agent privacy** | Agents cannot see other agents' calls |

### 10.5 Compliance

- Privacy policy at a publicly accessible URL, linked in both the Play Store listing and within the app's settings screen. Terms of service similarly linked.
- Data stored in India-region servers (Supabase Singapore/Mumbai, R2 Asia-Pacific)
- Execute DPAs with Groq, OpenAI/Anthropic, Firebase, Sentry before launch
- DPDP-compliant privacy policy and consent mechanism
- Consent acknowledgment checkbox before each recording (agent confirms verbal consent obtained)
- Consent timestamp logged per recording
- Data deletion API for right-to-erasure requests

### 10.6 Mobile App Security

- Encrypt local audio files using AES-256 via Android Keystore
- Encrypt Room database using SQLCipher
- Certificate pinning for all API endpoints (pin intermediate CA)
- Tokens in EncryptedSharedPreferences (Keystore-backed)
- R8/ProGuard code obfuscation
- FLAG_SECURE on transcript/insights activities

### 10.7 API Security

- Input validation and sanitization on all API endpoints
- CORS restricted to dashboard domain only
- Presigned URL download logging and rate limiting
- Presigned URL expiry: 15 minutes for all downloads
- Request idempotency keys on all mutating endpoints

### 10.8 Infrastructure Security

- Supabase audit logs and MFA for dashboard access
- Supabase project admin access limited to max 2 people
- Dependency scanning in CI/CD (Dependabot/Snyk)
- gitleaks pre-commit hook for secret scanning
- All secrets in environment variables, never in code

### 10.9 RLS Testing

- Automated RLS policy test suite running in CI
- Test every permutation: agent reads own calls, agent cannot read other agent's calls, cross-company isolation, removed agent denied access

### 10.10 Incident Response

- Severity levels: P0 (data breach, 15 min response), P1 (account compromise, 1 hr), P2 (service degradation, 4 hr), P3 (minor issue, 24 hr)
- Data breach notification within 72 hours (DPDP Act)
- Audio leak protocol: wait for presigned URL expiry (15 min), notify affected companies
- Quarterly DR drill: restore backup to test environment

---

## 11. Monitoring & Observability

### 11.1 Mobile App Monitoring

| Tool | Purpose | Cost |
|------|---------|------|
| Firebase Crashlytics | Crash reporting, ANR detection, device-specific issues | Free (unlimited) |
| Firebase Analytics | App usage, screen flows, retention | Free |
| Custom sync metrics | Upload success/failure rates, chunk retry counts, pending upload age | Built-in |

#### Key Mobile Metrics
- Crash-free users rate (target: >99.5%)
- Recording start success rate
- Average sync time per call
- Sync failure rate by network type (WiFi vs 4G vs 3G)
- Pending upload age distribution
- Audio quality gate rejection rate
- App performance on target OEM devices

### 11.2 Backend Monitoring

| Tool | Purpose | Cost |
|------|---------|------|
| Axiom or Betterstack | Primary centralized logging, structured log aggregation, dashboards, alerting | Free tier (~$0-25/month) |
| Sentry (free tier) | Error tracking, supplements centralized logging | Free (5K events/month) |
| Supabase Dashboard | Database metrics, API latency, connection pool usage | Included |
| Job queue dashboard (Inngest/Trigger.dev) | Processing pipeline visibility, retry tracking, stage latency | Included in plan |

#### Structured Logging Requirements
- All services emit structured JSON logs with: timestamp, service, level, message, trace_id, user_id, company_id
- Log pipeline processing events: stage transitions, provider switches, retry attempts, failures
- Log provider health: response times, error rates, circuit breaker state changes
- Retention: 30 days for standard logs, 90 days for error/security logs

#### Key Backend Metrics
- Processing pipeline success rate per stage (target: >99%)
- Average processing latency by stage (upload -> transcribed -> completed)
- Transcription cost per call (tracked in `processing_cost_cents`)
- Provider fallback frequency and duration
- Failed calls count and age
- API response times (p50, p95, p99)
- Active database connections vs pool limit
- R2 storage usage and lifecycle deletion rate

### 11.3 Alerting

| Alert | Condition | Channel |
|-------|-----------|---------|
| Processing failure spike | >5% calls failing in 1 hour | Email/Slack |
| Transcription provider down | 3 consecutive API failures (circuit breaker open) | Email/Slack |
| Provider fallback activated | Primary provider circuit breaker tripped | Email/Slack |
| Database connection pool exhaustion | >80% connections used | Email/Slack |
| R2 storage approaching limit | >80% of budget threshold | Email |
| Agent with 0 synced calls for 48+ hours | Agent recorded locally but nothing synced | Dashboard warning for owner |

---

## 12. Testing Strategy

### 12.1 Device Testing Matrix

| Device | OS | Price Range | Why |
|--------|------|-------------|-----|
| Xiaomi Redmi Note 12 | MIUI 14 / Android 13 | ₹12,000 | Most popular mid-range, aggressive battery optimization |
| Samsung Galaxy M14 | OneUI 5 / Android 13 | ₹13,000 | Second most popular, different OEM behavior |
| Vivo Y56 | FuntouchOS / Android 13 | ₹14,000 | Vivo-specific background restrictions |
| Realme Narzo 60 | RealmeUI / Android 13 | ₹15,000 | Realme-specific auto-start restrictions |
| Low-end: Samsung Galaxy A04 | OneUI Core / Android 12 | ₹8,000 | 2GB RAM stress testing |

### 12.2 OEM-Specific Test Playbooks

#### MIUI (Xiaomi) — 8 tests
1. Battery optimization: verify recording survives "Battery Saver" mode
2. Autostart: confirm app is in autostart whitelist, recording starts after reboot
3. Background restrictions: test with "No restrictions" vs "Restrict background activity"
4. Notification handling: verify foreground service notification persists across MIUI notification management
5. App lock: recording continues when MIUI app lock activates
6. Memory management: recording survives aggressive MIUI memory cleanup
7. Dual-app: verify correct behavior if user creates dual instance
8. Screen recorder conflict: verify audio recording unaffected by MIUI screen recorder

#### Samsung (OneUI) — 6 tests
1. Sleeping Apps: verify app is not placed in "Sleeping apps" list
2. Deep Sleeping: verify app excluded from "Deep sleeping apps"
3. Battery optimization: test with "Unrestricted" battery setting
4. Bixby conflicts: verify no audio focus conflicts with Bixby voice activation
5. Secure Folder: verify app behavior when installed in Secure Folder
6. Good Lock: verify notification and foreground service with Good Lock customizations

#### Vivo (FuntouchOS) — 4 tests
1. Autostart: verify autostart permission granted and persists after reboot
2. Background power: test with "Allow background activity" enabled
3. iManager: verify app whitelisted in iManager battery and memory optimization
4. Notifications: verify foreground notification not suppressed by Vivo notification manager

#### Oppo (ColorOS) — 4 tests
1. Battery optimization: verify app excluded from battery optimization
2. Autostart: confirm autostart manager whitelist
3. App freeze: verify app not auto-frozen by ColorOS app management
4. Notifications: verify persistent notification not killed by ColorOS

#### Realme (RealmeUI) — 3 tests
1. Autostart: verify autostart permission granted
2. Battery optimization: verify excluded from battery optimization
3. App quick freeze: verify recording not affected by Quick Freeze feature

### 12.3 Test Categories

#### Unit Tests
- Audio silence-boundary chunking logic (variable chunk sizes, boundary detection, manifest generation)
- Sync queue ordering (smallest-first)
- Retry logic with exponential backoff
- OTP rate limiting logic
- Customer fuzzy matching
- Audio quality gate (silence detection, energy thresholds)
- Token expiry and refresh logic
- Provider circuit breaker logic
- Crash recovery: orphaned chunk validation

#### Integration Tests
- End-to-end recording -> chunking -> upload -> R2 storage flow
- Supabase Auth OTP flow with rate limiting
- RLS policy verification (agent can't see other agent's calls, cross-company isolation)
- Deep link invite flow (app installed vs not installed)
- Presigned URL generation and expiry
- Job queue: enqueue -> process -> checkpoint -> complete
- Job queue: failure -> retry -> eventual success
- Job queue: max retries -> permanent failure -> owner notification
- Provider fallback: primary failure -> automatic switch -> recovery
- Audio playback via presigned URL streaming

#### Recording Edge Case Tests
- Recording while screen is off (foreground service + wakelock)
- Recording during incoming phone call (audio focus loss/regain)
- Recording when battery drops below 5%
- Recording when storage is nearly full
- Starting recording while another is in progress (should block)
- Recording < 30 seconds (discard prompt)
- Recording exactly 2 hours (max duration cutoff)
- App force-killed during recording (crash recovery on next launch)
- Pause/resume across screen on/off cycles

#### Offline & Sync Tests
- Record 5 calls offline -> come online -> verify all sync in order
- Upload interrupted mid-chunk -> verify resume from last successful chunk
- Network flapping (connect/disconnect rapidly) during sync
- Upload with only 2G connectivity (very slow)
- Max retries exhausted -> verify "tap to retry" shown
- Removed agent's pending uploads still sync
- Verify cached insights available offline after sync
- Crash recovery: force-kill during upload -> verify chunk recovery on relaunch

#### Processing Pipeline Tests
- Normal flow: 30-minute call -> transcription -> analysis -> completed
- Transcription failure -> retry -> success (verify no duplicate transcripts)
- Analysis failure -> retry (verify transcription not re-run)
- Corrupt audio chunk -> graceful failure, skip chunk, note gap in transcript
- Concurrent processing of 50+ calls (load test)
- 2-hour call with many chunks (stress test)
- Provider fallback: simulate primary down -> verify fallback used -> verify primary recovery

#### Security Tests
- Verify RLS: agent A cannot access agent B's calls
- Verify RLS: company A cannot access company B's data
- Removed agent's token is rejected immediately
- Presigned URL expired -> returns 403
- Upload non-audio file -> rejected
- Upload oversized file -> rejected
- OTP brute force (>3 attempts) -> blocked
- OTP spam (>5 requests/hour) -> rate limited

#### Dashboard Tests
- Empty state rendering (new company, zero calls)
- Pagination with 10,000+ calls
- Real-time updates (new call appears without refresh)
- Filter combinations (agent + date range + outcome)
- Failed call reprocessing from dashboard
- WhatsApp share generates correct format (<500 chars)
- Audio playback controls for calls within retention window

### 12.4 UAT / Beta Program

#### Alpha (2 weeks)
- 5-8 internal users
- Focus: core recording loop, sync reliability, basic dashboard functionality
- Exit criteria: zero data loss, <2% sync failure rate, all P0 requirements functional

#### Closed Beta (4 weeks)
- 5-8 companies (40-50 agents)
- Real-world field conditions across target OEMs
- Focus: OEM compatibility, transcription quality (Hindi-English), battery/background behavior
- Weekly feedback surveys, daily crash monitoring
- Exit criteria: >95% recording success rate, >90% sync success within 1 hour, transcription rated "useful" by >70% of agents

#### Open Beta (3 weeks)
- 20-30 companies
- Focus: scale testing, onboarding flow, billing readiness
- Monitor: pipeline throughput, cost per call at scale, dashboard performance under load
- Exit criteria: system handles 1,000+ daily calls, onboarding completion >80%, no P0 bugs

### 12.5 Performance Benchmarks

| Scenario | Target | Test Method |
|----------|--------|-------------|
| App cold start on 2GB RAM device | < 3 seconds | Automated via Firebase Test Lab |
| Recording start latency | < 500ms | Manual timing on test devices |
| Chunk upload on 4G | < 5 seconds per chunk | Network-conditioned test |
| Chunk upload on 3G | < 15 seconds per chunk | Network-conditioned test |
| Dashboard load with 1000 calls | < 2 seconds TTI | Lighthouse CI |
| 50 concurrent call processing | All complete within 10 minutes | Load test via k6/Artillery |

### 12.6 QA Process

- **Pre-merge:** Unit tests + integration tests run in CI (GitHub Actions)
- **Weekly:** Manual testing on all 5 devices in the device matrix
- **Pre-release:** Full regression on recording, sync, processing, and dashboard flows
- **Post-release:** Monitor Crashlytics for new crash clusters within 24 hours

---

## 13. Metrics & Success Criteria

### 13.1 Key Performance Indicators

#### Acquisition Metrics

| Metric | Definition | MVP Target (Month 3) |
|--------|------------|----------------------|
| Companies onboarded | Total companies with active subscription | 50 |
| Total agents | Total agents across all companies | 300 |
| Activation rate | % of signed-up agents who record first call within 7 days | 70% |

#### Engagement Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| Daily Active Agents | Agents who record at least 1 call/day | 60% of total agents |
| Calls per agent per day | Average calls recorded | 3-4 calls |
| Dashboard daily visits | Unique owner logins per day | 80% of owners |
| Report share rate | % of owners who share daily report | 50% |

#### Quality Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| Transcription accuracy | Word Error Rate (WER) | < 15% for English, < 25% for code-mixed |
| Processing success rate | % of calls fully processed | > 99% |
| Sync success rate | % of uploads completing within 24 hours | > 98% |
| AI insight feedback | % of thumbs-up ratings on insights | > 70% |

#### Business Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| Monthly Recurring Revenue (MRR) | Total subscription revenue | ₹2,00,000 by Month 6 |
| Churn rate | % of companies canceling per month | < 5% |
| Net Promoter Score (NPS) | Customer satisfaction | > 40 |

### 13.2 MVP Success Criteria

The MVP will be considered successful if, within 3 months of launch:

- 50+ companies actively using the platform
- 300+ agents recording calls regularly
- 1,000+ calls processed weekly
- 70%+ of agents find the transcription accurate enough to be useful
- 5+ organic referrals from existing customers

---

## 14. Roadmap & Phases

### Phase 1: MVP (Weeks 1-10)

**Goal:** Core recording-to-insight loop working end-to-end with production-grade reliability

#### Week 1-2: Foundation
- CI/CD pipeline: GitHub Actions for Android (Fastlane), Vercel for dashboard, Supabase CLI for database migrations
- Supabase project setup (auth, database, Realtime)
- Cloudflare R2 bucket setup with lifecycle rules
- Kotlin Android project setup with Room DB, foreground service scaffolding
- Next.js dashboard project setup
- Data model implementation with RLS policies
- Async job queue setup (Inngest/Trigger.dev)
- Deep linking setup (assetlinks.json, web fallback page)
- Provider abstraction layer (transcription + LLM interfaces)
- Centralized logging setup (Axiom/Betterstack)

#### Week 3-4: Agent App Core
- Phone OTP authentication with rate limiting
- Recording functionality with foreground service + wakelock (screen-off support)
- Pause/resume recording
- Consent checkbox with timestamp
- Audio quality gate (silence/energy detection)
- On-device silence-boundary chunking
- Crash recovery logic (orphaned chunk detection)
- Resumable chunked upload to R2
- Post-call metadata entry with fuzzy customer autocomplete
- Local Room DB for offline storage + cached insights

#### Week 5-6: Agent App Polish
- Call history with pagination
- Call detail view with transcript and audio playback
- Agent personal analytics screen
- First-time experience (tutorial, empty states)
- Sync status UI, "tap to retry" for failed uploads
- Force-update version check
- OEM battery optimization whitelisting prompts

#### Week 7-8: Backend Processing
- Transcription pipeline via provider abstraction (Groq primary, OpenAI fallback)
- Transcript concatenation (no stitching needed with silence-boundary chunks)
- LLM insight generation with confidence scoring (summary, topics, next steps, sentiment)
- Provider circuit breaker and automatic fallback
- Processing checkpointing (independent stage retries)
- Batched push notifications via FCM
- Processing cost tracking per call
- Failed call handling (owner reprocessing)

#### Week 9-10: Owner Dashboard & Launch Prep
- Dashboard authentication and company setup
- Team management (invite, remove, admin role)
- Call list with filters, pagination, and real-time updates
- Call detail view with insights and audio playback
- Daily report generation (brief format)
- WhatsApp share integration
- Firebase Crashlytics + Sentry + centralized logging integration
- Bug fixes and performance optimization
- Device matrix testing + OEM playbook execution

### Phase 2: Enhancement (Weeks 11-18)

- Improved Hindi-English transcription (Sarvam AI A/B evaluation)
- Advanced analytics on dashboard
- Customer conversation history grouping
- Transcript search
- Thumbs up/down feedback on insights
- Transcript correction mechanism
- Payment integration (subscription billing)
- Customer phone number deduplication improvements

### Phase 3: Scale (Weeks 19-26)

- iOS app (evaluate Flutter or native Swift)
- AI coaching suggestions
- Industry-specific insight templates
- WhatsApp Business API for automated reports
- Data export (CSV)
- Hindi UI localization
- Self-hosted Whisper migration (if volume justifies)
- Location tracking (optional GPS per call, with consent)

---

## 15. Play Store Launch Requirements

This section covers all Google Play Store compliance requirements that must be satisfied before the first production release.

### 15.1 Store Listing Assets

| Asset | Specification | Notes |
|-------|---------------|-------|
| App Icon | 512×512 PNG, 32-bit, no alpha | High-res icon used on Play Store listing |
| Feature Graphic | 1024×500 JPEG or PNG | Displayed at top of store listing |
| Screenshots | Min 2, recommended 8; JPEG or PNG, 16:9 or 9:16 | Show key flows: recording, insights, call history, dashboard |
| Short Description | Max 80 characters | e.g., "Record sales calls. Get AI insights instantly." |
| Full Description | Max 4000 characters | Feature summary, benefits, supported languages |
| Category | Business | Primary store category |
| Contact Email | Required | Displayed on store listing |
| Privacy Policy URL | Required | Must be publicly accessible; same URL linked in-app |
| Support URL | Required | Link to support/FAQ page |

### 15.2 Data Safety Form

The Play Store Data Safety section must accurately declare all data collected and shared. Complete this form in Play Console before publishing.

| Data Type | Play Store Category | Collected | Shared | Purpose | Optional/Required |
|-----------|-------------------|-----------|--------|---------|-------------------|
| Audio recordings | Audio files | Yes | No | App functionality (transcription) | Required |
| Phone number | Phone number | Yes | No | Account management (auth) | Required |
| Name | Personal info → Name | Yes | No | Account management | Required |
| Device identifiers | Device or other IDs | Yes | No | Analytics, crash reporting | Required |
| FCM token | Device or other IDs | Yes | No | Push notifications | Required |
| App usage data | App activity → App interactions | Yes | No | Analytics | Required |
| Crash logs | App activity → Crash logs | Yes | No | Crash reporting (Crashlytics) | Required |

Additional declarations:
- Data is encrypted in transit (TLS 1.3)
- Users can request data deletion (in-app deletion flow, AUTH-008)
- Audio files are auto-deleted after 7 days

### 15.3 Content Rating

- Complete the IARC (International Age Rating Coalition) questionnaire in Play Console before launch
- Expected rating: suitable for all ages (no violent, sexual, or gambling content)
- Must be completed before the app can be published

### 15.4 Permissions Declarations

| Permission | Declaration Required | Justification |
|------------|---------------------|---------------|
| `RECORD_AUDIO` | Permission Declaration Form | Core functionality: recording in-person sales meetings for transcription and AI analysis. Audio is only captured when user explicitly starts a recording. |
| `FOREGROUND_SERVICE` | Standard declaration | Required for background audio recording while screen is off. |
| `FOREGROUND_SERVICE_MICROPHONE` | Standard declaration | Android 14+ requires typed foreground service. Used exclusively for audio recording. |
| `WAKE_LOCK` | Standard declaration | Keeps CPU active during recording when screen is off. |
| `POST_NOTIFICATIONS` | Runtime permission (API 33+) | Requested at runtime. Used for sync status and insight-ready notifications. |

**Important:** Do NOT request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` directly — this triggers Play Store rejection. Instead, use `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent to let the user opt in, and only for OEM-specific battery optimization whitelisting (FTX-004).

### 15.5 App Signing & Distribution

| Item | Requirement |
|------|-------------|
| Play App Signing | Enroll during first upload. Google manages the app signing key; you retain the upload key. |
| Build format | Android App Bundle (.aab) required. APK uploads are not accepted for new apps. |
| Internal testing track | Map to Alpha phase (5-8 internal users). No review required. |
| Closed testing track | Map to Closed Beta phase (5-8 companies, 40-50 agents). Requires tester email list or Google Group. |
| Open testing track | Map to Open Beta phase (20-30 companies). Publicly joinable, limited review. |
| Production track | Full launch after beta exit criteria met. Full Google review. |

### 15.6 Pre-Launch Checklist

| # | Item | Status | Blocker? |
|---|------|--------|----------|
| 1 | Privacy policy at public URL, linked in app settings and Play listing | Pending | Yes |
| 2 | Prominent disclosure screen before first recording (REC-015) | Pending | Yes |
| 3 | In-app account & data deletion flow (AUTH-008) | Pending | Yes |
| 4 | Data Safety form completed in Play Console | Pending | Yes |
| 5 | IARC content rating questionnaire completed | Pending | Yes |
| 6 | RECORD_AUDIO Permission Declaration Form submitted | Pending | Yes |
| 7 | `foregroundServiceType="microphone"` declared (FTX-005) | Pending | Yes |
| 8 | `POST_NOTIFICATIONS` runtime permission on Android 13+ (NOTIF-004) | Pending | Yes |
| 9 | Target SDK set to API 34 | Pending | Yes |
| 10 | Build as .aab (not APK) | Pending | Yes |
| 11 | Enrolled in Play App Signing | Pending | Yes |
| 12 | Store listing assets uploaded (icon, feature graphic, screenshots) | Pending | Yes |
| 13 | Short and full descriptions written | Pending | No |
| 14 | Contact email and support URL set | Pending | Yes |
| 15 | No `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` in manifest | Pending | Yes |
| 16 | Closed beta testers list uploaded to Play Console | Pending | No |

---

## 16. Cost Analysis

### 16.1 Per-Call Processing Costs

Estimated costs for a typical 30-minute call (using Groq Whisper v3 Turbo):

| Component | Cost (INR) | Notes |
|-----------|------------|-------|
| Transcription (Groq Whisper v3 Turbo) | ₹2-3 | ~$0.04/hr for 30-min avg call |
| LLM processing (GPT-4o Mini) | ₹0.10-0.30 | Summary, topics, sentiment with confidence scoring |
| Storage (R2, temporary) | ₹0.15 | ~10MB chunks for 7 days, zero egress |
| **Total per 30-min call** | **₹2.50-3.50** | |

### 16.2 Monthly Infrastructure Costs (MVP Scale)

| Component | Monthly Cost (INR) | Notes |
|-----------|-------------------|-------|
| Supabase Pro | ₹2,100 | $25/month base |
| Additional database | ₹0-4,000 | Based on usage |
| Cloudflare R2 storage | ₹300-500 | ~250GB peak at $0.015/GB, zero egress |
| Async job queue (Inngest) | ₹0-2,000 | Free tier covers MVP, paid at scale |
| Firebase (FCM + Crashlytics) | ₹0 | Free |
| Sentry (free tier) | ₹0 | Free (5K events/month) |
| Centralized logging (Axiom/Betterstack) | ₹0-2,000 | Free tier covers MVP |
| Domain & SSL | ₹500 | Annual amortized |
| OTP SMS provider (MSG91) | ₹1,000-3,000 | ~₹0.20/OTP, depends on auth volume |
| **Total infrastructure** | **₹3,900-14,100** | Variable based on usage |

### 16.3 Unit Economics

For an agent doing 4 calls/day (average 30 minutes each):

- Daily processing cost: ~₹16-20
- Monthly processing cost: ~₹350-440 per agent
- Suggested pricing: ₹500-800 per agent/month (profitable per agent)

### 16.4 Pricing Recommendations

| Plan | Price | Includes |
|------|-------|----------|
| Starter | ₹3,000/month | Up to 5 agents, 500 minutes transcription |
| Growth | ₹7,500/month | Up to 15 agents, 1,500 minutes transcription |
| Business | ₹15,000/month | Up to 30 agents, 3,500 minutes transcription |
| Enterprise | Custom | Unlimited agents, volume discounts |

---

## 17. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hindi-English transcription quality poor | High | Medium | Evaluate Sarvam AI early; collect feedback via thumbs up/down; build transcript correction mechanism; confidence scoring flags low-quality results |
| Agents resist adoption (feel surveilled) | High | Medium | Position as productivity tool; show personal analytics; agent notes for their own use |
| Offline sync causes data loss | High | Low | Robust local Room DB; resumable chunked uploads; crash recovery for orphaned chunks; clear sync status UI |
| Processing costs exceed revenue | Medium | Low | Groq Whisper reduces costs 75%; track cost per call; per-agent daily limits as guardrails |
| Low-end phones have performance issues | Medium | Medium | Native Kotlin (no Flutter overhead); test on ₹8k-15k device matrix; lazy loading |
| OEM background restrictions kill recording | High | High | Foreground service + wakelock; OEM-specific whitelisting prompts; test on 5 target OEMs with dedicated playbooks |
| Provider API downtime | Medium | Low | Provider abstraction with automatic fallback; circuit breaker pattern; processing queue absorbs temporary outages |
| Privacy/legal concerns | Medium | Low | Consent checkbox with timestamp; data retention policy; legal review; DPDP compliance |
| Competition from enterprise players | Medium | Low | Focus on India-specific needs; price advantage; local language support |
| Audio quality too poor for transcription | Medium | Medium | On-device quality gate; LLM confidence scoring; agent guidance on microphone placement |

---

## 18. Open Questions & Future Considerations

### 18.1 Open Questions for MVP

- Which transcription provider (Groq Whisper vs. Sarvam) performs better for code-mixed Hindi-English? Need A/B testing.
- What is the acceptable transcription latency? 5 minutes? 15 minutes?
- What's the minimum viable insight set that delivers the 'aha moment'?
- What is the optimal audio bitrate for balancing file size vs transcription accuracy on mid-range phone microphones?

### 18.2 Future Feature Considerations

| Feature | Description |
|---------|-------------|
| **AI Coaching** | Post-call suggestions for improving sales techniques |
| **CRM Integration** | Sync call data to Salesforce, Zoho, etc. |
| **Competitive Intelligence** | Extract mentions of competitors from calls |
| **Voice Analytics** | Tone analysis, talk-to-listen ratio, interruption detection |
| **Phone Call Recording** | Extend to phone calls (not just in-person) |
| **Team Leaderboards** | Gamification elements for agent motivation |
| **Custom Insight Templates** | Industry-specific extraction (pharma: products mentioned, insurance: objections) |
| **Location Tracking** | Optional GPS-based location capture per call (with consent) for coverage maps |
| **Manager Comments** | Owner/admin can leave feedback on calls visible to agent |
| **Follow-up Reminders** | Auto-create reminders from AI-extracted next steps |
| **Photo/Document Capture** | Attach photos to calls (visiting cards, orders) |
| **CSV Data Export** | Export call data, customer data, analytics |

### 18.3 Technical Debt Considerations

- Plan for migration path if Supabase limits become constraining
- Consider CDN for dashboard static assets as user base grows
- Evaluate on-device ML for basic processing to reduce cloud costs
- Plan migration to self-hosted Whisper when processing volume exceeds 500 hours/day
- API versioning from day one (`/v1/` prefix) to support backward compatibility

---

## 19. Appendix

### A. Glossary

| Term | Definition |
|------|------------|
| **Agent** | Sales representative who records calls using the mobile app |
| **Owner** | Business owner who created the company and has full access |
| **Admin** | Manager promoted by owner, can view all calls and manage agents |
| **Call** | A recorded customer meeting/conversation |
| **Insight** | AI-generated analysis including summary, topics, next steps, confidence score |
| **Code-switching** | Mixing two languages (Hindi-English) in conversation |
| **OTP** | One-Time Password for phone authentication |
| **RLS** | Row Level Security — Supabase feature for data isolation |
| **R2** | Cloudflare R2 — S3-compatible object storage with zero egress fees |
| **Chunk** | A 45-90 second variable-length audio segment split at silence boundary (>=200ms gap) |
| **Foreground Service** | Android service that runs with a persistent notification, survives screen-off |
| **Circuit Breaker** | Pattern that automatically switches to fallback provider after consecutive failures |

### B. Sample Daily Report Format

```
SalesVoice Daily Report — 24 Jan 2026
Company: ABC Pharma

Calls: 12 | Agents: 4/6 active

Ramesh: 4 calls, 2 positive
Priya: 3 calls, pricing objection noted
Amit: 3 calls, 1 closing scheduled
Neha: 2 calls, new customer

Details: app.salesvoice.in/dashboard
```

*Note: Report kept under 500 characters for WhatsApp readability.*

### C. LLM Prompt Template for Insights

```
You are analyzing a sales call transcript. Extract the following information.

RULES:
- Only extract information explicitly stated in the transcript. Do not infer or hallucinate details.
- Transcript may contain Hindi-English code-mixed text. Preserve Hindi terms as-is. Generate summary in the dominant language of the transcript.
- If the transcript is shorter than 50 words or largely unintelligible, set confidence below 0.3 and note the quality issue in the summary.

EXAMPLES:

Example 1 — Good quality transcript:
Transcript: "So the Crocin 650mg, we have new packaging launching next month. Doctor sahab, aapko samples chahiye honge. I'll send 50 strips by Friday. Also the MR conference is on 15th February, registration is open."
Output:
{
  "summary": "Discussion about Crocin 650mg new packaging launch. Doctor requested samples - 50 strips to be sent by Friday. MR conference on Feb 15th mentioned.",
  "key_topics": ["Crocin 650mg", "new packaging", "sample request", "MR conference"],
  "next_steps": ["Send 50 strips of Crocin 650mg by Friday", "Follow up on MR conference registration"],
  "sentiment": "positive",
  "confidence": 0.92,
  "dominant_language": "hindi-english"
}

Example 2 — Poor quality transcript:
Transcript: "... [inaudible] ... okay ... yes ... [noise] ..."
Output:
{
  "summary": "Transcript too short or unintelligible for meaningful analysis.",
  "key_topics": [],
  "next_steps": [],
  "sentiment": "neutral",
  "confidence": 0.15,
  "dominant_language": "english"
}

NOW ANALYZE THIS TRANSCRIPT:

Extract:
1. Summary (2-3 sentences capturing the key points)
2. Key topics discussed (list of 3-5 items)
3. Next steps/action items (list of concrete actions)
4. Overall sentiment: positive/neutral/negative
5. Confidence score (0.0-1.0) based on transcript quality and extraction certainty
6. Dominant language of the transcript

Respond in JSON format:
{
  "summary": "...",
  "key_topics": ["topic1", "topic2", ...],
  "next_steps": ["action1", "action2", ...],
  "sentiment": "positive|neutral|negative",
  "confidence": 0.0-1.0,
  "dominant_language": "english|hindi|hindi-english"
}

Transcript:
{transcript}
```

### D. API Endpoints Summary (v1)

All endpoints prefixed with `/v1/`.

#### Authentication
- `POST /v1/auth/otp/send` — Send OTP to phone number (rate limited: 5/hr per number)
- `POST /v1/auth/otp/verify` — Verify OTP and get session (max 3 attempts, 10-min expiry)

#### App Config
- `GET /v1/config/min-version` — Get minimum required app version

#### Companies
- `POST /v1/companies` — Create company (owner only)
- `GET /v1/companies/:id` — Get company details
- `GET /v1/companies/:id/invite-link` — Get/regenerate invite link
- `PATCH /v1/companies/:id/settings` — Update company settings (daily call limit, etc.)

#### Users
- `GET /v1/users/me` — Get current user profile
- `POST /v1/users/join/:invite_code` — Join company via invite
- `GET /v1/companies/:id/agents` — List agents (owner/admin only)
- `DELETE /v1/companies/:id/agents/:agent_id` — Remove agent (owner/admin only)
- `PATCH /v1/companies/:id/agents/:agent_id/role` — Change agent role (owner only)

#### Calls
- `POST /v1/calls` — Create call record (agent)
- `GET /v1/calls` — List calls (filtered by role, cursor-based pagination, default last 7 days)
- `GET /v1/calls/:id` — Get call details with insights
- `PATCH /v1/calls/:id` — Update call metadata (agent notes, customer, type, outcome)
- `POST /v1/calls/:id/reprocess` — Trigger reprocessing of failed call (owner/admin only)
- `GET /v1/calls/failed` — List failed calls (owner/admin only)

#### Upload
- `POST /v1/calls/:id/upload-url` — Get presigned R2 upload URL for a chunk
- `POST /v1/calls/:id/upload-complete` — Signal all chunks uploaded, trigger processing

#### Audio Playback
- `GET /v1/calls/:id/audio-url` — Get presigned R2 download URL for audio playback (15-min expiry, within 7-day retention)

#### Customers
- `GET /v1/customers` — List customers (with fuzzy search)
- `POST /v1/customers` — Create customer
- `PATCH /v1/customers/:id` — Update customer details

#### Insights Feedback
- `POST /v1/calls/:id/insights/feedback` — Submit thumbs up/down rating
- `POST /v1/calls/:id/insights/corrections` — Submit transcript corrections

#### Reports
- `GET /v1/reports/daily` — Get today's daily report
- `GET /v1/reports/daily/:date` — Get historical report

#### Agent Analytics
- `GET /v1/analytics/agent/me` — Get personal analytics (calls count, outcome distribution)

---

### E. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | January 2025 | — | Initial PRD creation |
| 2.0 | January 2025 | — | Major revision: 44 gaps addressed. Architecture changes (Cloudflare R2, async job queue, Groq Whisper, native Kotlin). Added: pause/resume, audio chunking, resumable upload, admin role, agent notes/editing, AI feedback, audio quality gate, foreground service recording, OTP rate limiting, token revocation, pipeline checkpointing, offline insight caching, deep linking, force-update, API versioning, personal analytics, empty states, accessibility requirements. New sections: Monitoring & Observability, Testing Strategy. |
| 2.1 | January 2025 | — | Cross-team review updates: promoted key requirements to P0, fixed data model (removed circular FK, added fcm_token, audit_log, indexes), security hardening (Sections 12.6-12.11), updated Groq pricing, revised cost estimates. |
| 2.2 | January 2026 | — | Full rewrite addressing 10 cross-report consensus items: (1) silence-boundary chunking replacing fixed 30s overlap chunks, (2) centralized logging via Axiom/Betterstack, (3) CI/CD pipeline with GitHub Actions + Fastlane + Vercel, (4) provider abstraction with circuit breaker fallback, (5) notification batching with quiet hours, (6) audio playback promoted to P1 MVP, (7) OEM-specific test playbooks for 5 manufacturers, (8) UAT/beta program (alpha/closed/open), (9) crash recovery for orphaned chunks, (10) LLM prompt with few-shot examples, confidence scoring, and anti-hallucination guardrails. Fixed 4 contradictions: standardized presigned URL expiry to 15 minutes, consent model to checkbox+timestamp, refresh tokens to role-based expiry (7d/14d), cleaned up duplicate future features. Removed Sections 6 (User Stories) and 9 (User Flows) to eliminate redundancy; merged processing flow into Section 6.3. Reduced from 20 to 18 sections. Added confidence and dominant_language to call_insights schema, consent_timestamp to calls. |
| 2.3 | January 2026 | — | Play Store readiness additions: New Section 15 (Play Store Launch Requirements) covering store listing assets, Data Safety form, IARC content rating, permissions declarations, app signing & distribution tracks, and pre-launch checklist. Added AUTH-008 (in-app account/data deletion), REC-015 (prominent disclosure before first recording), NOTIF-004 (POST_NOTIFICATIONS runtime permission for Android 13+), FTX-005 (foregroundServiceType="microphone" for Android 14+). Tech stack updated with Target SDK API 34 and AAB build format. Section 9.4 updated with target SDK details. Section 10.4 updated with prominent disclosure and in-app data deletion. Section 10.5 strengthened privacy policy URL requirement. Sections renumbered 15→19 to accommodate new section. |

---

*End of Document*
