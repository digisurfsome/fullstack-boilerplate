-- Practitioner Module Migration
-- Tables for NLP submodality profiling, guided sessions, and technique protocols

-- ============================================================================
-- SUBMODALITY_PROFILES TABLE
-- Stores each user's positive and negative neural signature (submodality coding)
-- ============================================================================
CREATE TABLE IF NOT EXISTS submodality_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  profile_type TEXT NOT NULL CHECK (profile_type IN ('positive', 'negative')),
  -- Visual modalities
  brightness TEXT CHECK (brightness IN ('bright', 'dark', 'neutral')),
  color_type TEXT CHECK (color_type IN ('color', 'black_and_white', 'muted')),
  distance TEXT CHECK (distance IN ('near', 'far', 'medium')),
  size TEXT CHECK (size IN ('large', 'small', 'medium')),
  motion TEXT CHECK (motion IN ('moving', 'still')),
  focus TEXT CHECK (focus IN ('sharp', 'fuzzy')),
  framing TEXT CHECK (framing IN ('framed', 'panoramic')),
  dimensionality TEXT CHECK (dimensionality IN ('2d', '3d')),
  -- Auditory modalities
  volume TEXT CHECK (volume IN ('loud', 'soft', 'medium')),
  voice_source TEXT CHECK (voice_source IN ('own_voice', 'other_voice', 'no_voice')),
  sound_direction TEXT CHECK (sound_direction IN ('left', 'right', 'surround', 'behind')),
  tempo TEXT CHECK (tempo IN ('fast', 'slow', 'medium')),
  pitch TEXT CHECK (pitch IN ('high', 'low', 'medium')),
  clarity TEXT CHECK (clarity IN ('clear', 'muffled')),
  -- Kinesthetic modalities
  weight TEXT CHECK (weight IN ('heavy', 'light', 'neutral')),
  temperature TEXT CHECK (temperature IN ('warm', 'cold', 'neutral')),
  body_location TEXT,
  intensity INTEGER CHECK (intensity >= 0 AND intensity <= 10),
  pressure TEXT CHECK (pressure IN ('pressure', 'tingle', 'neutral')),
  body_motion TEXT CHECK (body_motion IN ('moving', 'still')),
  -- Perspective
  perspective TEXT CHECK (perspective IN ('associated', 'dissociated')),
  -- Metadata
  creation_date TIMESTAMPTZ DEFAULT NOW(),
  last_update_date TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, profile_type)
);

CREATE INDEX idx_submodality_profiles_user_id ON submodality_profiles(user_id);

ALTER TABLE submodality_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own submodality profiles"
  ON submodality_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own submodality profiles"
  ON submodality_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own submodality profiles"
  ON submodality_profiles FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own submodality profiles"
  ON submodality_profiles FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- TECHNIQUES TABLE
-- Library of available NLP/EFT/Hypnosis techniques with protocol definitions
-- ============================================================================
CREATE TABLE IF NOT EXISTS techniques (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('nlp', 'eft', 'hypnosis', 'visualization', 'hybrid')),
  difficulty TEXT NOT NULL DEFAULT 'beginner' CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  duration_minutes INTEGER NOT NULL DEFAULT 15,
  -- Protocol stored as structured JSON
  protocol JSONB NOT NULL DEFAULT '[]',
  -- Which modality areas this technique works with
  targets_visual BOOLEAN DEFAULT FALSE,
  targets_auditory BOOLEAN DEFAULT FALSE,
  targets_kinesthetic BOOLEAN DEFAULT FALSE,
  targets_perspective BOOLEAN DEFAULT FALSE,
  active BOOLEAN DEFAULT TRUE,
  creation_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_techniques_category ON techniques(category);
CREATE INDEX idx_techniques_active ON techniques(active);

ALTER TABLE techniques ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read techniques"
  ON techniques FOR SELECT
  USING (auth.role() = 'authenticated');

