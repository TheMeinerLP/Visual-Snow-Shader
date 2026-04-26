#ifndef LIB_CONFIG_GLSL
#define LIB_CONFIG_GLSL

/*
 * lib/config.glsl
 *
 * Overlay model:
 * Each symptom has a master slider STRENGTH (0..1).
 * At STRENGTH=0 the effect is invisible.
 * At STRENGTH=1 it is at full "clinically realistic" intensity.
 * Detail parameters (density, decay, speed etc.) are hidden in
 * advanced submenus.
 */

// =====================================================
//  GLOBAL — master controls
// =====================================================
#define GLOBAL_INTENSITY  1.0  // [0.0 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.0]
#define COMPARISON_MODE   0    // [0 1 2 3]

// =====================================================
//  STRENGTH MASTERS — the simple sliders on the main menu
//  Each symptom has exactly one STRENGTH value (0..1).
// =====================================================
#define STATIC_STRENGTH       0.30  // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define FLOATERS_STRENGTH     0.20  // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define PALINOPSIA_STRENGTH   0.00  // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define PHOTOPHOBIA_STRENGTH  0.00  // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define NYKTALOPIA_STRENGTH   0.00  // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define BLUE_FIELD_STRENGTH   0.00  // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define SELF_LIGHT_STRENGTH   0.00  // [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]

#define ENABLE_BLUE_AGGRAVATION    0     // [0 1]
#define BLUE_AGGRAVATION_STRENGTH  0.7   // [0.0 0.25 0.5 0.7 1.0 1.5 2.0 3.0]

// =====================================================
//  ADVANCED PARAMETERS — multiplied by STRENGTH
// =====================================================

// Static
#define STATIC_AMPLITUDE   0.20  // [0.05 0.08 0.10 0.12 0.15 0.18 0.20 0.25 0.30 0.40 0.50]
#define STATIC_DENSITY     0.80  // [0.20 0.30 0.40 0.50 0.60 0.70 0.75 0.80 0.85 0.90 1.00]
#define STATIC_GRAIN_SIZE  1.0   // [0.5 0.75 1.0 1.25 1.5 2.0 2.5 3.0 4.0]
#define STATIC_FLICKER     1.0   // [0.0 0.10 0.25 0.50 0.75 1.0 1.5 2.0]
#define STATIC_TYPE        1     // [0 1]
#define STATIC_COLORED     0     // [0 1]

// Floaters
#define FLOATERS_COUNT     2.0   // [0.5 1.0 1.5 2.0 2.5 3.0 4.0 5.0 7.0 10.0]
#define FLOATERS_SIZE      0.7   // [0.3 0.5 0.7 0.8 1.0 1.3 1.6 2.0 2.5]
#define FLOATERS_OPACITY   0.50  // [0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.85 1.00]
#define FLOATERS_DRIFT     1.0   // [0.0 0.25 0.5 0.75 1.0 1.5 2.0 3.0]

// Palinopsia
#define PALINOPSIA_BLEND        0.40  // [0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 1.00]
#define PALINOPSIA_DECAY        0.90  // [0.80 0.82 0.85 0.88 0.90 0.92 0.94 0.96 0.98]
#define PALINOPSIA_BRIGHT_BIAS  0.6   // [0.0 0.2 0.4 0.6 0.8 1.0]
#define PALINOPSIA_PICKUP       0.35  // [0.10 0.20 0.30 0.35 0.40 0.50 0.60]

// Photophobia
#define PHOTOPHOBIA_BLOOM       0.50  // [0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 1.00]
#define PHOTOPHOBIA_OVERSHOOT   0.30  // [0.0 0.10 0.20 0.30 0.40 0.50 0.60 0.80 1.0]
#define PHOTOPHOBIA_RADIUS      3.0   // [1.0 2.0 3.0 3.5 4.0 5.0 7.0 10.0]

// Nyctalopia
#define NYKTALOPIA_DESATURATION    0.70  // [0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define NYKTALOPIA_DARKENING       0.50  // [0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 1.00]
#define NYKTALOPIA_THRESHOLD       0.18  // [0.05 0.10 0.15 0.18 0.20 0.25 0.30 0.40]

// Blue Field
#define BLUE_FIELD_DENSITY    1.5   // [0.5 1.0 1.5 2.0 3.0 4.0 6.0 10.0]
#define BLUE_FIELD_SIZE       1.0   // [0.5 0.7 0.85 1.0 1.2 1.5 2.0]
#define BLUE_FIELD_BRIGHTNESS 0.70  // [0.20 0.30 0.40 0.50 0.60 0.70 0.80 1.00]
#define BLUE_FIELD_SPEED      1.5   // [0.0 0.25 0.5 1.0 1.5 2.0 3.0 5.0]

// Self-light
#define SELF_LIGHT_BRIGHTNESS   0.50  // [0.10 0.20 0.30 0.40 0.50 0.70 1.00]
#define SELF_LIGHT_SPEED        0.06  // [0.0 0.02 0.04 0.06 0.08 0.10 0.15 0.25]
#define SELF_LIGHT_THRESHOLD    0.06  // [0.02 0.04 0.06 0.08 0.10 0.15 0.20]
#define SELF_LIGHT_SCALE        4.0   // [1.0 2.0 3.0 4.0 5.0 7.0 10.0]

// =====================================================
//  INFO OPTIONS
// =====================================================
//#define info_about
//#define info_default
//#define info_screening
//#define info_static
//#define info_palinopsia
//#define info_floaters
//#define info_blue_field
//#define info_self_light
//#define info_photophobia
//#define info_nyktalopia
//#define info_blue_aggravation
//#define info_disclaimer
//#define info_credits

#endif
