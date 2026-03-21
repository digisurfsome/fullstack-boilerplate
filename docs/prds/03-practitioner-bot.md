# PRD: AI Practitioner Bot (NLP/EFT/Hypnosis Session Leader)

## Overview
An AI-powered practitioner that leads users through clinical-style sessions — NLP techniques, EFT tapping, hypnosis, and custom modality work. Operates like booking a real practitioner: appointments, session packages, structured protocols. The "brain" is a specialized AI agent loaded with technique-specific knowledge and guided by strict protocol files.

## Problem Statement
Thousands of NLP practitioners, EFT tappers, and hypnotherapists charge $100-500/session. Access is limited by geography, availability, and cost. The techniques themselves are systematic and protocol-driven — ideal for AI automation. A bot that can lead someone through a full NLP dislike swap, an EFT tapping sequence, or a hypnosis induction at a fraction of the cost would democratize access to these powerful tools.

## Core Concept: The Brain

### What Is "The Brain"?
The brain is NOT traditional RAG (retrieval-augmented generation). It's a structured agent system with:

1. **Protocol Files (the "Claude MD" equivalent)**
   - Markdown files defining the exact step-by-step procedure for each technique
   - Decision trees: "If client reports X, do Y. If intensity is below 3, move to next round."
   - Timing guidelines: how long each phase should take
   - Safety rails: when to stop, when to refer out, contraindications
   - These are the RULES the bot follows — not suggestions, not context, but hard instructions

2. **Technique Knowledge Base**
   - Detailed descriptions of each technique (NLP anchoring, swish pattern, reframing, timeline therapy, etc.)
   - The submodality checklist and how to extract/apply it
   - EFT tapping points, sequences, setup phrases
   - Hypnosis scripts: inductions, deepeners, suggestions, emergence
   - Loaded as structured data the agent can reference during sessions

3. **Session State Management**
   - Tracks where in the protocol the session currently is
   - Stores client responses, intensity ratings, modality profiles
   - Maintains context across multi-session treatment plans
   - Persists between sessions (client comes back next week, bot remembers everything)

4. **Conversational Layer**
   - Voice AI interface (real-time conversation, not text chat)
   - Empathetic, professional tone calibrated to practitioner style
   - Listens for emotional cues, adjusts pacing
   - Asks probing questions per the protocol
   - Guides visualization with descriptive language

### Architecture of the Brain

```
┌─────────────────────────────────────────────┐
│              PRACTITIONER BOT               │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────┐    ┌──────────────────┐   │
│  │  Protocol    │    │  Technique       │   │
│  │  Files       │    │  Knowledge Base  │   │
│  │  (.md rules) │    │  (structured     │   │
│  │              │    │   reference)     │   │
│  └──────┬───────┘    └────────┬─────────┘   │
│         │                     │             │
│         ▼                     ▼             │
│  ┌──────────────────────────────────────┐   │
│  │         AGENT CORE (LLM)            │   │
│  │  - Follows protocol files strictly   │   │
│  │  - References technique knowledge    │   │
│  │  - Manages session state             │   │
│  │  - Makes clinical decisions          │   │
│  └──────────────┬───────────────────────┘   │
│                 │                            │
│                 ▼                            │
│  ┌──────────────────────────────────────┐   │
│  │       SESSION STATE STORE            │   │
│  │  - Client profile & history          │   │
│  │  - Current session phase             │   │
│  │  - Modality profiles                 │   │
│  │  - Progress tracking                 │   │
│  │  - Treatment plan                    │   │
│  └──────────────┬───────────────────────┘   │
│                 │                            │
│                 ▼                            │
│  ┌──────────────────────────────────────┐   │
│  │       VOICE / CHAT INTERFACE         │   │
│  │  - Real-time voice (preferred)       │   │
│  │  - Text chat (fallback)              │   │
│  │  - Empathetic, professional tone     │   │
│  └──────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

### How the Brain Works (Step by Step)

1. **Client books session** → selects technique type (NLP, EFT, hypnosis, etc.)
2. **Bot loads protocol file** for that technique type
3. **Bot checks session state** → first session? Follow intake protocol. Returning? Resume treatment plan.
4. **Bot follows protocol strictly:**
   - Step 1 of protocol: "Ask client what they want to work on today"
   - Client responds
   - Step 2: "Rate the intensity of the issue on a scale of 0-10"
   - Client responds → bot stores rating
   - Step 3: "Begin setup phrase: 'Even though I [issue], I deeply and completely accept myself'"
   - ... and so on through the entire technique
5. **Bot makes clinical decisions** based on protocol decision trees:
   - "If intensity dropped by 2+ points → continue current approach"
   - "If intensity unchanged after 3 rounds → switch to different aspect"
   - "If client reports new memory surfacing → pivot to that memory"
6. **Session ends** → bot summarizes, assigns homework, schedules next session
7. **State persisted** → next session picks up where this one left off

### What Makes This Different From RAG
- RAG retrieves chunks of text and hopes the LLM figures out what to do
- This system has **explicit protocol files that act as instructions** — the LLM is told exactly what to do at each step
- The knowledge base is **structured reference material**, not a dump of documents
- Session state is **actively managed**, not reconstructed from chat history
- The bot **follows a clinical procedure**, not just answering questions

### Implementation: Best Practices (Current State of Art)

**Agent Framework:**
- Claude Agent SDK or similar framework
- System prompt = practitioner identity + session rules
- Protocol files loaded as tool-callable structured instructions
- Function calling for: update session state, get next protocol step, log intensity rating, schedule follow-up

**Protocol File Format:**
```markdown
# EFT Basic Recipe Protocol