-- ============================================================================
-- SESSIONS TABLE
-- Tracks each guided session a user completes
-- ============================================================================
CREATE TABLE IF NOT EXISTS practitioner_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  technique_id UUID NOT NULL REFERENCES techniques(id),
  -- Session target
  target_category TEXT NOT NULL CHECK (target_category IN ('health', 'financial', 'relationship', 'skill', 'craving', 'custom')),
  target_description TEXT NOT NULL,
  desired_outcome TEXT NOT NULL,
  -- Session state
  status TEXT NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'abandoned')),
  current_phase TEXT DEFAULT 'setup',
  -- Intensity tracking
  initial_intensity INTEGER CHECK (initial_intensity >= 0 AND initial_intensity <= 10),
  final_intensity INTEGER CHECK (final_intensity >= 0 AND final_intensity <= 10),
  intensity_log JSONB DEFAULT '[]',
  -- Session data (responses, notes, etc.)
  session_data JSONB DEFAULT '{}',
  -- Journal entry after session
  journal_entry TEXT,
  -- Timestamps
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  creation_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON practitioner_sessions(user_id);
CREATE INDEX idx_sessions_technique_id ON practitioner_sessions(technique_id);
CREATE INDEX idx_sessions_status ON practitioner_sessions(status);
CREATE INDEX idx_sessions_started_at ON practitioner_sessions(started_at DESC);

ALTER TABLE practitioner_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own sessions"
  ON practitioner_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sessions"
  ON practitioner_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sessions"
  ON practitioner_sessions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- SWAP_TARGETS TABLE
-- Stores the specific items being swapped (for dislike/like technique)
-- ============================================================================
CREATE TABLE IF NOT EXISTS swap_targets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID REFERENCES practitioner_sessions(id) ON DELETE SET NULL,
  -- What's being swapped
  source_label TEXT NOT NULL,
  source_modalities JSONB NOT NULL DEFAULT '{}',
  destination_label TEXT NOT NULL,
  destination_modalities JSONB NOT NULL DEFAULT '{}',
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  swap_type TEXT NOT NULL CHECK (swap_type IN ('dislike', 'like', 'scramble', 'health', 'goal')),
  -- Metadata
  notes TEXT,
  creation_date TIMESTAMPTZ DEFAULT NOW(),
  last_update_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_swap_targets_user_id ON swap_targets(user_id);
CREATE INDEX idx_swap_targets_active ON swap_targets(is_active);

ALTER TABLE swap_targets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own swap targets"
  ON swap_targets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own swap targets"
  ON swap_targets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own swap targets"
  ON swap_targets FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own swap targets"
  ON swap_targets FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- SEED: Default techniques
