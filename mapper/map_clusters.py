#!/usr/bin/env python

from pathlib import Path
from kashima.mapper import buildMap

# ── User-defined visual customization ──────────────────────────────
MAG_BINS = [3.5,4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0]

DOT_PALETTE = {
    "3.5-4.5": "#fee391",  # Butter yellow (more visible on satellite)
    "4.5-5.0": "#fed976",
    "5.0-5.5": "#fed976",
    "5.5-6.0": "#feb24c",
    "6.0-6.5": "#fd8d3c",
    "6.5-7.0": "#fc4e2a",
    "7.0-7.5": "#e31a1c",
    "7.5-8.0": "#bd0026",
    "8.0-8.5": "#800026",
    "8.5-9.0": "#4d0026",
}

DOT_SIZES = {
    "3.5-4.5": 2,
    "4.5-5.0": 2,
    "5.0-5.5": 3,
    "5.5-6.0": 4,
    "6.0-6.5": 6,
    "6.5-7.0": 12,
    "7.0-7.5": 13,
    "7.5-8.0": 18,
    "8.0-8.5": 19,
    "≥8.5": 24,
}

BEACHBALL_SIZES = {
    "3.5-4.5": 18,
    "4.5-5.0": 18,
    "5.0-5.5": 24,
    "5.5-6.0": 26,
    "6.0-6.5": 30,
    "6.5-7.0": 34,
    "7.0-7.5": 38,
    "7.5-8.0": 42,
    "8.0-8.5": 46,
    ">=8.5": 54,
}

USER_FAULT_STYLE = {
    "N":   {"label": "Normal",                 "color": "#3182bd"},
    "R":   {"label": "Reverse",                "color": "#de2d26"},
    "SS":  {"label": "Strike-slip",            "color": "#31a354"},
    "NSS": {"label": "Normal-Strike-slip",     "color": "#6baed6"},
    "RSS": {"label": "Reverse-Strike-slip",    "color": "#fc9272"},
    "O":   {"label": "Oblique",                "color": "#bdbdbd"},
    "U":   {"label": "Undetermined",           "color": "#969696"},
}

# ── Build the map with simplified API ──────────────────────────────
# Project: South Deep Mine (Goldfields)
# Location: Doornport (New Facility) - 27.4602°S, 27.6501°E
# base_zoom_level=7, idea for 500 km window

ROOT = Path(__file__).resolve().parent

result = buildMap(
    # Core parameters
    latitude=-12.939727,  # S
    longitude=+15.240812,  # E
    radius_km=2500,
    output_dir=str(ROOT),
    # Magnitude filtering
    vmin=3.5,
    vmax=9.0,
    # Project metadata
    project_name="Longonjo TSF",
    client="Teck",
    # Layer visibility
    show_events_default=False,
    show_cluster_default=True,
    show_heatmap_default=True,
    show_beachballs_default=True,
    show_faults_default=True,
    show_epicentral_circles_default=True,
    # Zoom configuration
    base_zoom_level=7,
    min_zoom_level=5,
    max_zoom_level=15,
    # Map behavior
    default_tile_layer="Esri.WorldImagery",
    auto_fit_bounds=True,
    lock_pan=True,
    epicentral_circles=20,
    # Visual customization
    mag_bins=MAG_BINS,
    dot_palette=DOT_PALETTE,
    dot_sizes=DOT_SIZES,
    beachball_sizes=BEACHBALL_SIZES,
    fault_style_meta=USER_FAULT_STYLE,
    # Heatmap configuration
    heatmap_radius=50,
    heatmap_blur=30,
    heatmap_min_opacity=0.50,
    # Event scaling
    event_radius_multiplier=1.0,
    # Fault styling
    regional_faults_color="darkgreen",
    regional_faults_weight=4,
    # Data management
    keep_data=True,  # Keep ./data/ for inspection
    # User faults: regional Angola sources as example (GeoJSON en examples/mapper/faults)
    faults_files=[
        str(ROOT / "faults" / "Angola1982.geojson"),
        str(ROOT / "faults" / "Escosa2024.geojson"),
        str(ROOT / "faults" / "Guiraud2010.geojson"),
        str(ROOT / "faults" / "Neto2018.geojson"),
        str(ROOT / "faults" / "Nkodia2022.geojson"),
        str(ROOT / "faults" / "Pereira2003.geojson"),
        str(ROOT / "faults" / "ReyMoral2022.geojson"),
    ],
)

print(f"✔ Map  → {result['html']}")
print(f"✔ Data → {result['csv']}")
print(f"✔ Events: {result['event_count']:,}")
