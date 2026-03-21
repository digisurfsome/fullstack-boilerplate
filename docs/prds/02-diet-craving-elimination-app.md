# PRD: Diet & Craving Elimination App (NLP-Powered Ozempic Alternative)

## Overview
An NLP-based app that eliminates food cravings using the submodality dislike/like swap technique. Diet-agnostic — works with keto, paleo, vegan, or any diet plan. Integrates with the existing keto grocery scanner app for a complete dietary transformation system.

## Problem Statement
Ozempic and similar GLP-1 drugs are the biggest weight loss trend in history, but they're expensive, have side effects, and require ongoing medication. The real problem is cravings — there are 10-20 foods most people can't stop eating. If you could neurologically "uncrave" them, you'd have a dramatically better chance of sticking to any diet. NLP's dislike technique has been demonstrated to work in live training settings (the burger/canned spinach swap story) — but nobody has productized it.

## Core Technique: The Dislike/Like Swap

### How It Works
1. Pick the food you want to stop craving (e.g., burgers)
2. Pick the most disgusting food experience you've ever had (e.g., canned spinach that made you throw up)
3. Extract submodalities for BOTH:
   - What do you see? (bright/dark, close/far, vivid/dull)
   - What do you hear? (sizzling vs. gagging)
   - What do you feel? (warm satisfaction vs. nausea)
   - What do you smell? (delicious aroma vs. sewer water)
   - What do you taste? (savory perfection vs. rotten marination)
   - Are you in the scene or watching it?
4. Systematically SWAP every modality — apply the disgusting food's modality profile to the craved food
5. Scramble rapidly (5-7 reps) until the association locks
6. Test: think about the craved food → should trigger nausea/revulsion

### Key Feature: REVERSIBILITY
- The swap can be UNDONE at any time
- Enables flexible dieting: activate dislike for weekdays, deactivate for cheat days
- User never feels permanently trapped
- This is a massive differentiator from drugs or surgery

## Product Structure

### Onboarding
1. Select your diet plan (keto, paleo, carnivore, vegan, calorie counting, custom)
2. List your top 5-20 craved foods that don't fit the diet
3. List foods you need to eat more of but currently dislike
4. Submodality profiling (one-time): extract positive and negative neural signatures
5. Identify your "anchor disgust" memory (the canned spinach equivalent)

### Core Features

**Craving Eliminator Sessions**
- Pick a food from your craving list
- Guided 10-15 minute session walks you through the swap
- Uses audio guidance, visual prompts, haptic feedback
- Intensity rating after each session
- Reinforcement schedule: Day 1, Day 3, Day 7, Day 14, Day 30

**Food Love Installer**
- Reverse process: take a healthy food you hate
- Swap its modalities with a food you love
- Make broccoli feel like pizza in your mind

**Diet Integration**
- Connect to any diet plan
- Auto-suggest which foods to eliminate/install based on diet rules
- Track compliance — are you actually avoiding the swapped foods?

**Keto Scanner Integration**
- The existing keto app reads sugar/glycemic index off product labels
- Cross-reference: scanned "bad" foods get flagged for craving elimination
- Scanned "good" foods get flagged for love installation
- One ecosystem: scan → identify → eliminate craving → stick to diet

### Scheduling & Flexibility
- **Strict Mode:** All swaps active, maximum craving suppression
- **Flexible Mode:** Schedule cheat windows — undo swaps for specific meals/days
- **Gradual Mode:** Phase in swaps over weeks, starting with worst cravings
- **Emergency Undo:** One-tap reversal if a swap causes distress

## Business Model

### Pricing
- Free: 1 food swap + modality assessment
- Monthly subscription: Unlimited swaps, diet integration, progress tracking
- Annual plan: Discount + keto scanner integration
- Practitioner tier: Guided sessions with live NLP practitioner (see PRD-04)

### Market Position
- "The NLP alternative to Ozempic"
- No drugs, no side effects, no injections
- Reversible at any time
- Works with ANY diet, not just calorie restriction
- Cost: fraction of GLP-1 drugs ($1,000+/month)

### Market Size
- GLP-1 drug market: $50B+ and growing
- Diet app market: $4B+
- Target: Anyone who wants to lose weight but can't stop craving specific foods
- Secondary: Diet plan companies wanting to increase adherence rates

## Integration Points
- Keto grocery scanner app (existing)
- Visualization/Manifestation app (PRD-01) — visualize your ideal body
- Practitioner Bot (PRD-04) — guided swap sessions with AI practitioner

## MVP Priority
1. Submodality profiling (shared module with PRD-01)
2. Dislike swap guided session (single food)
3. Like swap guided session (single food)
4. Craving tracker / food log
5. Undo/redo swap functionality
6. Keto scanner integration