## Phase 1: Setup
- Ask: "What would you like to work on today?"
- Store: {issue_description}
- Ask: "On a scale of 0-10, how intense is this feeling right now?"
- Store: {initial_intensity}
- If {initial_intensity} < 3: "This is relatively mild. Would you like to work on something with more charge?"

## Phase 2: Setup Statement
- Guide: "Repeat after me: Even though I {issue_description}, I deeply and completely accept myself."
- Repeat 3x while tapping karate chop point
- Reminder phrase: Extract 3-5 word summary of {issue_description}

## Phase 3: Tapping Sequence
- For each point [eyebrow, side of eye, under eye, under nose, chin, collarbone, under arm, top of head]:
  - Guide: "Tap on your {point} and say: {reminder_phrase}"
  - Pause 2 seconds between points

## Phase 4: Re-evaluate
- Ask: "Take a deep breath. On 0-10, what's the intensity now?"
- Store: {current_intensity}
- If {current_intensity} dropped 2+: "Great progress. Let's do another round."
- If {current_intensity} unchanged: "Let's try a different aspect. What comes up when you think about this?"
- If {current_intensity} = 0: "Wonderful. The charge is gone. Let's test it..."
```

**Session State Schema:**
```json
{
  "client_id": "uuid",
  "session_number": 3,
  "technique": "eft_basic",
  "current_phase": "tapping_round_2",
  "issue": "anxiety about public speaking",
  "initial_intensity": 8,
  "intensity_log": [8, 6, 4],
  "modality_profile": { "positive": {...}, "negative": {...} },
  "memories_surfaced": ["5th grade presentation incident"],
  "homework": ["tap 2x daily on reminder phrase"],
  "next_session": "2026-03-28T14:00:00Z",
  "treatment_plan": {
    "goal": "reduce public speaking anxiety to 0-1",
    "sessions_estimated": 5,
    "techniques_planned": ["eft_basic", "nlp_reframe", "timeline_therapy"]
  }
}
```

**Voice Integration:**
- Real-time voice API (ElevenLabs, OpenAI Realtime API, Deepgram)
- Low latency critical — practitioner needs to feel present
- Tone: calm, empathetic, professional, confident
- Pacing: slower during emotional moments, more directive during technique steps

## Technique Modules (Loadable)

### Module: NLP Core
- Submodality extraction and profiling
- Dislike/Like swap
- Scramble pattern
- Swish pattern
- Reframing (context and meaning)
- Anchoring (stacking, collapsing)
- Timeline therapy basics
- Meta-programs assessment

### Module: EFT / Faster EFT
- Basic recipe (setup + tapping rounds)
- Movie technique (for specific memories)
- Tearless trauma technique
- Chasing the pain
- Faster EFT: "Grab, flip, let go" protocol
- Memory tapping (list all negative memories, tap through each)

### Module: Hypnosis
- Progressive relaxation induction
- Elman induction
- Deepening techniques
- Direct suggestion scripts
- Metaphorical suggestion scripts
- Parts therapy
- Regression
- Emergence / awakening

### Module: Custom/Hybrid
- The user's personal mashup technique (from PRD-01)
- Visualization + modality swap + emotional conditioning
- Health-focused protocols
- Goal manifestation protocols

## Business Model

### Client-Facing (B2C)
- Per-session pricing: $15-30/session (vs. $100-500 human practitioner)
- Session packages: 5 for $60, 10 for $100
- Monthly unlimited: $49/month
- Includes: session recordings, homework reminders, progress tracking

### Practitioner Platform (B2B)
- Practitioners upload their OWN protocol files
- Bot operates under their brand/voice
- They set their own pricing
- Platform takes percentage
- Practitioners handle complex cases; bot handles routine sessions
- Hybrid model: bot does intake + basic work, practitioner handles breakthroughs

### White-Label (B2B2C)
- Diet companies license the craving elimination module
- Wellness brands license the meditation/visualization module
- Sales training companies license the sales bot module (see PRD-04)

## Safety & Ethics
- Clear disclaimer: "This is not a replacement for licensed therapy"
- Intensity monitoring: if client reports 9-10 on trauma, recommend human practitioner
- Emergency protocols: if client expresses self-harm, provide crisis resources immediately
- Session recordings available for client review
- Opt-in data sharing for technique improvement

## MVP Priority
1. Single technique: EFT Basic Recipe (most structured, easiest to protocol-ize)
2. Voice interface with protocol-following agent
3. Session state persistence
4. Intensity tracking and basic decision tree
5. Appointment booking and session packages
6. Add NLP module (submodality work, dislike swap)
7. Add hypnosis module