-- ============================================================================
INSERT INTO techniques (name, description, category, difficulty, duration_minutes, protocol, targets_visual, targets_auditory, targets_kinesthetic, targets_perspective) VALUES
(
  'Submodality Dislike Swap',
  'Swap the submodality profile of something you crave with something you find repulsive. Used for eliminating food cravings, bad habits, or unwanted attractions.',
  'nlp',
  'beginner',
  15,
  '[
    {"phase": "setup", "title": "Identify Target", "instruction": "What do you want to stop craving or dislike?", "duration_seconds": 60, "type": "input"},
    {"phase": "setup", "title": "Identify Anchor", "instruction": "Think of the most disgusting thing you have ever experienced related to this category. Something that makes you physically sick.", "duration_seconds": 60, "type": "input"},
    {"phase": "extract", "title": "Map Target Modalities", "instruction": "Close your eyes and think about the thing you crave. We will go through each sense.", "duration_seconds": 180, "type": "modality_extraction"},
    {"phase": "extract", "title": "Map Anchor Modalities", "instruction": "Now think about the disgusting thing. We will map exactly how your brain codes it.", "duration_seconds": 180, "type": "modality_extraction"},
    {"phase": "swap", "title": "The Swap", "instruction": "Now we swap. Take every modality from the disgusting experience and apply it to the craved thing. See it dark, far away, hear the awful sounds, feel the nausea.", "duration_seconds": 120, "type": "guided"},
    {"phase": "scramble", "title": "Scramble Pattern", "instruction": "See the craving BIG and BRIGHT. Now SHRINK it, drain the color, push it far away. Bring up the disgust HUGE and VIVID. Repeat faster and faster.", "duration_seconds": 90, "type": "timed_repetition", "repetitions": 7},
    {"phase": "condition", "title": "Lock It In", "instruction": "Take a deep breath. Feel the new association settling in. The craving now triggers the disgust response.", "duration_seconds": 60, "type": "guided"},
    {"phase": "test", "title": "Test", "instruction": "Think about the thing you used to crave. What happens? Rate the craving now on 0-10.", "duration_seconds": 60, "type": "intensity_rating"}
  ]',
  true, true, true, true
),
(
  'Goal Visualization Installation',
  'Use AI-matched submodality profiling to install a vivid, emotionally charged visualization of your desired outcome. Combines NLP modality work with guided meditation.',
  'visualization',
  'beginner',
  20,
  '[
    {"phase": "setup", "title": "Define Your Goal", "instruction": "Describe the specific outcome you want. Be as detailed as possible.", "duration_seconds": 120, "type": "input"},
    {"phase": "setup", "title": "Category", "instruction": "Select the area of life this goal belongs to.", "duration_seconds": 30, "type": "category_select"},
    {"phase": "pain", "title": "Pain Amplification", "instruction": "Close your eyes. See your life 1 year from now if NOTHING changes. Make it dark, gloomy, feel the weight of staying stuck. Now 5 years. Now 10 years.", "duration_seconds": 180, "type": "guided"},
    {"phase": "pain", "title": "Pain Intensity", "instruction": "Rate the pain of NOT changing on 0-10. You need at least 8 to continue.", "duration_seconds": 30, "type": "intensity_rating", "minimum": 8},
    {"phase": "interrupt", "title": "Pattern Interrupt", "instruction": "STAND UP! Shake your whole body. Make the most ridiculous sound you can. Jump. Move. Break the state completely.", "duration_seconds": 30, "type": "interrupt"},
    {"phase": "pleasure", "title": "Success Visualization", "instruction": "Now see your life with this goal ACHIEVED. Make it BRIGHT, VIVID, CLOSE. Step INTO the scene. Feel the warmth, hear the celebration, feel the pride.", "duration_seconds": 300, "type": "guided"},
    {"phase": "pleasure", "title": "Pleasure Intensity", "instruction": "Rate the pleasure and excitement of having achieved this on 0-10. You need at least 8.", "duration_seconds": 30, "type": "intensity_rating", "minimum": 8},
    {"phase": "scramble", "title": "Scramble", "instruction": "Flash between the pain scene and the success scene. Pain - dark, heavy, stuck. SUCCESS - bright, warm, free. Faster. FASTER.", "duration_seconds": 90, "type": "timed_repetition", "repetitions": 7},
    {"phase": "condition", "title": "Emotional Lock-In", "instruction": "Stay in the success scene. Feel deep gratitude. It is already done. You already have it. Feel it in every cell of your body. Say thank you.", "duration_seconds": 180, "type": "guided"},
    {"phase": "test", "title": "Commitment", "instruction": "State out loud: I am committed to this outcome. It is already mine. Rate your belief on 0-10.", "duration_seconds": 60, "type": "intensity_rating"}
  ]',
  true, true, true, true
),
(
  'EFT Basic Tapping',
  'Emotional Freedom Technique basic recipe. Tap on meridian points while focusing on the issue to reduce emotional intensity.',
  'eft',
  'beginner',
  15,
  '[
    {"phase": "setup", "title": "Identify the Issue", "instruction": "What emotion or issue would you like to work on right now?", "duration_seconds": 60, "type": "input"},
    {"phase": "setup", "title": "Rate Intensity", "instruction": "On a scale of 0-10, how intense is this feeling right now?", "duration_seconds": 30, "type": "intensity_rating"},
    {"phase": "setup", "title": "Setup Statement", "instruction": "While tapping the karate chop point, repeat 3 times: Even though I have this [issue], I deeply and completely accept myself.", "duration_seconds": 45, "type": "guided_repeat", "repetitions": 3},
    {"phase": "tapping", "title": "Eyebrow Point", "instruction": "Tap on your eyebrow point and say your reminder phrase.", "duration_seconds": 15, "type": "tapping_point", "point": "eyebrow"},
    {"phase": "tapping", "title": "Side of Eye", "instruction": "Tap on the side of your eye and say your reminder phrase.", "duration_seconds": 15, "type": "tapping_point", "point": "side_of_eye"},
    {"phase": "tapping", "title": "Under Eye", "instruction": "Tap under your eye and say your reminder phrase.", "duration_seconds": 15, "type": "tapping_point", "point": "under_eye"},
    {"phase": "tapping", "title": "Under Nose", "instruction": "Tap under your nose and say your reminder phrase.", "duration_seconds": 15, "type": "tapping_point", "point": "under_nose"},
    {"phase": "tapping", "title": "Chin Point", "instruction": "Tap on your chin point and say your reminder phrase.", "duration_seconds": 15, "type": "tapping_point", "point": "chin"},
    {"phase": "tapping", "title": "Collarbone", "instruction": "Tap on your collarbone point and say your reminder phrase.", "duration_seconds": 15, "type": "tapping_point", "point": "collarbone"},
    {"phase": "tapping", "title": "Under Arm", "instruction": "Tap under your arm and say your reminder phrase.", "duration_seconds": 15, "type": "tapping_point", "point": "under_arm"},
    {"phase": "tapping", "title": "Top of Head", "instruction": "Tap on the top of your head and say your reminder phrase.", "duration_seconds": 15, "type": "tapping_point", "point": "top_of_head"},
    {"phase": "evaluate", "title": "Re-evaluate", "instruction": "Take a deep breath. On 0-10, what is the intensity now?", "duration_seconds": 30, "type": "intensity_rating"},
    {"phase": "evaluate", "title": "Next Step", "instruction": "If intensity dropped 2+ points, great progress! Do another round. If unchanged, try a different aspect of the issue.", "duration_seconds": 30, "type": "decision"}
  ]',
  false, false, true, false
),
(
  'Health Healing Visualization',
  'Guided visualization focused on physical healing. Associate the healed state with your positive modality profile. Designed for immune support, pain relief, and recovery.',
  'visualization',
  'intermediate',
  20,
  '[
    {"phase": "setup", "title": "Identify Health Target", "instruction": "What physical health issue do you want to work on? This can be for yourself or someone you care about.", "duration_seconds": 60, "type": "input"},
    {"phase": "setup", "title": "Who Is This For?", "instruction": "Are you working on your own health or visualizing for a loved one?", "duration_seconds": 30, "type": "choice", "options": ["myself", "loved_one"]},
    {"phase": "setup", "title": "Current State", "instruction": "Describe the current symptoms or condition as specifically as possible.", "duration_seconds": 60, "type": "input"},
    {"phase": "setup", "title": "Rate Severity", "instruction": "Rate the severity of this condition on 0-10.", "duration_seconds": 30, "type": "intensity_rating"},
    {"phase": "healing", "title": "Relaxation", "instruction": "Close your eyes. Take 5 deep breaths. With each exhale, release tension from your body. Feel yourself sinking into comfort.", "duration_seconds": 60, "type": "guided"},
    {"phase": "healing", "title": "See the Ailment", "instruction": "Visualize the affected area. See it with your negative modalities — dark, dim, heavy. Give the ailment a shape and color.", "duration_seconds": 90, "type": "guided"},
    {"phase": "healing", "title": "Transform", "instruction": "Now watch as bright, warm healing light floods the area. See the ailment shrinking, dissolving, being washed away. The area becomes bright, vivid, warm — matching your positive profile.", "duration_seconds": 120, "type": "guided"},
    {"phase": "healing", "title": "Already Healed", "instruction": "See the person (you or your loved one) completely healed. Vibrant. Strong. Laughing. Moving freely. Make this image HUGE, BRIGHT, CLOSE. Step into it.", "duration_seconds": 180, "type": "guided"},
    {"phase": "condition", "title": "Gratitude Lock-In", "instruction": "Feel deep gratitude. The healing has already happened. Feel it in your whole body. Say thank you. Mean it.", "duration_seconds": 120, "type": "guided"},
    {"phase": "test", "title": "Rate Confidence", "instruction": "Rate your confidence in the healing on 0-10.", "duration_seconds": 30, "type": "intensity_rating"}
  ]',
  true, true, true, true
);
