
# Race Tracking App - Project Specification

## 📱 Mobile Development 2

### 🎯 Objective
Track and display participants' performances during a race.

### 👥 Target Audience
- Race management teams (triathlons, marathons, aquathons)

### 🚀 Key Features
- Race management
- Time tracking
- Dashboard
- Realtime updates

### 🧑‍🤝‍🧑 Team Composition
- 3 students

### 🗓️ Duration
- 6 weeks

## 📅 Agenda & Outcomes

| Date      | Deliverables                                 | Support       |
|-----------|----------------------------------------------|---------------|
| Mar 22nd  | ✓ Team Members                               | Telegram      |
| Apr 04th  | ✓ Project UX/UI <br> ✓ Selected User Stories  | Figma, JIRA   |
| May 07th  | ✓ Project Code <br> ✓ Project Presentation    | GitHub, Jury  |

## 🏁 Race Overview

A sport competition composed of 3 segments:
- Swimming (e.g., 1000 meters)
- Cycling (e.g., 20 km)
- Running (e.g., 5 km)

**Goal:** Track participant times for each sport and share the final results.

**Identifier:** BIB number (unique per participant)

## ⚠️ Key Challenges
- Efficient time tracking for concurrent arrivals
- Real-time synchronization across devices
- Live results board

## 👤 User Personas
- **Race Manager:** Controls race and participant data
- **Time Tracker:** Logs times for assigned segment

## 🧩 User Stories

### Priority 1
- CRUD participant info (Race Manager)
- Start/Finish a race (Race Manager)
- Track segment time by BIB tap (Time Tracker)
- Untrack time (Time Tracker)

### Priority 2
- View results board with segment & overall times (Race Manager)
- Get real-time updates (Race Manager)

### Priority 3
- Reset race data (Race Manager)
- 2-step time tracking for unclear BIBs (Time Tracker)

### Priority 4
- Manage multiple races (Race Manager)
- Customize segments and distances (Race Manager)
- Sign in/up and manage races (User)

## 🔄 User Flows

### Race Setup (Manager)
1. Add participants
2. Start race
3. Reset if needed

### Tracking (Time Tracker)
1. Select segment
2. Tap BIB to track
3. View segment time
4. Untrack if needed
5. Mark segment finished

### Race Monitoring (Manager)
1. Monitor dashboard
2. Race finishes when all segments complete
3. Export results

## 🗃️ Data Model Suggestions

### Race Stage
- Status: Not Started / Started / Finished
- Start Time

### Race (for multi-race support)
- Name
- Date & Time
- Segment Details

### Participant
- BIB Number
- First Name, Last Name
- Age, Gender (optional)
- School (not important)

### Segment Time
- Segment Time per participant

## 🧑‍💻 Technical Requirements

### Architecture Guidelines
- Use abstract repositories
- Use DTOs or static conversion methods
- State management via:
  - Global providers (e.g. RaceProvider)
  - Screen-specific providers
- Consistent shared UI widgets

### Coding Conventions
- Follow Flutter/Dart best practices

### Tech Stack
- **Frontend:** Flutter (Provider)
- **Backend & DB:** Any (Firebase recommended)

## 🔗 References
- [How race tracking works](https://www.raceclocker.com/How_To.php)
- [Best timing apps](https://raceid.com/organizer/timing/the-8-best-timing-apps-for-races)

## 📊 Evaluation Criteria

### Part 1 - UX / UI
- Figma user flow, design system, and usability heuristics

### Part 2 - Screens, Widgets & Providers
- Themed design, reusable widgets, efficient state handling

### Part 3 - Model & Repositories
- Abstract pattern, mock support, DTOs, CRUD operations

### Part 4 - Networking
- To be defined

### Part 5 - Architecture & Code Quality
- Clean code, modular, well-documented, follows conventions


